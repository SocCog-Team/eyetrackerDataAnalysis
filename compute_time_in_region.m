function [timeInRegion, numFixInRegion] = compute_time_in_region(varargin)
  nVarargs = length(varargin);
  if (nVarargs >= 4) % we assume that trial is passed
    trial = struct('x', varargin{1}, 'y', varargin{2}, 't', varargin{3}); 
    roiPositionInArgList = 4;
  else
    trial = varargin{1};
    roiPositionInArgList = 2;    
  end 
  nTrial = length(trial);
  timeInRegion = zeros(nTrial, 1);
  numFixInRegion = zeros(nTrial, 1);
  
  if (nVarargs < roiPositionInArgList) 
    error('Not enough input parameters: rectangle specifying the region of interest is missing');
  end
  roiRect = varargin{roiPositionInArgList};
  if (length(roiRect) < 4)
    error('Rectangle should be described by a vector of length 4');
  end    
  left = roiRect(1);
  top = roiRect(2);
  width = roiRect(3); 
  height = roiRect(4);
  
  for iTrial = 1:nTrial
    roiIndices = find((trial(iTrial).x >= left) & (trial(iTrial).y >= top) & ... 
                      (trial(iTrial).x < left + width) & (trial(iTrial).y < top + height));
  
    if (nVarargs > roiPositionInArgList) %if image is passed to mask the fixations
      maskImage = varargin{roiPositionInArgList + 1};
      ix = round(trial(iTrial).x(roiIndices) - left + 1);            
      iy = round(trial(iTrial).y(roiIndices) - top + 1);
      faceIndicesAmongRoiIndices = any( impixel(maskImage, ix, iy), 2);  
      faceIndices = roiIndices(faceIndicesAmongRoiIndices);
      timeInRegion(iTrial) = sum(trial(iTrial).t(faceIndices));
      numFixInRegion(iTrial) = length(faceIndices);
    else
      timeInRegion(iTrial) = sum(trial(iTrial).t(roiIndices));
      numFixInRegion(iTrial) = length(roiIndices);      
    end
  end  
end  