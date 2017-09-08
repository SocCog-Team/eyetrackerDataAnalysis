function draw_error_bar(mean, varargin)
  [nBars, nDataSource] = size(mean);  
  if (length(varargin) > 4)
    showError = true;
    confInt = varargin{1};    
    settingPos = 2;
  else
    showError = false;
    settingPos = 1;
  end
  legendEntry = varargin{settingPos};
  conditionName = varargin{settingPos + 1};
  fontSize = varargin{settingPos + 2};
  maxValue = varargin{settingPos + 3};
    
  xRange = 1:nBars;
  offset = fix(-nDataSource/2):fix(nDataSource/2);
  smooshFactor = 0.8;
  barWidth = 0.85*smooshFactor/nDataSource;

  colorVector = (0:nDataSource-1)/(nDataSource-1);
  barColor = [1 - 0.75*colorVector; 0.4 + 0.1*colorVector; 0.25 + 0.5*colorVector];
  %barColor = [min(0.7 + 0.4*colorVector, 1); 0.35 + 0.5*colorVector; max(0.8 - 0.9*colorVector, 0)];
  barHandle = [];
  
  hold on;
  for i = 1:nDataSource
    barOrigins = xRange + smooshFactor*(offset(i)/nDataSource);
    b = bar(barOrigins, mean(:, i), barWidth, 'FaceColor', barColor(:, i));
    barHandle = [barHandle b]; 
    if (showError)
      errorbar(barOrigins, mean(:, i), confInt(:, i), 'LineStyle', 'none', 'color', 'black');
    end  
  end  
  %bar(barX, barData); 
  %errorbar(barX, barData, errData, 'o')
  hold off;  
  legend_handleMain = legend(barHandle, legendEntry, 'location', 'NorthEast');
  set(legend_handleMain, 'fontsize', fontSize-1, 'FontName','Times', 'Interpreter', 'latex');

  axis([0.5, nBars + 0.5, 0, maxValue]);
  set( gca, 'XTick', 1:nBars, 'XTickLabel', conditionName, 'fontsize', fontSize, 'FontName','Times');  
  

end
