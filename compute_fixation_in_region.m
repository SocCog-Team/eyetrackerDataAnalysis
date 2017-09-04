function [timeInRegion, numFixInRegion, isFirst] = compute_fixation_in_region(varargin)
% compute_time_in_region calculates total duration and amount of fixations
% in a specified region.
%
% SYNTAX
%     [timeInRegion, numFixInRegion, isFirst] = compute_time_in_region(x, y, t, roiRect);
%     [timeInRegion, numFixInRegion, isFirst] = compute_time_in_region(trial, roiRect);
% INPUT
%   Either single trial information:
%     - x - x-coordinates of fixation centres, N-element vector;
%     - y - y-coordinates of fixation centres, N-element vector;
%     - t - fixation durations, N-element vector.
%   or array of trial structures:
%     - trial - array of nTrial structures, having as fields x, y, and t arrays
%		- roiRect - rectangle describing region of interest in format [left top width height]
%		4-element vector in format [left top width height]. Required if presentedImage is specified
% OUTPUT:
%   - timeInRegion - total time of fixations in roiRect, vector 
%   - numFixInRegion - total number of fixations in roiRect
%   - isFirst - does first fixation fall to this region (0 or 1)
%
% EXAMPLE of use    
%

  nVarargs = length(varargin);
  if (nVarargs >= 4) % we assume that single trial is passed as three separate arrays
    trial = struct('x', varargin{1}, 'y', varargin{2}, 't', varargin{3}); 
    roiPositionInArgList = 4;
  else
    trial = varargin{1};
    roiPositionInArgList = 2;    
  end 
  nTrial = length(trial);
  timeInRegion = zeros(nTrial, 1);
  numFixInRegion = zeros(nTrial, 1);
  isFirst = zeros(nTrial, 1);
  
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
      % choose indices when fixation is in ROI and not on black pixel (having value 0)
      faceIndicesAmongRoiIndices = any( impixel(maskImage, ix, iy), 2);  
      roiIndices = roiIndices(faceIndicesAmongRoiIndices); 
    end
    timeInRegion(iTrial) = sum(trial(iTrial).t(roiIndices));
    numFixInRegion(iTrial) = length(roiIndices);
    isFirst(iTrial) = nnz(roiIndices == 1);
  end  
end  