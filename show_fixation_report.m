function show_fixation_report(stimulName, stimulStat, scrambledStat)
  totalShareTimeInROI = [stimulStat(:).totalShareTimeInROI];
  totalShareTimeOnFace = [stimulStat(:).totalShareTimeOnFace];
  totalShareTimeOnEyes = [stimulStat(:).totalShareTimeOnEyes];
  totalShareTimeOnMouth = [stimulStat(:).totalShareTimeOnMouth];

  totalShareFixInROI = [stimulStat(:).totalShareFixInROI];
  totalShareFixOnFace = [stimulStat(:).totalShareFixOnFace];
  totalShareFixOnEyes = [stimulStat(:).totalShareFixOnEyes];
  totalShareFixOnMouth = [stimulStat(:).totalShareFixOnMouth];  

  totalShareTimeInROIScram = [scrambledStat(:).totalShareTimeInROI];
  totalShareTimeOnEyesScram = [scrambledStat(:).totalShareTimeOnEyes];
  totalShareTimeOnMouthScram = [scrambledStat(:).totalShareTimeOnMouth];
  
  totalShareFixInROIScram = [scrambledStat(:).totalShareFixInROI];
  totalShareFixOnEyesScram = [scrambledStat(:).totalShareFixOnEyes];
  totalShareFixOnMouthScram = [scrambledStat(:).totalShareFixOnMouth];

  %lineType = {'r-o', 'r-*', 'r-s', 'b--o', 'b--*', 'b--s'};
  %fieldName = {'shareTimeOnFace', 'shareTimeOnEyes', 'shareTimeOnMouth', 'shareFixOnFace', 'shareFixOnEyes', 'shareFixOnMouth'};
  lineType = {'r-o', 'r-*', 'b--o', 'b--*'};
  fieldName = {'shareTimeOnFace', 'shareTimeOnEyes', 'shareFixOnFace', 'shareFixOnEyes'};
  nField = length(fieldName);
  
  nStimul = length(stimulName);
  nStimCol = floor(sqrt(2*nStimul));
  nStimRow = ceil(nStimul/nStimCol);
  FontSize = 12;
  figure('Name', 'Trial-wise shares of fixations');
  set( axes,'fontsize', FontSize, 'FontName', 'Times');
  for iStimul = 1:nStimul
    subplot(nStimRow, nStimCol, iStimul);
  
    hold on;
    for iField = 1:nField
      plot(stimulStat(iStimul).(fieldName{iField}), lineType{iField});
    end
    hold off
    legend_handleMain = legend(fieldName, 'location', 'NorthEast');
    set(legend_handleMain, 'fontsize', FontSize, 'FontName', 'Times');
    set(gca, 'XTick', 1:length(stimulStat(iStimul).trialIndex), 'XTickLabel', cellstr(num2str(stimulStat(iStimul).trialIndex(:))))
    axis([0.8, length(stimulStat(iStimul).(fieldName{iField})) + 0.2, 0, 1.2]);
    title(stimulName{iStimul})
  end

  figure('Name', 'Total shares of fixations');
  set( axes,'fontsize', FontSize, 'FontName', 'Times');
 
  subplot(2, 2, 1);
  barData = [totalShareFixInROI; totalShareFixOnFace; totalShareFixOnEyes; totalShareFixOnMouth];
  bar(barData); 
  legend_handleMain = legend(stimulName(:), 'location', 'NorthEast');
  set(legend_handleMain, 'fontsize', FontSize, 'FontName', 'Times');
  axis([0.5, 4.5, 0, 0.8]);
  title('share of fixations on stimuli')
  set( gca, 'XTickLabel', {'in ROI', 'on face', 'on eyes', 'on mouth'}, 'fontsize', FontSize, 'FontName', 'Times');
  
  subplot(2, 2, 2);
  barData = [totalShareTimeInROI; totalShareTimeOnFace; totalShareTimeOnEyes; totalShareTimeOnMouth];
  bar(barData); 
  legend_handleMain = legend(stimulName(:), 'location', 'NorthEast');
  set(legend_handleMain, 'fontsize', FontSize, 'FontName', 'Times');
  axis([0.5, 4.5, 0, 0.8]);
  title('share of fixation time on stimuli')
  set( gca, 'XTickLabel', {'in ROI', 'on face', 'on eyes', 'on mouth'}, 'fontsize', FontSize, 'FontName', 'Times');

  subplot(2, 2, 3);
  barData = [totalShareFixInROIScram;  totalShareFixOnEyesScram; totalShareFixOnMouthScram];
  bar(barData); 
  legend_handleMain = legend(stimulName(:), 'location', 'NorthEast');
  set(legend_handleMain, 'fontsize', FontSize, 'FontName', 'Times');
  axis([0.5, 3.5, 0, 0.8]);
  title('share of fixations on scrambled')
  set( gca, 'XTickLabel', {'in ROI', 'on eyes', 'on mouth'}, 'fontsize', FontSize, 'FontName', 'Times');

  
  subplot(2, 2, 4);
  barData = [totalShareTimeInROIScram;  totalShareTimeOnEyesScram; totalShareTimeOnMouthScram];
  bar(barData); 
  legend_handleMain = legend(stimulName(:), 'location', 'NorthEast');
  set(legend_handleMain, 'fontsize', FontSize, 'FontName', 'Times');
  axis([0.5, 3.5, 0, 0.8]);
  title('share of fixation time on scrambled')  
  set( gca, 'XTickLabel', {'in ROI', 'on eyes', 'on mouth'}, 'fontsize', FontSize, 'FontName', 'Times');

  %{
  figure('Name', 'Total shares of fixations');
  set( axes,'fontsize', FontSize, 'FontName', 'Times');
  
  subplot(2, 2, 1);
  barData = [totalShareFixInROI', totalShareFixOnFace', totalShareFixOnEyes', totalShareFixOnMouth'];
  hold on;
  bar(barData); 
%  plot([3.5 3.5], [0 0.8], 'k--')
  hold off;
  legend_handleMain = legend('in ROI', 'on face', 'on eyes', 'on mouth', 'location', 'NorthEast');
  set(legend_handleMain, 'fontsize', FontSize, 'FontName', 'Times');
  axis([0.5, nStimul + 0.5, 0, 0.8]);
  title('share of fixations on stimuli')
  
  subplot(2, 2, 2);
  barData = [totalShareTimeInROI', totalShareTimeOnFace', totalShareTimeOnEyes', totalShareTimeOnMouth'];
  hold on;
  bar(barData); 
%  plot([3.5 3.5], [0 0.8], 'k--')
  hold off;
  legend_handleMain = legend('in ROI', 'on face', 'on eyes', 'on mouth', 'location', 'NorthEast');
  set(legend_handleMain, 'fontsize', FontSize, 'FontName', 'Times');
  axis([0.5, nStimul + 0.5, 0, 0.8]);
  title('share of fixation time on stimuli')

  subplot(2, 2, 3);
  barData = [totalShareFixInROIScram',  totalShareFixOnEyesScram', totalShareFixOnMouthScram'];
  bar(barData); 
  legend_handleMain = legend('in ROI', 'on eyes', 'on mouth', 'location', 'NorthEast');
  set(legend_handleMain, 'fontsize', FontSize, 'FontName', 'Times');
  axis([0.5, nStimul + 0.5, 0, 0.8]);
  title('share of fixations on scrambled')

  
  subplot(2, 2, 4);
  barData = [totalShareTimeInROIScram',  totalShareTimeOnEyesScram', totalShareTimeOnMouthScram'];
  bar(barData); 
  legend_handleMain = legend('in ROI', 'on eyes', 'on mouth', 'location', 'NorthEast');
  set(legend_handleMain, 'fontsize', FontSize, 'FontName', 'Times');
  axis([0.5, nStimul + 0.5, 0, 0.8]);
  title('share of fixation time on scrambled')
  %}
  
  

 
end
