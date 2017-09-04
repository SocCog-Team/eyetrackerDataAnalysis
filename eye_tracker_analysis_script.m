filename = 'Z:\taskcontroller\DAG-3\PrimatarData\Cornelius_20170714_1250\TrackerLog--ArringtonTracker--2017-14-07--12-50.txt';

screenWidth = 1280;
screenHeight = 1024;
screenRect = [0, 0, screenWidth, screenHeight];          

fixPointX = 960;
fixPointY = 348;
fixPointSize = 204;
fixPointRect = [fixPointX - fixPointSize/2, fixPointY - fixPointSize/2, fixPointSize, fixPointSize];
           
imageWidth = 400;
imageHeight = 400;
imageLeft = fixPointX - imageWidth/2;
imageTop = fixPointY - imageHeight/2;
imageRect = [imageLeft, imageTop, imageWidth, imageHeight];             

stimulImage = {'Z:\taskcontroller\Stimuli\Primatar\20170714\face1.png', ...
               'Z:\taskcontroller\Stimuli\Primatar\20170714\face2.png', ...
               'Z:\taskcontroller\Stimuli\Primatar\20170714\face3.png', ...
               'Z:\taskcontroller\Stimuli\Primatar\20170714\RealistcAvatar.png', ...
               'Z:\taskcontroller\Stimuli\Primatar\20170714\UnrealisticAvatar.png'};

stimulName = {'Real face 1', 'Real face 2', 'Real face 3', 'Realistic avatar', 'Unrealistic avatar'};          
nStimul = length(stimulName);            
             
%eyes in image coordinate system
eyesRect = [95, 70, 190, 70; ...
           75, 67, 215, 70; ...
           90, 65, 190, 85; ...
           85, 65, 200, 70; ...
           90, 65, 190, 70];  
%eyes in screen coordinate system         
eyesRect(:, 1) = eyesRect(:, 1) + imageLeft;     
eyesRect(:, 2) = eyesRect(:, 2) + imageTop;

%mouth in image coordinate system
mouthRect = [115, 280, 150, 50; ...
           85, 260, 150, 50; ...
           100, 275, 130, 60; ...
           70, 285, 190, 70; ...
           65, 290, 200, 60];  
%mouth in screen coordinate system         
mouthRect(:, 1) = mouthRect(:, 1) + imageLeft;     
mouthRect(:, 2) = mouthRect(:, 2) + imageTop;

pValue = 0.05;

fixationDetector = struct('method', 'dispersion-based', ...
                          'dispersionThreshold', 30, ...
                          'durationThreshold', 120);

%% parse file for trials  grouped by original image                                               
[trial, dataTable, trialStruct] = parse_eye_tracker_file(filename, stimulName, true);  

%% analyse trials  grouped by original image      
% plot gaze results for fixation    
analyse_initial_fixation(trial, fixationDetector, screenRect, fixPointRect);

% plot gaze results for stimuli
[stimulStat, scrambledStat] = analyse_stimul_fixation(trial, trialStruct, pValue, stimulImage, fixationDetector, ...
                                                  screenRect, imageRect, eyesRect, mouthRect);
% final statistic
show_fixation_report(stimulName, stimulStat, scrambledStat);


%% parse file for grouped by presented image       
specStimulName = {'Real face 1 - Normal 0', 'Real face 2 - Normal 0', 'Real face 3 - Normal 0', ... 
                  'Realistic avatar - Normal 1', 'Unrealistic avatar - Normal 2',  ... 
                  'Real face 1 - Moderate obfuscation  3', 'Real face 2 - Moderate obfuscation  3', 'Real face 3 - Moderate obfuscation  3', ... 
                  'Realistic avatar - Moderate obfuscation  4', 'Unrealistic avatar  - Moderate obfuscation  5', ...
                  'Real face 1 - Strong obfuscation  6', 'Real face 2 - Strong obfuscation  6',  'Real face 3 - Strong obfuscation  6', ...
                  'Realistic avatar  - Strong obfuscation  7', 'Unrealistic avatar  - Strong obfuscation  8'};          
specEyesRect = [eyesRect; eyesRect; eyesRect];
specMouthRect = [mouthRect; mouthRect; mouthRect];
specStimulImage = [stimulImage, stimulImage, stimulImage];
[specTrial, ~, specTrialStruct] = parse_eye_tracker_file(filename, specStimulName, true);  

%% analyse trials grouped by presented image  
% plot gaze results for stimuli
[specStimulStat, specScrambledStat] = analyse_stimul_fixation(specTrial, specTrialStruct, pValue, specStimulImage, fixationDetector, ...
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
  
%% parse file for normal stimuli only       
normStimulName = {'Real face 1 - Normal 0', 'Real face 2 - Normal 0', 'Real face 3 - Normal 0', ... 
                  'Realistic avatar - Normal 1', 'Unrealistic avatar - Normal 2'};          
[normTrial, ~, normTrialStruct] = parse_eye_tracker_file(filename, normStimulName, true);  

%% analyse for normal stimuli only       
% plot gaze results for stimuli
[normStimulStat, normScrambledStat] = analyse_stimul_fixation(normTrial, normTrialStruct, pValue, ...
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