function [stimulStat, scrambledStat] = analyse_stimul_fixation(trial, ...
            stimulCaption, pValue, stimulImage, fixationDetector, ...
            screenRect, imageRect, eyesRect, mouthRect, plotSetting, sessionName)
% analyses raw gazes and fixations during presentations of stimuli images and scrambled images
% makes the plots and computes statistics
			

imageWidth = imageRect(3);
imageHeight = imageRect(4);
nStimul = length(stimulCaption);

stimulFix = cell(1, nStimul);
scrambledFix = cell(1, nStimul);
scaledImage = cell(1, nStimul);
for iStimul = 1:nStimul % for every stimulus
    % read and scale image
    originalImage = imread(stimulImage{iStimul});
    scaledImage{iStimul} = imresize(originalImage,[imageHeight imageWidth]);

    % compute gaze positions for the stimul
    [stimulFix{iStimul}, stimulRaw, trialIndices] = get_gaze_pos(trial, 'stimulus', stimulCaption{iStimul}, fixationDetector);
    stimulFix{iStimul} = bound_gaze_pos(stimulFix{iStimul}, screenRect);
    stimulRaw = bound_gaze_pos(stimulRaw, screenRect);    
    stimulStat(iStimul) = compute_fixation_statistic(stimulFix{iStimul}, pValue, screenRect, ...
        imageRect, eyesRect(iStimul, :), mouthRect(iStimul, :));
    stimulStat(iStimul).trialIndex = trialIndices';    
    
    % generate titles for figures
    trialIndicesAsStr = arrayfun(@num2str, trialIndices, 'UniformOutput', false);
    trialCaption = cell(2, length(stimulFix{iStimul}));
    trialCaption(1,:) = strcat('Trial', {' '}, trialIndicesAsStr);
    trialCaption(2,:) = {trial(trialIndices).caption};
    trialCaption(2,:) = strrep(trialCaption(2,:), 'obfuscation', 'obf.');
        
    % plot fixations   
    if (plotSetting.perTrialAttentionMap)
        drawAllAttentionMapsPerStimul(stimulCaption{iStimul}, fixationDetector, stimulFix{iStimul}, stimulRaw, scaledImage{iStimul}, imageRect, eyesRect(iStimul, :), mouthRect(iStimul, :), trialCaption, sessionName, plotSetting.fontSize, plotSetting.fontName);
    end    
    if (plotSetting.rawFix)
        drawRawFixationPerStimul(stimulCaption{iStimul}, stimulRaw, scaledImage{iStimul}, imageRect, eyesRect(iStimul, :), mouthRect(iStimul, :), trialCaption, sessionName, plotSetting.fontSize, plotSetting.fontName);
    end
    
    % compute gaze positions for the scrambled    
    [scrambledFix{iStimul}, ~, trialIndices] = get_gaze_pos(trial, 'scrambled', stimulCaption{iStimul}, fixationDetector);
    scrambledFix{iStimul} = bound_gaze_pos(scrambledFix{iStimul}, screenRect);
    scrambledStat(iStimul) = compute_fixation_statistic(scrambledFix{iStimul}, pValue, screenRect, ...
        imageRect, eyesRect(iStimul, :), mouthRect(iStimul, :));
    scrambledStat(iStimul).trialIndex = trialIndices';
end

% plot average attention maps per stimuli
if (plotSetting.averageAttentionMap)
    nTrialToShow = plotSetting.nTrial;
    drawAverageAttentionMapAllStimuli(stimulCaption, fixationDetector, stimulFix, scaledImage, imageRect, eyesRect, mouthRect, nTrialToShow, sessionName, 'AverageStimuliAttentionMap', plotSetting.fontSize, plotSetting.fontName);      
%    scrambledTitle
    drawAverageAttentionMapAllStimuli(stimulCaption, fixationDetector, scrambledFix, scaledImage, imageRect, eyesRect, mouthRect, nTrialToShow, sessionName, 'AverageScrambledAttentionMap', plotSetting.fontSize, plotSetting.fontName);      
end

%{
% Fisher test for number of fixations for various stimuli in each region
regionName = {'Face', 'Eyes', 'Mouth' };
nRegion = length(regionName);

figure('Name', 'Fisher exact test for N fixations')
set( axes,'fontSize', fontSize, 'FontName', 'Arial');
for iRegion = 1:nRegion
    region = regionName{iRegion};
    fixIn = vertcat(stimulStat(:).(['numFixOn' region]));
    fixOut = vertcat(stimulStat(:).numFixTotal) - fixIn;
    
    nTrial = length(fixIn);
    for iTrial = 1:nTrial
        contigencyMatrix(1, :) = [fixIn(iTrial), fixOut(iTrial)];
        for jTrial = 1:nTrial
            contigencyMatrix(2, :) = [fixIn(jTrial), fixOut(jTrial)];
            isAssociation.(region)(iTrial, jTrial) = 32*(fishertest(contigencyMatrix, 'Alpha',0.01) + ...
                fishertest(contigencyMatrix, 'Alpha',0.05));
        end
    end
    subplot(2, 2, iRegion);
    image(isAssociation.(region));
    colormap('winter');
    title(['Fixations to ', region], 'fontSize', fontSize, 'FontName','Arial');
end

% Kruskal-Wallis test for number of fixations for various stimuli in each region
p = cell(1, nRegion);
tbl = cell(1, nRegion);
stats = cell(1, nRegion);
for iRegion = 1:nRegion
    region = regionName{iRegion};
    shareFixationTime = vertcat(stimulStat(:).(['shareTimeOn' region]));
    stimulGroupSize = arrayfun(@(x) length(x.trialIndex), stimulStat);
    stimulName = cell(1, length(shareFixationTime));
    groupEnd = cumsum(stimulGroupSize);
    groupStart = 1 + [0 groupEnd(1:end-1)];
    for i = 1:length(stimulGroupSize)
        stimulName(groupStart(i):groupEnd(i)) = stimulCaption(i);
    end
    [p{iRegion}, tbl{iRegion}, stats{iRegion}] = kruskalwallis(shareFixationTime, stimulName);
end
%}
end


function drawAverageAttentionMapAllStimuli(stimulCaption, fixationDetector, stimulFix, scaledImage, imageRect, eyesRect, mouthRect, nTrialToShow, sessionName, figureName, fontSize, fontName)      
    % plot averaged heat maps
    nStimul = length(stimulCaption);    
    nCol = floor(sqrt(2*nStimul));
    nRow = ceil(nStimul/nCol);    
    plotHandle = gobjects(nStimul, 1);
    
    areaToShow = [imageRect(1), imageRect(1) + imageRect(3), imageRect(2), imageRect(2) + imageRect(4)];
    
    %all hit maps
    figure('Name', figureName);
    set( axes,'fontSize', fontSize, 'FontName', fontName);
    for iStimul = 1:nStimul
        if isempty(nTrialToShow)
            nTrial = length(stimulFix{iStimul});
        else
            nTrial = min([nTrialToShow, length(stimulFix{iStimul})]);
        end
        
        allX = [stimulFix{iStimul}(1:nTrial).x];
        allY = [stimulFix{iStimul}(1:nTrial).y];
        allT = [stimulFix{iStimul}(1:nTrial).t];
        titleText = strsplit(strrep(stimulCaption{iStimul}, 'obfuscation', 'obf.'), ' -');
                
        plotHandle(iStimul) = subplot(nRow, nCol, iStimul);
        set(gca, 'YDir', 'reverse','fontSize', fontSize, 'FontName', fontName);
        hold on
        gaussian_attention_map(allX, allY, fixationDetector.dispersionThreshold/2, ...
            allT, (nTrial/2)*fixationDetector.durationThreshold, scaledImage{iStimul}, imageRect);
        rectangle('Position',eyesRect(iStimul, :), 'EdgeColor','b');
        rectangle('Position',mouthRect(iStimul, :),'EdgeColor','b');        
        hold off
        set(gca, 'fontSize', fontSize - 4, 'FontName', fontName);
        box off;
        axis off;
        axis(areaToShow);
        title(titleText, 'fontSize', fontSize - 4, 'FontName', fontName);
    end
    tickLabel = fixationDetector.durationThreshold*[0.4 1 2 4 8]/2;
    tickValue = 0.75*log(1 + 4*tickLabel/fixationDetector.durationThreshold)/log(3);    
    colormap(parula(256))
    pos = get(plotHandle(nStimul), 'Position');
    %[pos(1)-0.1*pos(3)  pos(2)-0.05*pos(4)  0.1*pos(3) 0.95*pos(4)]
    h = colorbar('Position', [pos(1)+pos(3)+0.07 pos(2)+0.05*pos(4) 0.15*pos(3) 0.95*pos(4)], ...                             
        'Ticks', tickValue/2, ...
        'TickLabels', cellstr(num2str(tickLabel')),...
        'fontSize', fontSize, 'FontName', 'Arial');
    ylabel(h, 'mean fixation time [ms]', 'fontSize', fontSize, 'FontName', fontName);
    
    set( gcf,'PaperUnits','centimeters', 'PaperPosition', [ 0 0 29 21 ],'PaperOrientation','landscape' );    
    if (isempty(nTrialToShow)) || (nTrialToShow < max(cellfun(@length, stimulFix)))
        % if all trials were used for averaging - tell this in the name
        outputFilename = fullfile(sessionName, [figureName, '_average_all']);
    else
        % otherwise specify the mumber of trials actually used
        outputFilename = fullfile(sessionName, [figureName, '_average_first', num2str(nTrialToShow)]);                
    end
    print('-dpdf', outputFilename, '-r600');
end


function drawAllAttentionMapsPerStimul(stimulName, fixationDetector, stimulFix, stimulRaw, scaledImage, imageRect, eyesRect, mouthRect, trialCaption, sessionName, fontSize, fontName)      
    areaToShow = [imageRect(1), imageRect(1) + imageRect(3), imageRect(2), imageRect(2) + imageRect(4)];
    
    nTrial = length(stimulFix);
    nTrialCol = floor(sqrt(2*nTrial));
    nTrialRow = ceil(nTrial/nTrialCol);    
    %all hit maps
    figure('Name', [stimulName, ' - Gaussian attention maps'])
    set( axes,'fontsize', fontSize, 'FontName', fontName);
    for iTrial = 1:nTrial
        subplot(nTrialRow, nTrialCol, iTrial);
        set(gca, 'YDir', 'reverse','fontsize', fontSize, 'FontName', fontName);
        hold on;
        gaussian_attention_map(stimulFix(iTrial).x, stimulFix(iTrial).y, fixationDetector.dispersionThreshold/2, ...
            stimulFix(iTrial).t, fixationDetector.durationThreshold, scaledImage, imageRect);
        rectangle('Position',eyesRect, 'EdgeColor','b');
        rectangle('Position',mouthRect,'EdgeColor','b'); 
        line(stimulRaw(iTrial).x, stimulRaw(iTrial).y, 'Color', [0.6 0.4 0.9]);
        hold off;
        box off;
        axis off;
        axis(areaToShow);
        title(trialCaption(:, iTrial), 'fontsize', fontSize-4, 'FontName', fontName);
    end
    set( gcf,'PaperUnits','centimeters', 'PaperPosition', [ 0 0 29 21 ],'PaperOrientation','landscape' );
    outputFilename = stimulName;
    outputFilename(stimulName == ' ') = [];
    outputFilename = fullfile(sessionName, [outputFilename, '_rawAll.pdf']);
    print('-dpdf', outputFilename, '-r600');
end

function drawRawFixationPerStimul(stimulName, stimulRaw, scaledImage, imageRect, eyesRect, mouthRect, trialCaption, sessionName, fontSize, fontName)    
    [xRaw, yRaw, ~] = merge_trial_data(stimulRaw);
    
    areaToShow = [imageRect(1), imageRect(1) + imageRect(3), imageRect(2), imageRect(2) + imageRect(4)];
    imageLeft = imageRect(1);
    imageTop = imageRect(2);

    nTrial = length(stimulRaw);
    nTrialCol = floor(sqrt(2*nTrial));
    nTrialRow = ceil(nTrial/nTrialCol);  
    
    outputFilename = stimulName;
    outputFilename(stimulName == ' ') = [];
    
    figure('Name', [stimulName, ' - Raw gaze heat maps'])
    nHorizBin = ceil((max(xRaw) - min(xRaw) + 1)/8);
    nVertBin = ceil((max(yRaw) - min(yRaw) + 1)/8);

    for iTrial = 1:nTrial
        subplot(nTrialRow, nTrialCol, iTrial);
        set(gca, 'YDir', 'reverse','fontSize', fontSize, 'FontName', fontName);
        hold on;
        image(imageLeft, imageTop, scaledImage);
        rectangle('Position',eyesRect, 'EdgeColor','b');
        rectangle('Position',mouthRect,'EdgeColor','b');         
        if (~isempty(stimulRaw(iTrial).x))
            histogram2(stimulRaw(iTrial).x, stimulRaw(iTrial).y, [nHorizBin, nVertBin],'DisplayStyle','tile','ShowEmptyBins','off');
        end
        hold off;        
        axis(areaToShow);
        title(trialCaption(:, iTrial), 'fontSize', fontSize-4, 'FontName',fontName, 'Interpreter', 'latex');
    end
    set( gcf,'PaperUnits','centimeters', 'PaperPosition', [ 0 0 29 21 ],'PaperOrientation','landscape' );
    print('-dpdf', fullfile(sessionName, [outputFilename, '_raw.pdf']), '-r600');
    
    
    figure('Name', [stimulName, ' - raw gaze heat map over all presentations'])
    set( axes,'fontSize', fontSize, 'FontName', fontName);
    set(gca, 'YDir', 'reverse','fontSize', fontSize, 'FontName', fontName);
    hold on;
    image(imageLeft, imageTop, scaledImage);
    if (~isempty(xRaw))
        histogram2(xRaw,yRaw, [nHorizBin, nVertBin],'DisplayStyle','tile','ShowEmptyBins','off');
    end
    hold off;
    set( gcf,'PaperUnits','centimeters', 'PaperPosition', [ 0 0 29 21 ],'PaperOrientation','landscape' );    
    print('-dpdf', fullfile(sessionName, [outputFilename, '_rawAll.pdf']), '-r600');
end


