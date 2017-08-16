function stimulFix = bound_gaze_pos(stimulFix, roi)
% for an array of fixation data in trials, bound_gaze_pos removes all x, y and t
% values lying outside of the specified ROI
%
% INPUT
%   - stimulFix - array of fixation data having x, y (coordinates) and t (duration) fields;
%   - roi - rectangle describing region of interest in format [left top width height] 
%   radius of fixation areas.
%
% OUTPUT:
%   - stimulFix - array of fixation data in trials, where fixations outside of roi are omitted 
%

  nTrial = length(stimulFix);
  for iTrial = 1:nTrial
    indexInScreen = (stimulFix(iTrial).x >= roi(1)) & (stimulFix(iTrial).y >= roi(2)) & ...
                    (stimulFix(iTrial).x < roi(1) + roi(3)) & ...
                    (stimulFix(iTrial).y < roi(2) + roi(4));     
    stimulFix(iTrial).x = stimulFix(iTrial).x(indexInScreen); 
    stimulFix(iTrial).y = stimulFix(iTrial).y(indexInScreen); 
    stimulFix(iTrial).t = stimulFix(iTrial).t(indexInScreen); 
  end  
end  