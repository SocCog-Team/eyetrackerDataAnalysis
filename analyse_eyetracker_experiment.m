function [stimulStat, scrambledStat, stimulName] = analyse_eyetracker_experiment(filename, ...
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
       stimulImageForAnalysis = stimulImage;
    else % ignore stimuli and compare obfuscation levels only
        % analyse trials grouped by presented image (taking obfuscatio into account)       
        stimulName = {'Real face 1 - Normal', 'Real face 2 - Normal', 'Real face 3 - Normal', ... 
                      'Realistic avatar - Normal', 'Unrealistic avatar - Normal',  ... 
                      'Real face 1 - Moderate obfuscation', 'Real face 2 - Moderate obfuscation', 'Real face 3 - Moderate obfuscation', ... 
                      'Realistic avatar - Moderate obfuscation', 'Unrealistic avatar  - Moderate obfuscation', ...
                      'Real face 1 - Strong obfuscation', 'Real face 2 - Strong obfuscation',  'Real face 3 - Strong obfuscation', ...
                      'Realistic avatar  - Strong obfuscation', 'Unrealistic avatar  - Strong obfuscation'};          
        stimulImageForAnalysis = [stimulImage, stimulImage, stimulImage];
        eyesRect = [eyesRect; eyesRect; eyesRect];
        mouthRect = [mouthRect; mouthRect; mouthRect];
    end   
    pValue = 0.05;
    [stimulStat, scrambledStat] = analyse_stimul_fixation(trial, stimulName, ...
        pValue, stimulImageForAnalysis, fixationDetector, screenRect, imageRect, eyesRect, mouthRect, plotSetting, sessionName);

    
    % -------------- plot final statistics --------------
    if (plotSetting.summary)
        if (nObfuscationLevelToConsider == 1) || (nObfuscationLevelToConsider == 2)  || (nObfuscationLevelToConsider == 3)
            % plot overall figures (time cources of fixation proportions and average fixation proportions)
            display_fixation_proportions(sessionName, stimulName, stimulStat, scrambledStat);
        else % plot stats for different obfuscation levels
            obfuscLevelName = {'normal', 'medium', 'strong'};
			stimulStat = computeStatitisticForEachObfuscationLevel(stimulStat, stimulImage, obfuscLevelName, pValue);
			scrambledStat = computeStatitisticForEachObfuscationLevel(scrambledStat, stimulImage, obfuscLevelName, pValue);
            plotObfuscationStatitistic(stimulStat, sessionName, obfuscLevelName, plotSetting.fontSize, plotSetting.fontName);
        end    
    end
end


function totalObfusc = computeStatitisticForEachObfuscationLevel(stimulStat, stimulImage, obfuscLevelName, pValue)    
    nDistinctStimul = length(stimulImage);
    totalObfuscTime = sum(reshape( arrayfun(@(x) sum(x.timeTotal), stimulStat), nDistinctStimul, []));
    totalObfuscNumFix = sum(reshape( arrayfun(@(x) sum(x.numFixTotal), stimulStat), nDistinctStimul, []));   

    specStimulStat = stimulStat;
        
    nObfuscLevel = length(obfuscLevelName);    
    obfuscTime = cell(nObfuscLevel, 1);
    obfuscFix = cell(nObfuscLevel, 1);
    obfuscIsFirstFix = cell(nObfuscLevel, 1);
    
    regionName = {'Face', 'Eyes', 'Mouth'};
    nRegion = length(regionName);
    
    for iLevel = 1:nObfuscLevel
        levelIndex = (nDistinctStimul*(iLevel - 1) + 1):(nDistinctStimul*iLevel);

        totalObfusc(iLevel).timeTotal  = vertcat(specStimulStat(levelIndex).timeTotal);
    	totalObfusc(iLevel).numFixTotal = vertcat(specStimulStat(levelIndex).numFixTotal);
        totalObfusc(iLevel).trialIndex = vertcat(specStimulStat(levelIndex).trialIndex); 
        
        for iRegion = 1:nRegion
            region = regionName{iRegion};

            obfuscTime{iLevel} = vertcat(specStimulStat(levelIndex).(['timeOn' region]));
            obfuscFix{iLevel} = vertcat(specStimulStat(levelIndex).(['numFixOn' region]));
            obfuscIsFirstFix{iLevel} = vertcat(specStimulStat(levelIndex).(['isFirstFixOn' region]));
            
            totalObfusc(iLevel).(['timeOn' region]) = obfuscTime{iLevel};
            totalObfusc(iLevel).(['numFixOn' region]) = obfuscFix{iLevel};
            totalObfusc(iLevel).(['isFirstFixOn' region]) = obfuscIsFirstFix{iLevel};
            
            totalObfusc(iLevel).(['shareTimeOn' region]) = sum(obfuscTime{iLevel})/totalObfuscTime(iLevel);
            totalObfusc(iLevel).(['shareFixOn' region]) = sum(obfuscFix{iLevel})/totalObfuscNumFix(iLevel);

            normalizedTime = obfuscTime{iLevel}/mean(vertcat(specStimulStat(levelIndex).timeTotal));
            totalObfusc(iLevel).(['confIntTimeOn' region]) = calc_cihw(std(normalizedTime), length(normalizedTime), pValue);
            normalizedFixNum = obfuscFix{iLevel}/mean(vertcat(specStimulStat(levelIndex).numFixTotal));
            totalObfusc(iLevel).(['confIntFixOn' region]) = calc_cihw(std(normalizedFixNum), length(normalizedFixNum), pValue);
            
            % compute frequency of first fixation in the region
            totalObfusc(iLevel).(['freqFirstFixOn' region]) = mean(totalObfusc(iLevel).(['isFirstFixOn' region]));    
            
            % compute overall shares of duration and number of fixation in the region
            totalObfusc(iLevel).(['totalShareTimeOn' region]) = sum(totalObfusc(iLevel).(['timeOn' region]))/sum(totalObfusc(iLevel).timeTotal);
            totalObfusc(iLevel).(['totalShareFixOn' region]) = sum(totalObfusc(iLevel).(['numFixOn' region]))/sum(totalObfusc(iLevel).numFixTotal);
        end
    end
end
    
function plotObfuscationStatitistic(totalObfusc, sessionName, obfuscLevelName, fontSize, fontName)      
    plotTitle = {'proportions of fixation number (stimuli)', 'proportions of fixation duration (stimuli)'};
    regionName = {'to face', 'to eyes', 'to mouth'};
    nRegion = length(regionName);

    figure('Name', 'Total shares of fixations (per obfucation level)');
	[output_rect] = fnFormatPaperSize('Plos_half_page', gcf, 1/2.54);
	set(gcf(), 'Units', 'centimeters', 'Position', output_rect, 'PaperPosition', output_rect);
	
    set( axes,'fontsize', fontSize, 'FontName', fontName);
    for iPlot = 1:2
        subplot(2, 1, iPlot);
        if (iPlot == 1)
            barData = [totalObfusc.shareFixOnFace; totalObfusc.shareFixOnEyes; totalObfusc.shareFixOnMouth];
            confInt = [totalObfusc.confIntFixOnFace; totalObfusc.confIntFixOnEyes; totalObfusc.confIntFixOnMouth];
        else
            barData = [totalObfusc.shareTimeOnFace; totalObfusc.shareTimeOnEyes; totalObfusc.shareTimeOnMouth];
            confInt = [totalObfusc.confIntTimeOnFace; totalObfusc.confIntTimeOnEyes; totalObfusc.confIntTimeOnMouth];
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

%     set( gcf, 'PaperUnits','centimeters' );
%     xSize = 28; ySize = 28;
%     xLeft = 0; yTop = 0;
%     set( gcf,'PaperPosition', [ xLeft yTop xSize ySize ] );
    %print( '-depsc', '-r300', fullfile(sessionName, 'obfuscationEffect.eps'));
	write_out_figure(gcf(), fullfile(sessionName, 'obfuscationEffect.pdf'));
	
end
 