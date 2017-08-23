function show_fixation_report(stimulName, stimulStat, scrambledStat)

  regionName = {'ROI', 'Eyes', 'Mouth', 'Face' };
  
  for iRegion = 1:4
    region = regionName{iRegion};
    totalTime.(['shareOn' region]) = [stimulStat(:).(['totalShareTimeOn' region])];
    totalTime.(['confInt' region]) = [stimulStat(:).(['confIntTimeOn' region])];

    totalFix.(['shareOn' region]) = [stimulStat(:).(['totalShareFixOn' region])];
    totalFix.(['confInt' region]) = [stimulStat(:).(['confIntFixOn' region])];
  end
  
  for iRegion = 1:3
    region = regionName{iRegion};
    totalTimeScram.(['shareOn' region]) = [scrambledStat(:).(['totalShareTimeOn' region])];
    totalTimeScram.(['confInt' region]) = [scrambledStat(:).(['confIntTimeOn' region])];

    totalFixScram.(['shareOn' region]) = [scrambledStat(:).(['totalShareFixOn' region])];
    totalFixScram.(['confInt' region]) = [scrambledStat(:).(['confIntFixOn' region])];
  end

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
  barData = [totalFix.shareOnROI; totalFix.shareOnFace; totalFix.shareOnEyes; totalFix.shareOnMouth];
  confInt = [totalFix.confIntROI; totalFix.confIntFace; totalFix.confIntEyes; totalFix.confIntMouth];
  draw_error_bar(barData, confInt, stimulName, FontSize);       
  title('share of fixations on stimuli')
  set( gca, 'XTickLabel', {'in ROI', 'on face', 'on eyes', 'on mouth'}, 'fontsize', FontSize, 'FontName', 'Times');
  
  subplot(2, 2, 2);
  barData = [totalTime.shareOnROI; totalTime.shareOnFace; totalTime.shareOnEyes; totalTime.shareOnMouth];
  confInt = [totalTime.confIntROI; totalTime.confIntFace; totalTime.confIntEyes; totalTime.confIntMouth];
  draw_error_bar(barData, confInt, stimulName, FontSize);   
  title('share of fixation time on stimuli')
  set( gca, 'XTickLabel', {'in ROI', 'on face', 'on eyes', 'on mouth'}, 'fontsize', FontSize, 'FontName', 'Times');

  subplot(2, 2, 3);
  barData = [totalFixScram.shareOnROI;  totalFixScram.shareOnEyes; totalFixScram.shareOnMouth];
  confInt = [totalFixScram.confIntROI;  totalFixScram.confIntEyes; totalFixScram.confIntMouth];
  draw_error_bar(barData, confInt, stimulName, FontSize);   
  title('share of fixations on scrambled')
  set( gca, 'XTickLabel', {'in ROI', 'on eyes', 'on mouth'}, 'fontsize', FontSize, 'FontName', 'Times');

  subplot(2, 2, 4);
  barData = [totalTimeScram.shareOnROI;  totalTimeScram.shareOnEyes; totalTimeScram.shareOnMouth];
  confInt = [totalTimeScram.confIntROI;  totalTimeScram.confIntEyes; totalTimeScram.confIntMouth];
  draw_error_bar(barData, confInt, stimulName, FontSize); 
  title('share of fixation time on scrambled')  
  set( gca, 'XTickLabel', {'in ROI', 'on eyes', 'on mouth'}, 'fontsize', FontSize, 'FontName', 'Times');

  
  %{
  figure('Name', 'Total shares of fixations');
  set( axes,'fontsize', FontSize, 'FontName', 'Times');
  
  subplot(2, 2, 1);
  barData = [totalShareFixOnROI', totalShareFixOnFace', totalShareFixOnEyes', totalShareFixOnMouth'];
  hold on;
  bar(barData); 
%  plot([3.5 3.5], [0 0.8], 'k--')
  hold off;
  legend_handleMain = legend('in ROI', 'on face', 'on eyes', 'on mouth', 'location', 'NorthEast');
  set(legend_handleMain, 'fontsize', FontSize, 'FontName', 'Times');
  axis([0.5, nStimul + 0.5, 0, 0.8]);
  title('share of fixations on stimuli')
  
  subplot(2, 2, 2);
  barData = [totalShareTimeOnROI', totalShareTimeOnFace', totalShareTimeOnEyes', totalShareTimeOnMouth'];
  hold on;
  bar(barData); 
%  plot([3.5 3.5], [0 0.8], 'k--')
  hold off;
  legend_handleMain = legend('in ROI', 'on face', 'on eyes', 'on mouth', 'location', 'NorthEast');
  set(legend_handleMain, 'fontsize', FontSize, 'FontName', 'Times');
  axis([0.5, nStimul + 0.5, 0, 0.8]);
  title('share of fixation time on stimuli')

  subplot(2, 2, 3);
  barData = [totalShareFixOnROIScram',  totalShareFixOnEyesScram', totalShareFixOnMouthScram'];
  bar(barData); 
  legend_handleMain = legend('in ROI', 'on eyes', 'on mouth', 'location', 'NorthEast');
  set(legend_handleMain, 'fontsize', FontSize, 'FontName', 'Times');
  axis([0.5, nStimul + 0.5, 0, 0.8]);
  title('share of fixations on scrambled')

  
  subplot(2, 2, 4);
  barData = [totalShareTimeOnROIScram',  totalShareTimeOnEyesScram', totalShareTimeOnMouthScram'];
  bar(barData); 
  legend_handleMain = legend('in ROI', 'on eyes', 'on mouth', 'location', 'NorthEast');
  set(legend_handleMain, 'fontsize', FontSize, 'FontName', 'Times');
  axis([0.5, nStimul + 0.5, 0, 0.8]);
  title('share of fixation time on scrambled')
  %}
  
  

 
end

function draw_error_bar(mean, confInt, sourceName, fontSize)
  [nBars, nDataSource] = size(mean);

  xRange = 1:nBars;
  offset = fix(-nDataSource/2):fix(nDataSource/2);
  smooshFactor = 0.8;
  barWidth = 0.9*smooshFactor/nDataSource;

  colorVector = (0:nDataSource-1)/(nDataSource-1);
  barColor = [1 - 0.7*colorVector; 1 - 0.5*colorVector; colorVector];
  barHandle = [];
  
  hold on;
  for i = 1:nDataSource
    barOrigins = xRange + smooshFactor*(offset(i)/nDataSource);
    b = bar(barOrigins, mean(:, i), barWidth, 'FaceColor', barColor(:, i));
    barHandle = [barHandle b]; 
    errorbar(barOrigins, mean(:, i), confInt(:, i), 'LineStyle', 'none', 'color', 'black');
  end  
  %bar(barX, barData); 
  %errorbar(barX, barData, errData, 'o')
  hold off;  
  
  legend_handleMain = legend(barHandle, sourceName, 'location', 'NorthEast');
  set(legend_handleMain, 'fontsize', fontSize, 'FontName', 'Times');
  axis([0.5, nBars + 0.5, 0, 0.95]);
end


function draw_bar(mean, sourceName, fontSize)
  bar(mean);
  legend_handleMain = legend(sourceName(:), 'location', 'NorthEast');
  set(legend_handleMain, 'fontsize', fontSize, 'FontName', 'Times');
  axis([0.5, nBars + 0.5, 0, 0.95]);
end
%{




function barerror(data, varargin)
% function barerror(data, varargin)
% Plots bars for each row with error bars computed as range of data

% USAGE:
% Pass in matrix of data arranged with repeated measurements in columns,
% with rows containing individual types
%           -OR-
% A cell array of these data matrices, for plotting multiple adjacent bars with
% unique colors.
%
% The rest of the stuff it expects goes as follows:
% 1) barlabels:  cell array of strings to label the ROWS of data
% 2) grouplabels: cell array of strings to label the matrix/matrices of data 
% 3) colors: the sequence of color characters for labeling bars
%
% Jonathan Scholz,  GaTech, October 15 2009

% Example:
% data = {diag(sin(1:5)) * rand(5,5),diag(cos(1:5)) * rand(5,5)};
% barerror(data,{'Trial 1','Trial 2','Trial 3','Trial 4','Trial 5'},{'Sin','Cos'});

if iscell(data)
    ntypes = size(data,2);
    nbars = length(data{1});
else
    ntypes = 1;
    nbars = length(data);
end

if nargin >=2
    method = varargin{1};
else
    method = 1; % default to range-based error bars
end

if nargin >= 3
    barlabels = varargin{2};
else
    for i=1:nbars
        barlabels{i}=sprintf('%d',i);
    end
end

if nargin >= 4
    grouplabels = varargin{3};
else
        for i=1:nbars
        grouplabels{i}=sprintf('Class %d',i-1);
    end
end

if nargin >= 5
    colors = varargin{4};
else
    colors = ['r', 'g', 'b', 'c', 'm', 'y', 'k', 'w'];
end

clf;
hold on;
barhandles=[];
for i=1:ntypes
    if iscell(data)
        d=data{i};
    else
        d=data;
    end

    % data stuff
    means = mean(d')';
    mins = min(d')';
    maxs = max(d')';
    if method == 1
        L = means-mins;
        U = means-maxs;
    else
        Z = 1.96; % for 0.95 CI
        stdev = std(d'); % std returns stdev of COLUMNS
        sem = stdev/sqrt(length(d(1,:)));
        L = - Z*sem';
        U = Z*sem';
    end

    % plot control stuff
    xrange = 1:nbars;
    offsets = fix(-ntypes/2):fix(ntypes/2);
    smooshFactor = 0.8;
    barOrigins = xrange+smooshFactor*(offsets(i)/ntypes);
    barwidth = smooshFactor/ntypes;

    b = bar(barOrigins, means, barwidth, colors(mod(i,length(colors))));
    barhandles=[barhandles b]; % is there a better way to fix this???
    errorbar(barOrigins,means,L,U,'LineStyle','none','color','black');
end

title_str = 'title';
xlabel_str = 'x axis';
ylabel_str = 'y axis';

set(gca,'XTickLabel',barlabels);
set(gca,'FontSize',16)

title(title_str);
h = get(gca, 'title');
set(h,'FontSize',16);

xlabel(xlabel_str);
h = get(gca, 'xlabel');
set(h,'FontSize',24);

ylabel(ylabel_str);
h = get(gca, 'ylabel');
set(h,'FontSize',24);

legend(barhandles, grouplabels);
%}