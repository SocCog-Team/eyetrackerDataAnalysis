function gaussian_attention_map(x, y, sigma, varargin)
% gaussian_attention_map draws fixation areas as 2D Gaussian distributions 
% around central point. If background image is provided, attention map is overlayed with it.
%
% INPUT
%   - x - x-coordinates of fixation centres, N-element vector;
%   - y - y-coordinates of fixation centres, N-element vector;
%   - sigma - standard deviation of Gaussian distribution, scalar. Controls 
%   radius of fixation areas.

% OPTIONAL INPUT (these values may be omitted)
%		- t - fixation durations, N-element vector. Optional, controls color intensity
%		 of fixation area. 
%   - minT - minimal fixation duration, scalar. Required if t is specified, normalises t
%		- presentedImage - background image. Optional, if specified, it is overlayed with attention area.
%		- roiRect - coordinates of presentedImage in the coordinate system of
%		fixations.  Required if presentedImage is specified
% OUTPUT:
%   - 
%
% EXAMPLE of use 
% imshow(finalImage, refFinalImage)
%

  nVarargs = length(varargin);
  nFixation = length(x);
  doOverlay = false;
  
  %determine boundaries of fixation map
  minX = min(x) - 3*sigma;
  minY = min(y) - 3*sigma;
  maxX = max(x) + 3*sigma;
  maxY = max(y) + 3*sigma;  
  
  if (nVarargs > 0) % additional parameters are passed
    if (length(varargin{1}) == nFixation) % varargin{1} contains fixation durations
      minT = varargin{2};
      % t = minT, 2*minT, 4*minT are mapped to intensities 1, 1.5 and 2; 
      intensity = 1 + log2(varargin{1}/minT)/2;
      imagePoseInArgList = 3; %if image filenme is passed, it should be at varargin{3}
    else %otherwise varargin{1} should be the image filename
      intensity = 2*one(size(x));
      imagePoseInArgList = 1;
    end
    % normalize intensities so that for minimal duration of fixation
    % we have 0.8 in the center of the fixation circle after gaussian filtering
    % The formula comes from the fact that for sigma = 4, in the center we have 0.01*intensity
    intensity = 80*intensity*(sigma/4)^2; 
    
    if (nVarargs >= imagePoseInArgList)
      % if image filename specified we overlay the image with the attention map
      doOverlay = true;
      presentedImage =  varargin{imagePoseInArgList};
      %get coordinates of the image in the coordinate system of fixations
      roiRect =  varargin{imagePoseInArgList + 1};
      imageSize = size(presentedImage);
      roiRect(3) = imageSize(2);  %just in case replace sizes with the actual size of image
      roiRect(4) = imageSize(1);
      
      %determine joint boundaries of fixations and the presented image
      minX = min(minX, roiRect(1));
      minY = min(minY, roiRect(2));
      maxX = max(maxX, roiRect(1) + roiRect(3));
      maxY = max(maxY, roiRect(2) + roiRect(4));   
    end
  end 
 
 % create fixationMap as a set of gaussian distributed values 
 % centered in x,y, having expectation intensity and std sigma  
 fullImageHeight = ceil(maxY - minY);
 fullImageWidth = ceil(maxX - minX); 
 fixationCentresMap = zeros(fullImageHeight, fullImageWidth); 
 ix = round(x - minX) + 1;
 iy = round(y - minY) + 1;   
 fixationCentresMap(sub2ind(size(fixationCentresMap), iy, ix)) = intensity;
 fixationMap = imgaussfilt(fixationCentresMap, sigma, 'FilterSize', 2*ceil(3*sigma)+1);

 %create transparencyMap from fixationMap
 maxTransperentValue = 2/3;
 transparencyMap = maxTransperentValue*fixationMap;
 transparencyMap(fixationMap > 1) = maxTransperentValue;
 
 % create fixationMap image from mapImage
 fixationMap(fixationMap > 2.56) = 2.56; 
 %fixationImage = ind2rgb(uint8(100*fixationMap), jet(256));
 fixationImage = ind2rgb(uint8(100*fixationMap), parula(256));
 refFinalImage = imref2d(size(fixationMap));
 refFinalImage.XWorldLimits = [minX maxX];
 refFinalImage.YWorldLimits = [minY maxY];

  if (doOverlay)    
    %copy presented image to the full size canvas    
    fullImage = zeros(fullImageHeight, fullImageWidth, 3, 'uint8');
    x0 = round(roiRect(1) - minX) + 1;
    y0 = round(roiRect(2) - minY) + 1;    
    fullImage(y0:y0+roiRect(4)-1, x0:x0+roiRect(3)-1, :) = presentedImage;
    
    %draw fixations using alpha channel
    hold on 
    imshow(fullImage, refFinalImage);  
    h = imshow(fixationImage, refFinalImage); 
    hold off
    set(h, 'AlphaData', transparencyMap) 
    
    %draw fixations using overlay
    %[finalImage, refFinalImage] = imfuse(mapImage, refMapImage, presentedImage, refPresentedImage, 'falsecolor', 'ColorChannels', [1 2 2]);
    %imshow(finalImage, refFinalImage);
  else
    imshow(fixationImage, refFinalImage);
  end  
end
%figure; imshow(mapImage, refMapImage)
%figure; imshow(presentedImage, refPresentedImage)

