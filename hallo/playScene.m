function playScene( lvlSignal, lvlAmbient, stConfig )
% Plays WFS scene
% 
% Input
%   list        : Current test list/sentence/section 
%   lvlSpeaker  : Signal level speech signal [dB FS]
%   lvlAmbient  : Signal level ambiient signal [dB FS]
%   stConfig    : Configuration
% 
%   150615sk

% define ambient audio data as persistent, this should be implemented 
% as a class, but who has the time?!
%persistent dataAmbient;

% audio location
dataPath        = [ filesep , ...
                    'media' filesep , ...
                    'hallo' filesep , ...
                    '2TB_BLOCK' filesep , ...
                    'Hoertechnik_Audiologie' filesep , ...
                    'hallo' filesep ];
                
dataPathAmbient = [ 'WfsAufnahmenHALLO' filesep , ...
                    '150501_EigenMikeAufnahmen' filesep , ...
                    'StadtOhneSprache' filesep ];
   
dataPathSpeech  = [ 'sprachaufnahmen_hallo' filesep ];

% load speech file for current list
if stConfig.isDirectionalSpeech
    dataPathSpeech = [ dataPathSpeech 'directional' filesep ];
    dataFileSpeech = [ 'Text' num2str(stConfig.vDataSet(stConfig.iTrial)) '_' num2str(stConfig.angleSpeech,'%05.1f') '.wav'];    
else
    dataFileSpeech = [ 'Text' num2str(stConfig.vDataSet(stConfig.iTrial)) '.wav'];
end

if stConfig.vPlayTime(stConfig.iTrial) ~= -1
    [dataSpeech, fsSpeech]  = audioread([dataPath dataPathSpeech dataFileSpeech], [1 stConfig.vPlayTime(stConfig.iTrial)*48e3]);
else
    [dataSpeech, fsSpeech]  = audioread([dataPath dataPathSpeech dataFileSpeech]);
end
dataSpeech              = dataSpeech(:,1); % single channel
lenSignal               = length(dataSpeech);

% load ambient data
% mics from front, clockwise: 4 11 23 18 20 27 7 2
% facing dummy              : 20 27 7 2 4 11 23 18             
vAmbientChannel = [20 27 7 2 4 11 23 18]; % horizontal mics of EM32
nAmbientChannel = length(vAmbientChannel);

dataAmbient = zeros(lenSignal, nAmbientChannel);
    
idxStart    = stConfig.startAmbient * fsSpeech;
idxStop     = idxStart + lenSignal - 1;

for iChannel = 1:nAmbientChannel
    dataFileAmbient = [ dataPath dataPathAmbient num2str(vAmbientChannel(iChannel),'%02d') '-150504.wav' ];
    [dataAmbient(:,iChannel), fsAmbient] = audioread(dataFileAmbient, [idxStart idxStop]);
end % for iChannel


% adjust signal level and copy into output array
dataOutput                          = zeros(lenSignal, nAmbientChannel + 1);
dataOutput(:,end)                   = dataSpeech  .* 10^(lvlSignal /20) / max(rms(dataSpeech));
dataOutput(:,1:nAmbientChannel)     = dataAmbient .* 10^(lvlAmbient/20) / max(rms(dataAmbient));

% positioning
radiusAmbient   = 1.7;    % [m]
distanceSpeaker = 1.2;    % [m]
angleSpeaker    = pi/10; % [rad]
showFigure      = 1;    % 1: plot source postion; 0: no plot

% ambient sources
angleAmbient    = (1:nAmbientChannel) .* (2*pi / nAmbientChannel) - pi/8;
xPosSources     = radiusAmbient * sin(angleAmbient);
yPosSources     = radiusAmbient * cos(angleAmbient);

% add speech source
xPosSources     = [ xPosSources (distanceSpeaker * sin(angleSpeaker)) ];
yPosSources     = [ yPosSources (distanceSpeaker * cos(angleSpeaker)) ];
% shift to the left
xPosSources     = xPosSources + 0.7;

% show position of sources in a plot
if showFigure
    plot(xPosSources,yPosSources,'or','MarkerSize',10,'LineWidth',4)
    grid on;
    axis square;
end

% audio configuration
msound('close')
lAudioBlock     = 2^11; % [samples]

msound('openWrite', stConfig.deviceID, fsAmbient, lAudioBlock, nAmbientChannel+1);

% prepare block processing, pad last block with zeros
nBlocks     = ceil(size(dataOutput,1)/lAudioBlock); % last block may be incomplete
padding     = zeros(nBlocks * lAudioBlock - size(dataOutput,1), nAmbientChannel+1);
dataOutput  = [dataOutput; padding];

% init sourcetype of WFS-function
vSourceType = zeros(1, size(dataOutput,2)); % 0 for point source;
isDebug     = 0; % 1 to get more details

% fsSpatial     = 1; % [Hz]
% updateSpatial = floor(fsSpeech / lAudioBlock / fsSpatial); 

% highpass
if stConfig.isHighpass
    [B,A]       = butter(4,stConfig.fgHighpass/fsAmbient*2,'high');
    dataOutput  = filter(B,A,dataOutput);
end


% playback loop
for iBlock = 1:nBlocks
    
%     % send control data only every nth frame, TOO SLOW
%     if ~rem(iBlock,updateSpatial)
%         for iChannel = 1:1%length(xPosSources)
%             wfs_oscsend(xPosSources(iChannel),yPosSources(iChannel),iChannel,vSourceType(iChannel),isDebug);
%         end 
%     end
%     
    % send one control packet each audio frame
    iChannel = rem(iBlock,nAmbientChannel+1)+1;
    wfs_oscsend(xPosSources(iChannel),yPosSources(iChannel),iChannel,vSourceType(iChannel),isDebug);

    curAudio = dataOutput( (1:lAudioBlock) + (iBlock-1) * lAudioBlock,:);
    msound('putSamples', curAudio);
    
end

msound('close')