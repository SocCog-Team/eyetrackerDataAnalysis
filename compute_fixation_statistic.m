function stat = compute_fixation_statistic(fixationStruct, pValue, screenRect, imageRect, eyesRect, mouthRect) 
% compute_fixation_statistic computes durations and number of fixations 
% for the whole face, eye and mouth regions
% for each trial and total over all trials (mean and confidence intervals)
%
% INPUT
%   - fixationStruct - array of nTrial structures, having as fields x, y  and t arrays 
%     (centre and duration of fixation)
%		- pValue - probability value for computing confidence intervals
%		- screenRect, imageRect, eyesRect, mouthRect - rectangles specifying boundaries of ROI 
%   - stimulImage - (optional) image used to compute fixations on face (excluding black areas from imageRect)
% OUTPUT:
%   - stat - statistics of durtions and numbers of fixations for given stimuli
%

  regionName = {'Face', 'Eyes', 'Mouth'};  
  nRegion = length(regionName);  
  regionRect = {imageRect, eyesRect, mouthRect};
  
  % compute total number of fixations on the screen
  [stat.timeTotal, stat.numFixTotal] = compute_fixation_in_region(fixationStruct, screenRect);

  for iRegion = 1:nRegion
    region = regionName{iRegion};
    [stat.(['timeOn' region]), stat.(['numFixOn' region]), stat.(['isFirstFixOn' region])] ...
          = compute_fixation_in_region(fixationStruct, regionRect{iRegion});

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

    % compute frequency of first fixation in the region
    stat.(['freqFirstFixOn' region]) = mean(stat.(['isFirstFixOn' region]));    
  end
  
  %preallocate trialIndices (filled outside of the function)
  stat.trialIndex = (1:length(stat.timeTotal))'; 
end