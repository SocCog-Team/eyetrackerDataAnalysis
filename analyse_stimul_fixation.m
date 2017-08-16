function [stimulStat, scrambledStat] = ...
    analyse_stimul_fixation(trial, trialStruct, stimulImage, fixationDetector, ...
                                                  screenRect, imageRect, eyesRect, mouthRect)
  FontSize = 6;                                                
  imageLeft = imageRect(1);
  imageTop = imageRect(2);
  imageWidth = imageRect(3);
  imageHeight = imageRect(4);
  nStimul = length(stimulImage);
  for iStimul = 1:nStimul 
    originalImage = imread(stimulImage{iStimul});
    scaledImage = imresize(originalImage,[imageHeight imageWidth]); 

%    [stimulFix, stimulRaw, trialIndices] = get_gaze_pos(trial, 'stimulus', iStimul, fixationDetector, true);
    [stimulFix, stimulRaw, trialIndices] = get_gaze_pos(trial, 'stimulus', iStimul, fixationDetector);
    stimulFix = bound_gaze_pos(stimulFix, screenRect);
    stimulRaw = bound_gaze_pos(stimulRaw, screenRect);
    trialIndicesAsStr = arrayfun(@num2str, trialIndices, 'UniformOutput', false);
    trialCaptionLine1 = strcat('Trial', {' '}, trialIndicesAsStr);
    trialCaptionLine2 = trialStruct.trialCaption(trialIndices)';
    trialCaptionLine2 = strrep(trialCaptionLine2, 'obfuscation ', 'obf.');

    stimulStat(iStimul) = compute_fixation_statistic(stimulFix, screenRect, ...
                                                    imageRect, eyesRect(iStimul, :), mouthRect(iStimul, :), scaledImage);
    stimulStat(iStimul).trialIndex = trialIndices;
    
    nTrial = length(stimulFix);                                              
    nTrialCol = floor(sqrt(2*nTrial));
    nTrialRow = ceil(nTrial/nTrialCol);      
      
    figure('Name', ['Stimul ', num2str(iStimul), ' - Gaussian attention maps'])
    set( axes,'fontsize', FontSize, 'FontName', 'Times');
    for iTrial = 1:nTrial
      subplot(nTrialRow, nTrialCol, iTrial);
      set(gca, 'YDir', 'reverse','fontsize', FontSize, 'FontName', 'Times');
      hold on;
      %image(imageLeft, imageTop, scaledImage);  
      %histogram2(xTrial{iTrial}, yTrial{iTrial}, [nHorizBin, nVertBin],'DisplayStyle','tile','ShowEmptyBins','off');
      %plot_fixation(stimulFix(iTrial), fixationDetector.durationThreshold, fixationDetector.dispersionThreshold, true);
      gaussian_attention_map(stimulFix(iTrial).x, stimulFix(iTrial).y, fixationDetector.dispersionThreshold/2, ...
                             stimulFix(iTrial).t, fixationDetector.durationThreshold, scaledImage, imageRect);
      line(stimulRaw(iTrial).x, stimulRaw(iTrial).y, 'Color', 'g');
      rectangle('Position', imageRect, 'EdgeColor', 'm', 'LineWidth', 2);
      hold off;
      axis([imageLeft, imageLeft + imageWidth, imageTop, imageTop + imageHeight]);
      title({trialCaptionLine1{iTrial}; trialCaptionLine2{iTrial}});
    end

    %[x, y, t] = merge_trial_data(stimulFix);
    [xRaw, yRaw, ~] = merge_trial_data(stimulRaw);
    nHorizBin = ceil((max(xRaw) - min(xRaw) + 1)/8);
    nVertBin = ceil((max(yRaw) - min(yRaw) + 1)/8);  
    figure('Name', ['Stimul ', num2str(iStimul), ' - raw gaze heat map over all presentations'])
    set( axes,'fontsize', FontSize, 'FontName', 'Times');
    %subplot(1, 2, 1);
    set(gca, 'YDir', 'reverse','fontsize', FontSize, 'FontName', 'Times');
    hold on;
    image(imageLeft, imageTop, scaledImage);  
    histogram2(xRaw,yRaw, [nHorizBin, nVertBin],'DisplayStyle','tile','ShowEmptyBins','off');
    rectangle('Position', imageRect, 'EdgeColor', 'm', 'LineWidth', 2);
    hold off;
    %subplot(1, 2, 2);
    %set(gca, 'YDir', 'reverse');
    %gaussian_attention_map(x, y, fixationDetector.dispersionThreshold/2, ...
    %                       t, fixationDetector.durationThreshold, scaledImage, imageRect);

  %{
    set(gca, 'YDir', 'reverse');
    hold on;
    image(imageLeft, imageTop, scaledImage);  
    plot_fixation(stimulFix, fixationDetector.durationThreshold, fixationDetector.dispersionThreshold);
    rectangle('Position', imageRect, 'EdgeColor', 'm', 'LineWidth', 2);
    hold off; 
  %}  
    figure('Name', ['Stimul ', num2str(iStimul), ' - Raw gaze heat maps'])
    nHorizBin = ceil((max(xRaw) - min(xRaw) + 1)/8);
    nVertBin = ceil((max(yRaw) - min(yRaw) + 1)/8);
    for iTrial = 1:nTrial       
      subplot(nTrialRow, nTrialCol, iTrial);
      set(gca, 'YDir', 'reverse','fontsize', FontSize, 'FontName', 'Times');
      hold on;
      image(imageLeft, imageTop, scaledImage);  
      histogram2(stimulRaw(iTrial).x, stimulRaw(iTrial).y, [nHorizBin, nVertBin],'DisplayStyle','tile','ShowEmptyBins','off');
      rectangle('Position', imageRect, 'EdgeColor', 'm', 'LineWidth', 2);
      hold off;
      axis([imageLeft, imageLeft + imageWidth, imageTop, imageTop + imageHeight]);
      title({trialCaptionLine1{iTrial}; trialCaptionLine2{iTrial}});       
    end


    [scrambledFix, scrambledRaw, trialIndices] = get_gaze_pos(trial, 'scrambled', iStimul, fixationDetector);
    scrambledFix = bound_gaze_pos(scrambledFix, screenRect);
    scrambledRaw = bound_gaze_pos(scrambledRaw, screenRect);
    scrambledStat(iStimul) = compute_fixation_statistic(scrambledFix, screenRect, ...
                                                    imageRect, eyesRect(iStimul, :), mouthRect(iStimul, :), scaledImage);
    scrambledStat(iStimul).trialIndex = trialIndices;
  %{
    [xRaw, yRaw, ~] = merge_trial_data(scrambledRaw);
    nHorizBin = ceil((max(xRaw) - min(xRaw) + 1)/8);
    nVertBin = ceil((max(yRaw) - min(yRaw) + 1)/8);    
    figure
    set(gca, 'YDir', 'reverse');
    hold on;
    %image(imageLeft, imageTop, scaledImage);  
    h = histogram2(xRaw,yRaw, [nHorizBin, nVertBin],'DisplayStyle','tile','ShowEmptyBins','off');
    rectangle('Position', imageRect, 'EdgeColor', 'm', 'LineWidth', 2);
    hold off;
  %} 
  end                                                    
end