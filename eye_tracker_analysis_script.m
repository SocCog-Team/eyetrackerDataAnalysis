% PC
%base_dir = fullfile('Z:', 'taskcontroller');
base_dir = fullfile('Y:');
filename = fullfile(base_dir, 'Projekts', 'Primatar', 'PrimatarData', 'Session_on_20190221VW_21-2--16-11', 'TrackerLog--EyeLink--2019-21-02--16-11.txt.Fixed.txt');
%filename = fullfile(base_dir, 'Projekts', 'Primatar', 'PrimatarData', 'Session_on_27-11--11-59', 'TrackerLog--EyeLink--2018-27-11--11-59.txt.Fixed.txt');
%filename = fullfile(base_dir, 'Projekts', 'Primatar', 'PrimatarData', 'Session_on_27-11--12-03', 'TrackerLog--EyeLink--2018-27-11--12-03.txt.Fixed.txt');

%filename = fullfile(base_dir, 'Projekts', 'Primatar', 'PrimatarData', 'Session_on_30-8--14-22', 'TrackerLog--EyeLink--2018-30-08--14-23.txt.Fixed.txt');
%filename = fullfile(base_dir, 'Projekts', 'Primatar', 'PrimatarData', 'Session_on_03-9--09-47', 'TrackerLog--EyeLink--2018-03-09--09-47.txt.Fixed.txt');
%filename = fullfile(base_dir, 'Projekts', 'Primatar', 'PrimatarData', 'Session_on_06-9--14-47', 'TrackerLog--EyeLink--2018-06-09--14-47.txt.Fixed.txt');

%filename = fullfile(base_dir, 'Projekts', 'Primatar', 'PrimatarData', 'Session_on_02-8--11-23', 'TrackerLog--EyeLink--2018-02-08--11-23.txt.Fixed.AU.txt');
%mac
%base_dir = fullfile('/Volumes', 'social_neuroscience_data', 'taskcontroller');

%filename = fullfile(base_dir, 'SCP-CTRL-01', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', 'PrimatarData', 'Session_on_07-11--15-27', 'TrackerLog--EyeLink--2017-07-11--15-27_fixed.txt');
%filename = fullfile(base_dir, 'SCP-CTRL-01', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', 'PrimatarData', 'Session_on_09-11--10-51', 'TrackerLog--EyeLink--2017-09-11--10-51.fixed.txt');


 


[data_dir, logfile_name] = fileparts(filename);

out_dir = fullfile(data_dir, 'ANALYSIS');


screenWidth = 1280;
screenHeight = 1024;
screenRect = [0, 0, screenWidth, screenHeight];          

fixPointX = 960;
fixPointY = 348;
fixPointSize = 204;
fixPointRect = [fixPointX - fixPointSize/2, fixPointY - fixPointSize/2, fixPointSize, fixPointSize];
           
%imageWidth = 300;
%imageHeight = 300;
imageWidth = 300*17/20;
imageHeight = 300;
imageLeft = fixPointX - imageWidth/2;
imageTop = fixPointY - imageHeight/2;
imageRect = [imageLeft, imageTop, imageWidth, imageHeight];             

stimulImage = {fullfile(base_dir, 'Projekts', 'Primatar', 'images', 'affiliatve_crop_BlockSized_Horz17_Vert20.png'), ...
               fullfile(base_dir, 'Projekts', 'Primatar', 'images', 'fear_crop_BlockSized_Horz17_Vert20.png'), ...
               fullfile(base_dir, 'Projekts', 'Primatar', 'images', 'neutral_crop_BlockSized_Horz17_Vert20.png'), ...
               fullfile(base_dir, 'Projekts', 'Primatar', 'images', 'threat_crop_BlockSized_Horz17_Vert20.png')};

stimulName = {'Affiliative', 'Fear', 'Neutral', 'Threat'};          
nStimul = length(stimulName);            
             
%eyes in image coordinate system
eyesRect = [80, 100, 125, 40; ...
            75, 83,  125, 40; ...
            77, 95,  125, 40; ...
            83, 80,  125, 40];  
%eyes in screen coordinate system         
eyesRect(:, 1) = eyesRect(:, 1) + imageLeft;     
eyesRect(:, 2) = eyesRect(:, 2) + imageTop;

%mouth in image coordinate system
mouthRect = [75, 205, 115, 80; ...
             76, 180, 115, 80; ...
             75, 195, 115, 80; ...
             80, 195, 115, 80];  
%mouth in screen coordinate system         
mouthRect(:, 1) = mouthRect(:, 1) + imageLeft;     
mouthRect(:, 2) = mouthRect(:, 2) + imageTop;

pValue = 0.05;

fixationDetector = struct('method', 'dispersion-based', ...
                          'dispersionThreshold', 30, ...
                          'durationThreshold', 100); %120
[dataTable, trialStruct, trial] = read_primatar_data_from_file(filename, true);                        


%% analyse trials  grouped by original image      
% plot gaze results for fixation    
analyse_initial_fixation(trial, fixationDetector, screenRect, fixPointRect);

% plot gaze results for stimuli
[stimulStat, scrambledStat] = analyse_stimul_fixation(trial, stimulName, pValue, stimulImage, fixationDetector, ...
                                                  screenRect, imageRect, eyesRect, mouthRect);
% final statistic
show_fixation_report(stimulName, stimulStat, scrambledStat);


%% analyse trials grouped by presented image        
specStimulName = {'Real face 1 - Normal', 'Real face 2 - Normal', 'Real face 3 - Normal', ... 
                  'Realistic avatar - Normal', 'Unrealistic avatar - Normal',  ... 
                  'Real face 1 - Moderate obfuscation', 'Real face 2 - Moderate obfuscation', 'Real face 3 - Moderate obfuscation', ... 
                  'Realistic avatar - Moderate obfuscation', 'Unrealistic avatar  - Moderate obfuscation', ...
                  'Real face 1 - Strong obfuscation', 'Real face 2 - Strong obfuscation',  'Real face 3 - Strong obfuscation', ...
                  'Realistic avatar  - Strong obfuscation', 'Unrealistic avatar  - Strong obfuscation'};          
specEyesRect = [eyesRect; eyesRect; eyesRect];
specMouthRect = [mouthRect; mouthRect; mouthRect];
specStimulImage = [stimulImage, stimulImage, stimulImage];

% plot gaze results for stimuli
[specStimulStat, specScrambledStat] = analyse_stimul_fixation(trial, specStimulName, pValue, specStimulImage, fixationDetector, ...
                                                  screenRect, imageRect, specEyesRect, specMouthRect);
% final statistic
show_fixation_report(specStimulName, specStimulStat, specScrambledStat);

%% stats for different obfuscation levels
totalObfuscTime = sum(reshape( arrayfun(@(x) sum(x.timeTotal), specStimulStat), 5, []));
totalObfuscNumFix = sum(reshape( arrayfun(@(x) sum(x.numFixTotal), specStimulStat), 5, []));

regionName = {'ROI', 'Eyes', 'Mouth', 'Face' };
for iRegion = 1:4
  region = regionName{iRegion};
  nObfuscLevel = 3;
  obfuscTime = cell(3, 1);
  obfuscFix = cell(3, 1);
  for iLevel = 1:nObfuscLevel
    levelIndex = (5*iLevel - 4):5*iLevel;
    obfuscTime{iLevel} = vertcat(specStimulStat(levelIndex).(['timeOn' region]));
    obfuscFix{iLevel} = vertcat(specStimulStat(levelIndex).(['numFixOn' region]));

    normalizedTime = obfuscTime{iLevel}/mean(vertcat(specStimulStat(levelIndex).timeTotal));
    totalObfusc.(['confIntTime' region])(iLevel) = calc_cihw(std(normalizedTime), length(normalizedTime), pValue);    
    normalizedFixNum = obfuscFix{iLevel}/mean(vertcat(specStimulStat(levelIndex).numFixTotal));  
    totalObfusc.(['confIntFix' region])(iLevel) = calc_cihw(std(normalizedFixNum), length(normalizedFixNum), pValue);
  end

  totalObfusc.(['ShareTime' region]) = cellfun(@sum, obfuscTime)'./totalObfuscTime;
  totalObfusc.(['ShareFix' region]) = cellfun(@sum, obfuscFix)'./totalObfuscNumFix;
end

FontSize = 12;
regionLabel = {'to ROI', 'to face', 'to eyes', 'to mouth'};
stimulName = {'normal', 'medium', 'strong'};
maxValue = 0.7;

figure('Name', 'Total shares of fixations (per obfucation level)');
set( axes,'fontsize', FontSize, 'FontName', 'Times');
  
subplot(2, 1, 1);
barData = [totalObfusc.ShareFixROI; totalObfusc.ShareFixFace; totalObfusc.ShareFixEyes; totalObfusc.ShareFixMouth];
confInt = [totalObfusc.confIntFixROI; totalObfusc.confIntFixFace; totalObfusc.confIntFixEyes; totalObfusc.confIntFixMouth];
draw_error_bar(barData, confInt, stimulName, regionLabel, FontSize, maxValue)
title('proportions of fixation number (stimuli)', 'fontsize', FontSize, 'FontName','Times', 'Interpreter', 'latex');
  
subplot(2, 1, 2);
barData = [totalObfusc.ShareTimeROI; totalObfusc.ShareTimeFace; totalObfusc.ShareTimeEyes; totalObfusc.ShareTimeMouth];
confInt = [totalObfusc.confIntTimeROI; totalObfusc.confIntTimeFace; totalObfusc.confIntTimeEyes; totalObfusc.confIntTimeMouth];
draw_error_bar(barData, confInt, stimulName, regionLabel, FontSize, maxValue)
title('proportions of fixation duration (stimuli)', 'fontsize', FontSize, 'FontName','Times', 'Interpreter', 'latex');

set( gcf, 'PaperUnits','centimeters' );
xSize = 28; ySize = 28;
xLeft = 0; yTop = 0;
set( gcf,'PaperPosition', [ xLeft yTop xSize ySize ] );
print ( '-depsc', '-r300', 'obfuscationEffect.eps');
  
%% analyse for normal stimuli only       
normStimulName = {'Real face 1 - Normal', 'Real face 2 - Normal', 'Real face 3 - Normal', ... 
                  'Realistic avatar - Normal', 'Unrealistic avatar - Normal'};          

% plot gaze results for stimuli
[normStimulStat, normScrambledStat] = analyse_stimul_fixation(trial, normStimulName, pValue, ...
                                        stimulImage, fixationDetector, screenRect, imageRect, eyesRect, mouthRect);
% final statistic
show_fixation_report(normStimulName, normStimulStat, normScrambledStat);



%set( gca, 'XTickLabel', [1, 2, 3, 4, 7, 8, 9], 'fontsize', FontSize, 'FontName', 'Times');
%xlabel( {' Number of experiment '; ' '; '(a)'}, 'fontsize', FontSize, 'FontName', 'Times');
%xlabel( ' Experimental session ', 'fontsize', FontSize, 'FontName', 'Times');
%ylabel( ' Mean Average Error ', 'fontsize', FontSize, 'FontName', 'Times');

%[x, y] = get_gaze_pos(trial, 'fix1', 0, 0);

  %{
  trial = struct('fix1Start', {fix1Start}, ...
                 'fix1End', {fix1End}, ...
                 'fix2Start', {fix2Start}, ...
                 'fix2End', {fix2End}, ...
                 'stimulStart', {stimulStart}, ...
                 'stimulEnd', {stimulEnd}, ...
                 'scrambledStart', {scrambledStart}, ...
                 'scrambledEnd', {scrambledEnd}, ...                 
                 'type', {dataTable.UserField(fix1Start)});
  %}
  %[allStates, ~, stateIndex]  = unique(ds.CurrentEvent);
  %[allStimuli, ~, stimuliIndices] = unique(ds.UserField);

%{
idx = dataTable.CurrentEvent == 'Top event>Fix 1';
x = dataTable.GazeX(idx);
y = dataTable.GazeY(idx);


figure
h = histogram2(x,y, [100, 100],'DisplayStyle','tile','ShowEmptyBins','on');
%}  