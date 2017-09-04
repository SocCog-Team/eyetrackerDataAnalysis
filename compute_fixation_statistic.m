function stat = compute_fixation_statistic(fixationStruct, pValue, screenRect, imageRect, eyesRect, mouthRect, stimulImage) 
% compute_fixation_statistic computes durations and number of fixations in various regions, 
% for every trial and total (over all trials, mean and confidence intervals))
%
% SYNTAX
%     [stat] = compute_time_in_region(fixationStruct, pValue, screenRect, imageRect, eyesRect, mouthRect, stimulImage);
% INPUT
%   - fixationStruct - array of nTrial structures, having as fields x, y  and t arrays 
%     (centre and duration of fixation)
%		- pValue - probability value for computing confidence intervals
%		- screenRect, imageRect, eyesRect, mouthRect - rectangles specifying boundaries of ROI 
%   - stimulImage - (optional) image used to compute fixations on face (excluding black areas from imageRect)
% OUTPUT:
%   - stat - statistics of durtions and numbers of fixations for given stimuli
%
% EXAMPLE of use    
%
  regionName = {'ROI', 'Eyes', 'Mouth', 'Face' };
  regionRect = {imageRect, eyesRect, mouthRect};
  [stat.timeTotal, stat.numFixTotal] = compute_fixation_in_region(fixationStruct, screenRect);

  for iRegion = 1:length(regionRect)
    region = regionName{iRegion};
    [stat.(['timeOn' region]), stat.(['numFixOn' region]), stat.(['isFirstFixOn' region])] ...
          = compute_fixation_in_region(fixationStruct, regionRect{iRegion});
  end  
  
  if (nargin > 6) %if facial image is passed - compute fixations on face as well  
    [stat.timeOnFace, stat.numFixOnFace, stat.isFirstFixOnFace] = compute_fixation_in_region(fixationStruct, imageRect, stimulImage);
    nRegion = 4;
  else
    nRegion = 3;
  end  
  
  for iRegion = 1:nRegion
    region = regionName{iRegion};
    % compute shares of duration and number of fixation in the region
    stat.(['shareTimeOn' region]) = stat.(['timeOn' region])./stat.timeTotal;
    stat.(['shareFixOn' region]) = stat.(['numFixOn' region])./stat.numFixTotal;
    
    % compute overall shares of duration and number of fixation in the region
    stat.(['totalShareTimeOn' region]) = sum(stat.(['timeOn' region]))/sum(stat.timeTotal);
    stat.(['totalShareFixOn' region]) = sum(stat.(['numFixOn' region]))/sum(stat.numFixTotal);
    
    % compute confidence intervals for duration and number of fixation
    normalizedTime = stat.(['timeOn' region])/mean(stat.timeTotal);
    stat.(['confIntTimeOn' region]) = calc_cihw(std(normalizedTime), length(normalizedTime), pValue);    
    normalizedFixNum = stat.(['numFixOn' region])/mean(stat.numFixTotal);    
    stat.(['confIntFixOn' region])  = calc_cihw(std(normalizedFixNum), length(normalizedFixNum), pValue);

    % comute frequency of first fixation in the region
    stat.(['freqFirstFixOn' region]) = mean(stat.(['isFirstFixOn' region]));    
  end
  
  %preallocate trialIndices (filled outside of the function)
  stat.trialIndex = 1:length(stat.timeTotal);
  
  %{    
  stat.totalShareTimeInROI = sum(stat.timeInROI)/sum(stat.timeTotal);
  stat.totalShareTimeOnEyes = sum(stat.timeOnEyes)/sum(stat.timeTotal);  
  stat.totalShareTimeOnMouth = sum(stat.timeOnMouth)/sum(stat.timeTotal);  
  stat.totalShareFixInROI = sum(stat.numFixInROI)/sum(stat.numFixTotal);
  stat.totalShareFixOnEyes = sum(stat.numFixOnEyes)/sum(stat.numFixTotal);    
  stat.totalShareFixOnMouth = sum(stat.numFixOnMouth)/sum(stat.numFixTotal);    
  
  %preallocate trialIndices (filled outside of the function)
  stat.trialIndex = 1:length(stat.timeTotal);
  
  if (nargin > 4) %if facial image is passed - compute fixations on face as well  
    [stat.timeOnFace, stat.numFixOnFace] = compute_fixation_in_region(fixationStruct, imageRect, stimulImage);
    stat.shareTimeOnFace = stat.timeOnFace./stat.timeTotal;
    stat.shareFixOnFace = stat.numFixOnFace./stat.numFixTotal;
    
    stat.totalShareTimeOnFace = sum(stat.timeOnFace)/sum(stat.timeTotal);
    stat.totalShareFixOnFace = sum(stat.numFixOnFace)/sum(stat.numFixTotal);
  end
%}  
end