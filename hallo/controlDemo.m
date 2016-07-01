function [vResult, ws] = controlDemo()

%% configuration
nDataSets       = 15; 
nTrials         = 3;
isRandom        = 0; 

portWebSocket   = 6666; 
portWebServer   = 8082;

stConfig.deviceID            = 1;
stConfig.isDemo              = true; % only play 20s 
stConfig.isDirectionalSpeech = true; 
stConfig.angleSpeech         = 0; % one of [0 90 135 180 270]
stConfig.isHighpass          = true;
stConfig.fgHighpass          = 75; % [Hz]
stConfig.startAmbient        = 231; % [s]

%% path
fullpath = mfilename('fullpath');
[currentPath, ~, ~] = fileparts(fullpath);
cd(currentPath)

%% setting things up
stControl.update = @update;

% start webserver
startWebServer(portWebServer);
% start websocket server and wait for client
ws = halloServer(portWebSocket, stControl); 
fprintf('Waiting for client to connect...\n\n');
vTime = 0; 
while isempty(ws.connections); 
    pause(.1); 
    % manual timer
    vTime = vTime + 1; 
    if ( vTime == 100 ) 
       fprintf('Timed out... bye. \n\n');
       ws.delete;
       return; 
    end
end

fprintf('Connected, starting... \n\n');

% setup maker stream
marker = lslMarker;

% prepare list/sentences
if isRandom 
    stConfig.vDataSet = randperm(nDataSets,nTrials);
else
    stConfig.vDataSet = 1:nTrials;
end % if isRandom

[ vResult, ...
  vLvlSpeeech, ...
  vLvlAmbient     ] = deal(zeros(nTrials,1));

% for now, used fixed levels for three trials
vLvlAmbient = [-10 -10 -10];
vLvlSpeeech = [-23 -26 -28];

stConfig.vPlayTime   = [5 5 5]; 

for iTrial = 1:nTrials
    
    fprintf('\t Trial #%d',iTrial);
    
    stConfig.iTrial = iTrial;
    
    marker.set(['Trial ' num2str(iTrial) ': Start']);
    
    playScene(vLvlSpeeech(iTrial), vLvlAmbient(iTrial), stConfig);
        
    marker.set(['Trial ' num2str(iTrial) ': Stop playback']);
    
    ws.send(ws.connections{3}, 'false');  % enable buttons
    
    while ~vResult(iTrial)
        pause(.1);
    end
           
    marker.set(['Trial ' num2str(iTrial) ': Answer set']);
    
    fprintf('\t answer #%d\n',vResult(iTrial));

    if vResult == -1; 
        fprintf('\n\t Run cancelled by client');
        break;
    end
    
%     if iTrial ~= nTrials
%         vLvlSpeeech(iTrial+1) = levelControl(vLvlSpeeech(iTrial), ...
%                                              vLvlAmbient(iTrial), ...
%                                              vResult(iTrial) );
%     end
    
    marker.set(['Trial ' num2str(iTrial) ': End']);

end

% delete websocket server
ws.delete;

    function update(value)
       
        vResult(iTrial) = value; 
        
    end % update()
        
end % controlDemo()