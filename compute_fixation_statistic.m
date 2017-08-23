function stat = compute_fixation_statistic(fixationStruct, pValue, screenRect, imageRect, eyesRect, mouthRect, stimulImage) 
  regionName = {'ROI', 'Eyes', 'Mouth', 'Face' };
  regionRect = {imageRect, eyesRect, mouthRect};
  [stat.timeTotal, stat.numFixTotal] = compute_time_in_region(fixationStruct, screenRect);

  for iRegion = 1:length(regionRect)
    region = regionName{iRegion};
    [stat.(['timeOn' region]), stat.(['numFixOn' region])] = compute_time_in_region(fixationStruct, regionRect{iRegion});
  end  
  
  if (nargin > 4) %if facial image is passed - compute fixations on face as well  
    [stat.timeOnFace, stat.numFixOnFace] = compute_time_in_region(fixationStruct, imageRect, stimulImage);
    nRegion = 4;
  else
    nRegion = 3;
  end
  
  
  for iRegion = 1:nRegion
    region = regionName{iRegion};
    stat.(['shareTimeOn' region]) = stat.(['timeOn' region])./stat.timeTotal;
    stat.(['shareFixOn' region]) = stat.(['numFixOn' region])./stat.numFixTotal;
    
    stat.(['totalShareTimeOn' region]) = sum(stat.(['timeOn' region]))/sum(stat.timeTotal);
    stat.(['totalShareFixOn' region]) = sum(stat.(['numFixOn' region]))/sum(stat.numFixTotal);

    normalizedTime = stat.(['timeOn' region])./mean(stat.timeTotal);
    stat.(['confIntTimeOn' region]) = calc_cihw(std(normalizedTime), length(normalizedTime), pValue);    
    normalizedFixNum = stat.(['numFixOn' region])./mean(stat.numFixTotal);    
    stat.(['confIntFixOn' region])  = calc_cihw(std(normalizedFixNum), length(normalizedFixNum), pValue); 
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
    [stat.timeOnFace, stat.numFixOnFace] = compute_time_in_region(fixationStruct, imageRect, stimulImage);
    stat.shareTimeOnFace = stat.timeOnFace./stat.timeTotal;
    stat.shareFixOnFace = stat.numFixOnFace./stat.numFixTotal;
    
    stat.totalShareTimeOnFace = sum(stat.timeOnFace)/sum(stat.timeTotal);
    stat.totalShareFixOnFace = sum(stat.numFixOnFace)/sum(stat.numFixTotal);
  end
%}  
end