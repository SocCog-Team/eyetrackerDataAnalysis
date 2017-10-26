function [stimulStat, scrambledStat] = ...
    analyse_stimul_fixation(trial, stimulCaption, pValue, stimulImage, fixationDetector, ...
                                                  screenRect, imageRect, eyesRect, mouthRect)
  FontSize = 14;                                                
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
     
    %all hit maps
    figure('Name', ['Stimul ', num2str(iStimul), ' - Gaussian attention maps'])
    set( axes,'fontsize', FontSize, 'FontName', 'Arial');
    for iTrial = 1:nTrial
      subplot(nTrialRow, nTrialCol, iTrial);
      set(gca, 'YDir', 'reverse','fontsize', FontSize, 'FontName', 'Arial');
      hold on;
      gaussian_attention_map(stimulFix(iTrial).x, stimulFix(iTrial).y, fixationDetector.dispersionThreshold/2, ...
                             stimulFix(iTrial).t, fixationDetector.durationThreshold, scaledImage, imageRect);
      line(stimulRaw(iTrial).x, stimulRaw(iTrial).y, 'Color', [0.6 0.4 0.9]);
      hold off;
      box off; 
      axis off; 
      axis([imageLeft, imageLeft + imageWidth, imageTop, imageTop + imageHeight]);
      %print a short name of stimul 
      titleText = strsplit(trialCaptionLine2{1}, ' -');      
      title({trialCaptionLine1{iTrial}; titleText{1}}, 'fontsize', FontSize, 'FontName','Arial'); 
      %%or a full name
      %title({trialCaptionLine1{iTrial}; trialCaptionLine2{iTrial}}, 'fontsize', FontSize, 'FontName','Arial'); 
    end
    % 'PaperPositionMode','auto',
    set( gcf,'PaperUnits','centimeters', 'PaperPosition', [ 0 0 29 21 ],'PaperOrientation','landscape' );
    print('-dpdf', ['Stimul', num2str(iStimul), '_gam.pdf'], '-r600');   
    
    %[x, y, t] = merge_trial_data(stimulFix);
    [xRaw, yRaw, ~] = merge_trial_data(stimulRaw);
    nHorizBin = ceil((max(xRaw) - min(xRaw) + 1)/8);
    nVertBin = ceil((max(yRaw) - min(yRaw) + 1)/8);  
    figure('Name', ['Stimul ', num2str(iStimul), ' - raw gaze heat map over all presentations'])
    set( axes,'fontsize', FontSize, 'FontName', 'Arial');
    set(gca, 'YDir', 'reverse','fontsize', FontSize, 'FontName', 'Arial');
    hold on;
    image(imageLeft, imageTop, scaledImage);  
    histogram2(xRaw,yRaw, [nHorizBin, nVertBin],'DisplayStyle','tile','ShowEmptyBins','off');
    hold off;

    figure('Name', ['Stimul ', num2str(iStimul), ' - Raw gaze heat maps'])
    nHorizBin = ceil((max(xRaw) - min(xRaw) + 1)/8);
    nVertBin = ceil((max(yRaw) - min(yRaw) + 1)/8);
    for iTrial = 1:nTrial       
      subplot(nTrialRow, nTrialCol, iTrial);
      set(gca, 'YDir', 'reverse','fontsize', FontSize, 'FontName', 'Arial');
      hold on;
      image(imageLeft, imageTop, scaledImage);  
      histogram2(stimulRaw(iTrial).x, stimulRaw(iTrial).y, [nHorizBin, nVertBin],'DisplayStyle','tile','ShowEmptyBins','off');
      hold off;
      axis([imageLeft, imageLeft + imageWidth, imageTop, imageTop + imageHeight]);
      title({trialCaptionLine1{iTrial}; trialCaptionLine2{iTrial}}, 'fontsize', FontSize, 'FontName','Arial', 'Interpreter', 'latex');        
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

  %% averaged heat maps  
for iFig = 1:2
  nTrialToShowTogether = 5;
  nCol = floor(sqrt(2*nStimul));
  nRow = ceil(nStimul/nCol);      
     
  plotHandle = gobjects(nStimul, 1);  
  %all hit maps
  figure('Average attention maps');
  set( axes,'fontsize', FontSize, 'FontName', 'Arial');
%{
set(0, 'DefaultAxesFontName', 'Arial');
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultTextFontName', 'Arial');
%}  
  for iStimul = 1:nStimul 
    originalImage = imread(stimulImage{iStimul});
    scaledImage = imresize(originalImage,[imageHeight imageWidth]); 

    [stimulFix, ~, trialIndices] = get_gaze_pos(trial, 'stimulus', stimulCaption{iStimul}, fixationDetector);
    stimulFix = bound_gaze_pos(stimulFix, screenRect);
    %trialCaptionLine2 = {trial(trialIndices).caption};
    
    if (iFig == 2)
      nTrialToShowTogether = length(stimulFix);
    end  
    
    allX = [stimulFix(1:nTrialToShowTogether).x];
    allY = [stimulFix(1:nTrialToShowTogether).y];
    allT = [stimulFix(1:nTrialToShowTogether).t];    
    titleText = strsplit(trial(trialIndices(1)).caption, ' -');
    
    plotHandle(iStimul) = subplot(nRow, nCol, iStimul);
    set(gca, 'YDir', 'reverse','fontsize', FontSize, 'FontName', 'Arial');
    gaussian_attention_map(allX, allY, fixationDetector.dispersionThreshold/2, ...
                           allT, (nTrialToShowTogether/2)*fixationDetector.durationThreshold, scaledImage, imageRect);
    set(gca, 'fontsize', FontSize, 'FontName', 'Arial');
    box off; 
    axis off; 
    axis([imageLeft, imageLeft + imageWidth, imageTop, imageTop + imageHeight]);
    title(titleText{1}, 'fontsize', FontSize + 4, 'FontName','Arial');  
  end
  tickLabel = fixationDetector.durationThreshold*[0.4 1 2 4 8]/2;
  tickValue = 0.75*log(1 + 4*tickLabel/fixationDetector.durationThreshold)/log(3);
  
  colormap(parula(256))
  pos = get(plotHandle(nStimul), 'Position');
  h = colorbar('Position', [pos(1)+pos(3)+0.07  pos(2)+0.05*pos(4)  0.15*pos(3) 0.95*pos(4)], ... 
        'Ticks', tickValue/2, ...
        'TickLabels', cellstr(num2str(tickLabel')),...
        'fontsize', FontSize, 'FontName', 'Arial');
  ylabel(h, 'mean fixation time [ms]', 'fontsize', FontSize, 'FontName', 'Arial');
  
  set( gcf,'PaperUnits','centimeters', 'PaperPosition', [ 0 0 29 21 ],'PaperOrientation','landscape' );
%    print('-dpng', ['Stimul', num2str(iStimul), '_overall'], '-r600');
  if (iFig == 1)
    print('-dpdf', 'NormalHeatMap_average', '-r600');
  else
    print('-dpdf', 'NormalHeatMap_average_all', '-r600');
  end  
end
  

  nTrialToShowTogether = 5;
  nCol = floor(sqrt(2*nStimul));
  nRow = ceil(nStimul/nCol);           
  %all hit maps
  figure
  set( axes,'fontsize', FontSize, 'FontName', 'Arial');  
  for iStimul = 1:nStimul 
    originalImage = imread(stimulImage{iStimul});
    scaledImage = imresize(originalImage,[imageHeight imageWidth]); 

    [stimulFix, ~, trialIndices] = get_gaze_pos(trial, 'stimulus', stimulCaption{iStimul}, fixationDetector);
    stimulFix = bound_gaze_pos(stimulFix, screenRect);
    %trialCaptionLine2 = {trial(trialIndices).caption};
    
    allX = [stimulFix(1:nTrialToShowTogether).x];
    allY = [stimulFix(1:nTrialToShowTogether).y];
    allT = [stimulFix(1:nTrialToShowTogether).t];    
    titleText = strsplit(trial(trialIndices(1)).caption, ' -');
    
    plotHandle(iStimul) = subplot(nRow, nCol, iStimul);
    set(gca, 'YDir', 'reverse','fontsize', FontSize, 'FontName', 'Arial');
    gaussian_attention_map(allX, allY, fixationDetector.dispersionThreshold/2, ...
                           allT, fixationDetector.durationThreshold, scaledImage, imageRect);
    set(gca, 'fontsize', FontSize, 'FontName', 'Arial');
    box off; 
    axis off; 
    axis([imageLeft, imageLeft + imageWidth, imageTop, imageTop + imageHeight]);
    title(titleText{1}, 'fontsize', FontSize + 4, 'FontName','Arial');  
  end
  set( gcf,'PaperUnits','centimeters', 'PaperPosition', [ 0 0 29 21 ],'PaperOrientation','landscape' );
  print('-dpdf', 'NormalHeatMap_sum', '-r600');


  %print('-dpdf', 'NormalHeatMap_sum', '-r600');
  
  %% Fisher test for number of fixations for various stimuli in each region
  regionName = {'ROI', 'Face', 'Eyes', 'Mouth' };
  nRegion = 4;
  
  figure('Name', 'Fisher exact test for N fixations')
  set( axes,'fontsize', FontSize, 'FontName', 'Arial');
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
    title(['Fixations to ', region], 'fontsize', FontSize, 'FontName','Arial'); 
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
