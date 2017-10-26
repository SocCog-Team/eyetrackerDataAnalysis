function show_fixation_report(stimulName, stimulStat, scrambledStat)
  lineWidth = 2.0;
  FontSize = 12;
  regionName = {'ROI', 'Eyes', 'Mouth', 'Face' };
  
  for iRegion = 1:4
    region = regionName{iRegion};
    totalTime.(['shareOn' region]) = [stimulStat(:).(['totalShareTimeOn' region])];
    totalTime.(['confInt' region]) = [stimulStat(:).(['confIntTimeOn' region])];

    totalFix.(['shareOn' region]) = [stimulStat(:).(['totalShareFixOn' region])];
    totalFix.(['confInt' region]) = [stimulStat(:).(['confIntFixOn' region])];    
    totalFix.(['firstFixOn' region]) = [stimulStat(:).(['freqFirstFixOn' region])];    
  end
  
  for iRegion = 1:3
    region = regionName{iRegion};
    totalTimeScram.(['shareOn' region]) = [scrambledStat(:).(['totalShareTimeOn' region])];
    totalTimeScram.(['confInt' region]) = [scrambledStat(:).(['confIntTimeOn' region])];

    totalFixScram.(['shareOn' region]) = [scrambledStat(:).(['totalShareFixOn' region])];
    totalFixScram.(['confInt' region]) = [scrambledStat(:).(['confIntFixOn' region])];
    totalFixScram.(['firstFixOn' region]) = [scrambledStat(:).(['freqFirstFixOn' region])];        
  end

  %lineType = {'r-o', 'r-*', 'r-s', 'b--o', 'b--*', 'b--s'};
  %fieldName = {'shareTimeOnFace', 'shareTimeOnEyes', 'shareTimeOnMouth', 'shareFixOnFace', 'shareFixOnEyes', 'shareFixOnMouth'};
  %lineType = {'r-o', 'r-*', 'b--o', 'b--*'};
  lineType = {'r-o', 'b--*'};
  fieldName = {'shareFixOnFace', 'shareFixOnEyes'};
  nField = length(fieldName);
  
  nStimul = length(stimulName);
  nStimCol = floor(sqrt(2*nStimul));
  nStimRow = ceil(nStimul/nStimCol);
  regionLabel = {'to ROI', 'to eyes'};  
  figure('Name', 'Trial-wise shares of fixations');
  set( axes,'fontsize', FontSize, 'FontName','Arial');
  for iStimul = 1:nStimul
    subplot(nStimRow, nStimCol, iStimul);
    hold on;
    for iField = 1:nField
      plot(stimulStat(iStimul).(fieldName{iField}), lineType{iField}, 'linewidth', lineWidth, 'markersize', 9);
    end
    hold off
    set(gca, 'XTick', 1:length(stimulStat(iStimul).trialIndex), 'XTickLabel', cellstr(num2str(stimulStat(iStimul).trialIndex(:))), 'fontsize', FontSize, 'FontName','Arial');
    axis([0.8, length(stimulStat(iStimul).(fieldName{iField})) + 0.2, 0, 1.0]);
    xlabel( ' Trial ', 'fontsize', FontSize, 'FontName', 'Arial');
    ylabel( ' Proportions of fixation number ', 'fontsize', FontSize, 'FontName', 'Arial');
    legend_handleMain = legend(regionLabel, 'location', 'NorthEast');
    set(legend_handleMain, 'fontsize', FontSize-1, 'FontName','Arial'); %, 'Interpreter', 'latex'
    title(stimulName{iStimul}, 'fontsize', FontSize, 'FontName','Arial'); %, 'Interpreter', 'latex' 
  end
  set( gcf, 'PaperUnits','centimeters' );
  xSize = 36; ySize = 24;
  xLeft = 0; yTop = 0;
  set( gcf,'PaperPosition', [ xLeft yTop xSize ySize ] );
  print ( '-depsc', '-r300', 'timeCourse.eps');

  regionLabel = {'to ROI', 'to face', 'to eyes', 'to mouth'};  
  figure('Name', 'Fixations proportions');
  set( axes,'fontsize', FontSize, 'FontName','Arial');
  maxValue = 1.29;
  subplot(2, 3, 1);
  barData = [totalFix.shareOnROI; totalFix.shareOnFace; totalFix.shareOnEyes; totalFix.shareOnMouth];
  confInt = [totalFix.confIntROI; totalFix.confIntFace; totalFix.confIntEyes; totalFix.confIntMouth];
  draw_error_bar(barData, confInt, stimulName, regionLabel, FontSize, maxValue);       
  title('proportions of fixation duration (stimuli)', 'fontsize', FontSize, 'FontName','Arial'); %, 'Interpreter', 'latex'
  
  subplot(2, 3, 2);
  barData = [totalTime.shareOnROI; totalTime.shareOnFace; totalTime.shareOnEyes; totalTime.shareOnMouth];
  confInt = [totalTime.confIntROI; totalTime.confIntFace; totalTime.confIntEyes; totalTime.confIntMouth];
  draw_error_bar(barData, confInt, stimulName, regionLabel, FontSize, maxValue);   
  title('proportions of fixation number (stimuli)', 'fontsize', FontSize, 'FontName','Arial'); %, 'Interpreter', 'latex'

  subplot(2, 3, 3);
  barData = [totalFix.firstFixOnROI; totalFix.firstFixOnFace; totalFix.firstFixOnEyes; totalFix.firstFixOnMouth];
  draw_error_bar(barData, stimulName, regionLabel, FontSize, maxValue+0.2);   
  title('first fixation rate (scrambled) (stimuli)', 'fontsize', FontSize, 'FontName','Arial'); %, 'Interpreter', 'latex'
  
  regionLabel = {'to ROI', 'to eyes', 'to mouth'};
  subplot(2, 3, 4);
  barData = [totalFixScram.shareOnROI;  totalFixScram.shareOnEyes; totalFixScram.shareOnMouth];
  confInt = [totalFixScram.confIntROI;  totalFixScram.confIntEyes; totalFixScram.confIntMouth];
  draw_error_bar(barData, confInt, stimulName, regionLabel, FontSize, maxValue);   
  title('proportions of fixation duration (scrambled)', 'fontsize', FontSize, 'FontName','Arial'); %, 'Interpreter', 'latex'

  subplot(2, 3, 5);
  barData = [totalTimeScram.shareOnROI;  totalTimeScram.shareOnEyes; totalTimeScram.shareOnMouth];
  confInt = [totalTimeScram.confIntROI;  totalTimeScram.confIntEyes; totalTimeScram.confIntMouth];
  draw_error_bar(barData, confInt, stimulName, regionLabel, FontSize, maxValue); 
  title('proportions of fixation number (scrambled)', 'fontsize', FontSize, 'FontName','Arial'); %, 'Interpreter', 'latex'

  subplot(2, 3, 6);
  barData = [totalFixScram.firstFixOnROI; totalFixScram.firstFixOnEyes; totalFixScram.firstFixOnMouth];
  draw_error_bar(barData, stimulName, regionLabel, FontSize, maxValue+0.2);   
  title('first fixation rate (scrambled)', 'fontsize', FontSize, 'FontName', 'Arial'); %, 'Interpreter', 'latex'
  
  set( gcf, 'PaperUnits','centimeters' );
  xSize = 36; ySize = 24;
  xLeft = 0; yTop = 0;
  set( gcf,'PaperPosition', [ xLeft yTop xSize ySize ] );
  print ( '-depsc', '-r300', 'barPlot.eps');
  
  
  %{
  figure('Name', 'Total shares of fixations');
  set( axes,'fontsize', FontSize, 'FontName','Arial');
  
  subplot(2, 2, 1);
  barData = [totalShareFixOnROI', totalShareFixOnFace', totalShareFixOnEyes', totalShareFixOnMouth'];
  hold on;
  bar(barData); 
%  plot([3.5 3.5], [0 0.8], 'k--')
  hold off;
  legend_handleMain = legend('in ROI', 'on face', 'on eyes', 'on mouth', 'location', 'NorthEast');
  set(legend_handleMain, 'fontsize', FontSize, 'FontName','Arial');
  axis([0.5, nStimul + 0.5, 0, 0.8]);
  title('share of fixations on stimuli')
  
  subplot(2, 2, 2);
  barData = [totalShareTimeOnROI', totalShareTimeOnFace', totalShareTimeOnEyes', totalShareTimeOnMouth'];
  hold on;
  bar(barData); 
%  plot([3.5 3.5], [0 0.8], 'k--')
  hold off;
  legend_handleMain = legend('in ROI', 'on face', 'on eyes', 'on mouth', 'location', 'NorthEast');
  set(legend_handleMain, 'fontsize', FontSize, 'FontName','Arial');
  axis([0.5, nStimul + 0.5, 0, 0.8]);
  title('share of fixation time on stimuli')

  subplot(2, 2, 3);
  barData = [totalShareFixOnROIScram',  totalShareFixOnEyesScram', totalShareFixOnMouthScram'];
  bar(barData); 
  legend_handleMain = legend('in ROI', 'on eyes', 'on mouth', 'location', 'NorthEast');
  set(legend_handleMain, 'fontsize', FontSize, 'FontName','Arial');
  axis([0.5, nStimul + 0.5, 0, 0.8]);
  title('share of fixations on scrambled')

  
  subplot(2, 2, 4);
  barData = [totalShareTimeOnROIScram',  totalShareTimeOnEyesScram', totalShareTimeOnMouthScram'];
  bar(barData); 
  legend_handleMain = legend('in ROI', 'on eyes', 'on mouth', 'location', 'NorthEast');
  set(legend_handleMain, 'fontsize', FontSize, 'FontName','Arial');
  axis([0.5, nStimul + 0.5, 0, 0.8]);
  title('share of fixation time on scrambled')
  %}
end

