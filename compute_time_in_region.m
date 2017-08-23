function [timeInRegion, numFixInRegion] = compute_time_in_region(varargin)
% compute_time_in_region calculates total duration and amount of fixations
% in a specified region.
%
% SYNTAX
%     [timeInRegion, numFixInRegion] = compute_time_in_region(x, y, t, roiRect);
%     [timeInRegion, numFixInRegion] = compute_time_in_region(trial, roiRect);
% INPUT
%   - x - x-coordinates of fixation centres, N-element vector;
%   - y - y-coordinates of fixation centres, N-element vector;
%		- t - fixation durations, N-element vector.

%		- roiRect - rectangle describing region of interest in format [left top width height]
%		4-element vector in format [left top width height]. Required if presentedImage is specified
% OUTPUT:
%   - timeInRegion - total time of fixations in roiRect
%   - numFixInRegion - total number of fixations in roiRect
%
% EXAMPLE of use 
% fixationDetector = struct('method', 'dispersion-based', ...
%                          'dispersionThreshold', 30, ...
%                          'durationThreshold', 120);
% imageRect = [imageLeft imageTop imageWidth imageHeight]
% originalImage = imread('stimulImage.png');
% scaledImage = imresize(originalImage,[imageHeight imageWidth]); 
% %get fixation data in x, y, t
% figure
% gaussian_attention_map(x, y, fixationDetector.dispersionThreshold/2, t, 
%                              fixationDetector.durationThreshold, scaledImage, imageRect);      
%

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