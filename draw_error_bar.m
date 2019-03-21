% @brief draw_error_bar creates a bar graph with grouped bars and 
% (optionally) with confidence intervals
%
% INPUT
%   - mean - matrix of MxN mean values representing the height of the bars
%   - confInt - matrix of MxN confidence intervals values representing the
%   error marks. If confInt is an empty array, no error marks are shown
%
% OUTPUT
%   - barHandle - array of handles to the plotted bars
% EXAMPLE 
%{
 % three bars are plotted for each of two points
 mean = [5,6,7;7,8,9];
 confInt = [1,2,3; 1,1,1];
 draw_error_bar(mean, confInt)
 set( gca, 'XTick', 1:2);  
%}

function barHandle = draw_error_bar(mean, confInt)
  [nBars, nDataSource] = size(mean);  
  showConfInt = ~isempty(confInt);
   
  xRange = 1:nBars;
  if (mod(nDataSource,2))
    marginValue = fix(nDataSource/2);
  else
    marginValue = (nDataSource-1)/2;
  end
  offset = -marginValue:marginValue;
  smooshFactor = 0.8;
  barWidth = 0.85*smooshFactor/nDataSource;

  colorVector = (0:nDataSource-1)/(nDataSource-1);
  barColor = [1 - 0.75*colorVector; 0.4 + 0.1*colorVector; 0.25 + 0.5*colorVector];
  barHandle = [];
  
  hold on;
  for i = 1:nDataSource
    barOrigins = xRange + smooshFactor*(offset(i)/nDataSource);
    b = bar(barOrigins, mean(:, i), barWidth, 'FaceColor', barColor(:, i));
    barHandle = [barHandle b]; 
    if (showConfInt)
      errorbar(barOrigins, mean(:, i), confInt(:, i), 'LineStyle', 'none', 'color', 'black');
    end  
  end  
  hold off; 
end
