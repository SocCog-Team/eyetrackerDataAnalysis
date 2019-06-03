function [stimulStat, scrambledStat] = analyse_eyetracker_experiment(filename, ...
    sessionName, dyadicPlatformImageTransform, nObfuscationLevelToConsider, ...
    stimulImage, eyesImageRect, mouthImageRect, plotSetting)         

    mkdir(sessionName);
    %-------------- set experiment parameters --------------
    screenWidth = 1280;
    screenHeight = 1024;
    screenRect = [0, 0, screenWidth, screenHeight];          
           
    if dyadicPlatformImageTransform
        fixPointX = 960; %fixation point coord
        fixPointY = 450;
        scalingCoeff = 300/383;   %scaling coefficient for image presentaion
        horizResizeCoeff = 17/20; %additional scaling for dyadic platform
        imageHeight = 300;
        imageWidth = imageHeight*horizResizeCoeff;
    else    
        fixPointX = 960; %fixation point coord
        fixPointY = 348;    
        horizResizeCoeff = 1;
        scalingCoeff = 400/383;
        imageWidth = 400;
        imageHeight = 400;
    end
    fixPointSize = 204;
    fixPointRect = [fixPointX - fixPointSize/2, fixPointY - fixPointSize/2, fixPointSize, fixPointSize];

    imageLeft = fixPointX - imageWidth/2;
    imageTop = fixPointY - imageHeight/2;
    imageRect = [imageLeft, imageTop, imageWidth, imageHeight];             

    % eyes in screen coordinate system         
    eyesRect = eyesImageRect*scalingCoeff; 
    eyesRect(:, 1) = horizResizeCoeff*eyesRect(:, 1) + imageLeft;     
    eyesRect(:, 2) = eyesRect(:, 2) + imageTop;

    % mouth in screen coordinate system
    mouthRect = mouthImageRect*scalingCoeff;            
    mouthRect(:, 1) = horizResizeCoeff*mouthRect(:, 1) + imageLeft;     
    mouthRect(:, 2) = mouthRect(:, 2) + imageTop;
    
    %--------------- perform gase analysis --------------
    % specify the algorithm for fixation detection 
    fixationDetector = struct('method', 'dispersion-based', ...
                              'dispersionThreshold', 30, ...
                              'durationThreshold', 100); %120


                     
    % read data from eyetracker log file                      
    [~, ~, trial] = read_primatar_data_from_file(filename, true);                        
    if (nObfuscationLevelToConsider == 1) || (nObfuscationLevelToConsider == 2)
        % analyse trials for normally or moderate obfuscated stimuli
        trial = remove_trials(trial, 'Strong obfuscation');
        if (nObfuscationLevelToConsider == 1)
            % analyse trials for normally obfuscated stimuli only   
            trial = remove_trials(trial, 'Moderate obfuscation');
        end
    end    
    
    % plot gaze for fixation  
    if (plotSetting.initialFix)
        analyse_initial_fixation(trial, fixationDetector, screenRect, fixPointRect);
    end
    
    % analyse gaze for stimuli
    if (nObfuscationLevelToConsider == 1) || (nObfuscationLevelToConsider == 2)  || (nObfuscationLevelToConsider == 3)
       stimulName = {'Real face 1', 'Real face 2', 'Real face 3', 'Realistic avatar', 'Unrealistic avatar'};          

    else % ignore stimuli and compare obfuscation levels only
        % analyse trials grouped by presented image (taking obfuscatio into account)       
        stimulName = {'Real face 1 - Normal', 'Real face 2 - Normal', 'Real face 3 - Normal', ... 
                      'Realistic avatar - Normal', 'Unrealistic avatar - Normal',  ... 
                      'Real face 1 - Moderate obfuscation', 'Real face 2 - Moderate obfuscation', 'Real face 3 - Moderate obfuscation', ... 
                      'Realistic avatar - Moderate obfuscation', 'Unrealistic avatar  - Moderate obfuscation', ...
                      'Real face 1 - Strong obfuscation', 'Real face 2 - Strong obfuscation',  'Real face 3 - Strong obfuscation', ...
                      'Realistic avatar  - Strong obfuscation', 'Unrealistic avatar  - Strong obfuscation'};          
        stimulImage = [stimulImage, stimulImage, stimulImage];
        eyesRect = [eyesRect; eyesRect; eyesRect];
        mouthRect = [mouthRect; mouthRect; mouthRect];
    end   
    pValue = 0.05;
    [stimulStat, scrambledStat] = analyse_stimul_fixation(trial, stimulName, ...
        pValue, stimulImage, fixationDetector, screenRect, imageRect, eyesRect, mouthRect, plotSetting, sessionName);

    
    % -------------- plot final statistics --------------
    if (plotSetting.summary)
        if (nObfuscationLevelToConsider == 1) || (nObfuscationLevelToConsider == 2)  || (nObfuscationLevelToConsider == 3)
            % plot overall figures (time cources of fixation proportions and average fixation proportions)
            display_fixation_proportions(sessionName, stimulName, stimulStat, scrambledStat);
        else % plot stats for different obfuscation levels
            %plotObfuscationStatitistic(stimulStat, stimulImage, sessionName, pValue)
        end    
    end
end
    
function plotObfuscationStatitistic(stimulStat, stimulImage, sessionName, pValue)
    nDistinctStimul = length(stimulImage);
    totalObfuscTime = sum(reshape( arrayfun(@(x) sum(x.timeTotal), stimulStat), nDistinctStimul, []));
    totalObfuscNumFix = sum(reshape( arrayfun(@(x) sum(x.numFixTotal), stimulStat), nDistinctStimul, []));

    specStimulStat = stimulStat;
    
    obfuscLevelName = {'normal', 'medium', 'strong'};
    nObfuscLevel = length(obfuscLevelName);
    regionName = {'Face', 'Eyes', 'Mouth'};
    nRegion = length(regionName);
    for iRegion = 1:nRegion
        region = regionName{iRegion};
        obfuscTime = cell(nObfuscLevel, 1);
        obfuscFix = cell(nObfuscLevel, 1);
        for iLevel = 1:nObfuscLevel
            levelIndex = (nDistinctStimul*(iLevel - 1) + 1):(nDistinctStimul*iLevel);
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
    fontName = 'Arial';
    plotTitle = {'proportions of fixation number (stimuli)', 'proportions of fixation duration (stimuli)'};
    regionName = {'to face', 'to eyes', 'to mouth'};
    nRegion = length(regionName);

    figure('Name', 'Total shares of fixations (per obfucation level)');
    set( axes,'fontsize', FontSize, 'FontName', fontName);
    for iPlot = 1:2
        subplot(2, 1, iPlot);
        if (iPlot == 1)
            barData = [totalObfusc.ShareFixFace; totalObfusc.ShareFixEyes; totalObfusc.ShareFixMouth];
            confInt = [totalObfusc.confIntFixFace; totalObfusc.confIntFixEyes; totalObfusc.confIntFixMouth];
        else
            barData = [totalObfusc.ShareTimeFace; totalObfusc.ShareTimeEyes; totalObfusc.ShareTimeMouth];
            confInt = [totalObfusc.confIntTimeFace; totalObfusc.confIntTimeEyes; totalObfusc.confIntTimeMouth];
        end
        barHandle = draw_error_bar(barData, confInt);    
        legend_handleMain = legend(barHandle, obfuscLevelName, 'location', 'NorthEast'); 
        set(legend_handleMain, 'fontsize', fontSize-1, 'FontName', fontName);%, 'FontName','Times', 'Interpreter', 'latex');
        pos = get(legend_handleMain, 'Position');
        set(legend_handleMain, 'Position', [pos(1) + 0.1, pos(2) + 0.07, pos(3:4)]);
        legend boxoff 
        axis([0.5, nRegion + 0.5, 0, 0.8]);
        set( gca, 'XTick', 1:nRegion, 'XTickLabel', regionName, 'YTick', 0:0.2:1, 'fontsize', fontSize, 'FontName',fontName);  
        title(plotTitle(iPlot), 'fontSize', fontSize, 'FontName',fontName);
    end

    set( gcf, 'PaperUnits','centimeters' );
    xSize = 28; ySize = 28;
    xLeft = 0; yTop = 0;
    set( gcf,'PaperPosition', [ xLeft yTop xSize ySize ] );
    print ( '-depsc', '-r300', fullfile(sessionName, 'obfuscationEffect.eps'));
    end
 