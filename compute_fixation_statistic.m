function stimulStat = compute_fixation_statistic(fixationStruct, screenRect, imageRect, eyesRect, mouthRect, stimulImage) 
  [stimulStat.timeTotal, stimulStat.numFixTotal] = compute_time_in_region(fixationStruct, screenRect);
  [stimulStat.timeInROI, stimulStat.numFixInROI] = compute_time_in_region(fixationStruct, imageRect);
  [stimulStat.timeOnEyes, stimulStat.numFixOnEyes] = compute_time_in_region(fixationStruct, eyesRect); 
  [stimulStat.timeOnMouth, stimulStat.numFixOnMouth] = compute_time_in_region(fixationStruct, mouthRect); 
  
  stimulStat.shareTimeInROI = stimulStat.timeInROI./stimulStat.timeTotal;
  stimulStat.shareTimeOnEyes = stimulStat.timeOnEyes./stimulStat.timeTotal;  
  stimulStat.shareTimeOnMouth = stimulStat.timeOnMouth./stimulStat.timeTotal; 
  stimulStat.shareFixInROI = stimulStat.numFixInROI./stimulStat.numFixTotal;
  stimulStat.shareFixOnEyes = stimulStat.numFixOnEyes./stimulStat.numFixTotal;    
  stimulStat.shareFixOnMouth = stimulStat.numFixOnMouth./stimulStat.numFixTotal;    
  
  stimulStat.totalShareTimeInROI = sum(stimulStat.timeInROI)/sum(stimulStat.timeTotal);
  stimulStat.totalShareTimeOnEyes = sum(stimulStat.timeOnEyes)/sum(stimulStat.timeTotal);  
  stimulStat.totalShareTimeOnMouth = sum(stimulStat.timeOnMouth)/sum(stimulStat.timeTotal);  
  stimulStat.totalShareFixInROI = sum(stimulStat.numFixInROI)/sum(stimulStat.numFixTotal);
  stimulStat.totalShareFixOnEyes = sum(stimulStat.numFixOnEyes)/sum(stimulStat.numFixTotal);    
  stimulStat.totalShareFixOnMouth = sum(stimulStat.numFixOnMouth)/sum(stimulStat.numFixTotal);    
  
  %preallocate trialIndices (filled outside of the function)
  stimulStat.trialIndex = 1:length(stimulStat.timeTotal);
  
  if (nargin > 4) %if facial image is passed - compute fixations on face as well  
    [stimulStat.timeOnFace, stimulStat.numFixOnFace] = compute_time_in_region(fixationStruct, imageRect, stimulImage);
    stimulStat.shareTimeOnFace = stimulStat.timeOnFace./stimulStat.timeTotal;
    stimulStat.shareFixOnFace = stimulStat.numFixOnFace./stimulStat.numFixTotal;
    
    stimulStat.totalShareTimeOnFace = sum(stimulStat.timeOnFace)/sum(stimulStat.timeTotal);
    stimulStat.totalShareFixOnFace = sum(stimulStat.numFixOnFace)/sum(stimulStat.numFixTotal);
  end
end