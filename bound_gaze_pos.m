function stimulFix = bound_gaze_pos(stimulFix, screenRect) 
  nTrial = length(stimulFix);
  for iTrial = 1:nTrial
    indexInScreen = (stimulFix(iTrial).x >= screenRect(1)) & (stimulFix(iTrial).y >= screenRect(2)) & ...
                    (stimulFix(iTrial).x < screenRect(1) + screenRect(3)) & ...
                    (stimulFix(iTrial).y < screenRect(2) + screenRect(4));     
    stimulFix(iTrial).x = stimulFix(iTrial).x(indexInScreen); 
    stimulFix(iTrial).y = stimulFix(iTrial).y(indexInScreen); 
    stimulFix(iTrial).t = stimulFix(iTrial).t(indexInScreen); 
  end  
end  