function [stimulStat, scrambledStat] = ...
    analyse_stimul_fixation(trial, stimulCaption, pValue, stimulImage, fixationDetector, ...
                                                  screenRect, imageRect, eyesRect, mouthRect)
  FontSize = 10;                                                
  imageLeft = imageRect(1);
  imageTop = imageRect(2);
  imageWidth = imageRect(3);
  imageHeight = imageRect(4);
  nStimul = length(stimulCaption);
  for iStimul = 1:nStimul 
    originalImage = imread(stimulImage{iStimul});
    scaledImage = imresize(originalImage,[imageHeight imageWidth]); 

%    [stimulFix, stimulRaw, trialIndices] = get_gaze_pos(trial, 'stimulus', iStimul, fixationDetector, true);
    [stimulFix, stimulRaw, trialIndices] = get_gaze_pos(trial, 'stimulus', stimulCaption{iStimul}, fixationDetector);
    stimulFix = bound_gaze_pos(stimulFix, screenRect);
    stimulRaw = bound_gaze_pos(stimulRaw, screenRect);
    trialIndicesAsStr = arrayfun(@num2str, trialIndices, 'UniformOutput', false);
    trialCaptionLine1 = strcat('Trial', {' '}, trialIndicesAsStr);
    trialCaptionLine2 = {trial(trialIndices).caption};
    trialCaptionLine2 = strrep(trialCaptionLine2, 'obfuscation ', 'obf.');

    stimulStat(iStimul) = compute_fixation_statistic(stimulFix, pValue, screenRect, ...
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
      line(stimulRaw(iTrial).x, stimulRaw(iTrial).y, 'Color', [0.6 0.4 0.9]);
      hold off;
      axis([imageLeft, imageLeft + imageWidth, imageTop, imageTop + imageHeight]);
      title({trialCaptionLine1{iTrial}; trialCaptionLine2{iTrial}}, 'fontsize', FontSize, 'FontName','Times', 'Interpreter', 'latex'); 
    end
    % 'PaperPositionMode','auto',
    set( gcf,'PaperUnits','centimeters', 'PaperPosition', [ 0 0 29 21 ],'PaperOrientation','landscape' );
    print('-dpdf', ['Stimul', num2str(iStimul), '_gam.pdf']);
%{
          fixIn = stimulStat(iStimul).(['numFixOn' region]);
    fixOut = stat.numFixTotal - stat.(['numFixOn' region])

    contigencyMatrixEnd(1, :) = 
    for jSession = iSession+1:currSubject.nSession
      subjectIndex = max(1, currSubject.sessionType(jSession));
      currSessionIndex = currSubject.sessionIndex(jSession);
      contigencyMatrix(2, :) = freeSession(currSessionIndex).numChoiceOfPos(subjectIndex, :);
      contigencyMatrixEnd(2, :) = freeSession(currSessionIndex).numChoiceOfPosEnd(subjectIndex, :);
      isAssociation(iSession, jSession) = fishertest(contigencyMatrix, 'Alpha',0.01);
%}      
      
  

    
    
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
    %rectangle('Position', imageRect, 'EdgeColor', 'm', 'LineWidth', 2);
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
      %rectangle('Position', imageRect, 'EdgeColor', 'm', 'LineWidth', 2);
      hold off;
      axis([imageLeft, imageLeft + imageWidth, imageTop, imageTop + imageHeight]);
      title({trialCaptionLine1{iTrial}; trialCaptionLine2{iTrial}}, 'fontsize', FontSize, 'FontName','Times', 'Interpreter', 'latex');        
    end


    [scrambledFix, scrambledRaw, trialIndices] = get_gaze_pos(trial, 'scrambled', stimulCaption{iStimul}, fixationDetector);
    scrambledFix = bound_gaze_pos(scrambledFix, screenRect);
    scrambledRaw = bound_gaze_pos(scrambledRaw, screenRect);
    scrambledStat(iStimul) = compute_fixation_statistic(scrambledFix, pValue, screenRect, ...
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

  %% Fisher test for number of fixations for various stimuli in each region
  regionName = {'ROI', 'Face', 'Eyes', 'Mouth' };
  nRegion = 4;
  
  figure('Name', 'Fisher exact test for N fixations')
  set( axes,'fontsize', FontSize, 'FontName', 'Times');
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
    title(['Fixations to ', region], 'fontsize', FontSize, 'FontName','Times', 'Interpreter', 'latex'); 
  end  

  %% Kruskal-Wallis test for number of fixations for various stimuli in each region  
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
end
