% @brief display_fixation_proportions draws two overview firures characterizing the experiment
% 1. plot of fixation proportions for each stimul as a function of trial number
% 2. bar graphs of fixation proportions averaged over stimuli presentations
%
% INPUT
%   - stimulName - cell array with names of the stimuli, used for ;
%   - stimulStat - two estimates of a certain quantity in several 
%     epochs, row or column vectors of equal size;
%   - scrambledStat
%
%
 

function display_fixation_proportions(sessionName, stimulName, stimulStat, scrambledStat)
lineWidth = 2.0;
fontSize = 12;
fontName = 'Arial';
nStimul = length(stimulName);

% draw line plots of fixation proportions dependence on stimulus presentation
fieldName = {'shareFixOnFace', 'shareFixOnEyes'};
lineType = {'r-o', 'b--*'};
nField = length(fieldName);
nStimCol = floor(sqrt(2*nStimul));
nStimRow = ceil(nStimul/nStimCol);
regionLabel = {'to ROI', 'to eyes'};
figure('Name', 'Trial-wise shares of fixations');

[output_rect] = fnFormatPaperSize('Plos', gcf, 1/2.54);
set(gcf(), 'Units', 'centimeters', 'Position', output_rect, 'PaperPosition', output_rect);


set( axes,'fontSize', fontSize, 'FontName', fontName);
for iStimul = 1:nStimul
    subplot(nStimRow, nStimCol, iStimul);
    hold on;
    for iField = 1:nField
        plot(stimulStat(iStimul).(fieldName{iField}), lineType{iField}, 'linewidth', lineWidth, 'markersize', 9);
    end
    hold off
    set(gca, 'XTick', 1:length(stimulStat(iStimul).trialIndex), 'XTickLabel', cellstr(num2str(stimulStat(iStimul).trialIndex(:))), 'fontSize', fontSize, 'FontName', fontName);
    axis([0.8, length(stimulStat(iStimul).(fieldName{iField})) + 0.2, 0, 1.0]);
    xlabel( ' Trial ', 'fontSize', fontSize, 'FontName', fontName);
    ylabel( ' Fixation proportions ', 'fontSize', fontSize, 'FontName', fontName);
    legend_handleMain = legend(regionLabel, 'location', 'best');
    set(legend_handleMain, 'fontSize', fontSize-2, 'FontName',fontName);
    title(stimulName{iStimul}, 'fontSize', fontSize-2, 'FontName',fontName);
end
% set( gcf, 'PaperUnits','centimeters' );
% xSize = 36; ySize = 24;
% xLeft = 0; yTop = 0;
% set( gcf,'PaperPosition', [ xLeft yTop xSize ySize ] );
%print( '-depsc', '-r300', 'timeCourse.eps');
write_out_figure(gcf(), 'timeCourse.pdf');

% prepare to draw the bar graphs of fixation proportions:
% fill tables with fixation data for all regions
regionName = {'Face', 'Eyes', 'Mouth'};
nRegion = length(regionName);

for iRegion = 1:nRegion
    region = regionName{iRegion};
    totalTime.(['shareOn' region]) = [stimulStat(:).(['totalShareTimeOn' region])];
    totalTime.(['confInt' region]) = [stimulStat(:).(['confIntTimeOn' region])];
    
    totalFix.(['shareOn' region]) = [stimulStat(:).(['totalShareFixOn' region])];
    totalFix.(['confInt' region]) = [stimulStat(:).(['confIntFixOn' region])];
    totalFix.(['firstFixOn' region]) = [stimulStat(:).(['freqFirstFixOn' region])];

    totalTimeScram.(['shareOn' region]) = [scrambledStat(:).(['totalShareTimeOn' region])];
    totalTimeScram.(['confInt' region]) = [scrambledStat(:).(['confIntTimeOn' region])];
    
    totalFixScram.(['shareOn' region]) = [scrambledStat(:).(['totalShareFixOn' region])];
    totalFixScram.(['confInt' region]) = [scrambledStat(:).(['confIntFixOn' region])];
    totalFixScram.(['firstFixOn' region]) = [scrambledStat(:).(['freqFirstFixOn' region])];
end

% draw bar graphs of fixation proportions
plotTitle = {'proportions of fixation durations (stimuli)', ...
             'proportions of fixations (stimuli)', ...
             'rate of first fixations (stimuli)', ...
             'proportions of fixation duration (scrambled)', ...
             'proportions of fixations (scrambled)', ...
             'first fixation rate (scrambled)'};
             
figure('Name', 'Fixation proportions');
[output_rect] = fnFormatPaperSize('Plos', gcf, 1/2.54);
set(gcf(), 'Units', 'centimeters', 'Position', output_rect, 'PaperPosition', output_rect);

set( axes,'fontSize', fontSize, 'FontName',fontName);
maxValue = 1.0;       
for iPlot = 1:6   
    % prepare data for the plot
    if ((iPlot == 3) || (iPlot == 6))
        if (iPlot == 3)
            toPlot = totalFix;
        else
            toPlot = totalFixScram;
        end
        barData = [toPlot.firstFixOnFace; toPlot.firstFixOnEyes; toPlot.firstFixOnMouth];
        confInt = [];
    else        
        if (iPlot == 1)
            toPlot = totalFix;            
        elseif (iPlot == 2)
            toPlot = totalTime;
        elseif (iPlot == 4)
            toPlot = totalFixScram;
        elseif (iPlot == 5)
            toPlot = totalTimeScram;
        end
        barData = [toPlot.shareOnFace; toPlot.shareOnEyes; toPlot.shareOnMouth];
        confInt = [toPlot.confIntFace; toPlot.confIntEyes; toPlot.confIntMouth];    
    end
    
    subplot(2, 3, iPlot);
    barHandle = draw_error_bar(barData, confInt);    
%     legend_handleMain = legend(barHandle, stimulName, 'location', 'NorthEast'); 
%     set(legend_handleMain, 'fontsize', fontSize-1, 'FontName', fontName);%, 'FontName','Times', 'Interpreter', 'latex');
%     pos = get(legend_handleMain, 'Position');
%     set(legend_handleMain, 'Position', [pos(1) + 0.1, pos(2) + 0.07, pos(3:4)]);
%     legend boxoff 
    axis([0.5, nRegion + 0.5, 0, maxValue + 0.1]);
    set( gca, 'XTick', 1:nRegion, 'XTickLabel', regionName, 'YTick', 0:0.2:1, 'fontsize', fontSize, 'FontName',fontName);  
    title(plotTitle(iPlot), 'fontSize', fontSize, 'FontName',fontName);
end   




% set( gcf, 'PaperUnits','centimeters' );
% xSize = 36; ySize = 24;
% xLeft = 0; yTop = 0;
% set( gcf,'PaperPosition', [ xLeft yTop xSize ySize ] );
%print( '-depsc', '-r300', fullfile(sessionName, 'barPlot.eps'));
write_out_figure(gcf(), fullfile(sessionName, 'Fixation_by_image_class_barPlot.pdf'))

legend_handleMain = legend(barHandle, stimulName, 'location', 'NorthEast');
set(legend_handleMain, 'fontsize', fontSize-1, 'FontName', fontName);%, 'FontName','Times', 'Interpreter', 'latex');
%pos = get(legend_handleMain, 'Position');
%set(legend_handleMain, 'Position', [pos(1) + 0.1, pos(2) + 0.07, pos(3:4)]);
legend boxoff

write_out_figure(gcf(), fullfile(sessionName, 'Fixation_by_image_class_barPlot.legend.pdf'))


end

