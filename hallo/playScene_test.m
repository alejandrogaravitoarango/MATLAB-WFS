clc

% for now, used fixed levels for three trials
vLvlAmbient = [-10 -10 -10];
vLvlSpeech = [-20 -26 -30];

stConfig.vPlayTime = [-1 6 8];
stConfig.vDataSet = 3; 

iLvl                         = 1;
stConfig.deviceID            = 1;

stConfig.iTrial              = 1;
stConfig.isDemo              = true; % only play 20s 
stConfig.isDirectionalSpeech = true; 
stConfig.angleSpeech         = 0; % one of [0 90 135 180 270]
stConfig.fgHighpass          = 75; 
stConfig.isHighpass          = true;
stConfig.startAmbient        = 231; % [s]

marker = lslMarker;

fprintf('Make sure all signals are being received properly\nand the recording is already started.\n\nPlease press Enter to continue ...\n')  
pause; pause(30);
disp('Session in progress ...')

Countdown;

marker.set(['Ambient Level: ' num2str(vLvlAmbient)]);
marker.set(['Speech Level: ' num2str(vLvlSpeech)]);
marker.set(['Text Number: ' num2str(stConfig.vDataSet)]);
marker.set('Start');

playScene(vLvlSpeech(iLvl), vLvlAmbient(iLvl), stConfig);

marker.set('Stop');
pause(2);
clear marker;

disp('Finished !')
