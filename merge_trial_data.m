function [x, y, t] = merge_trial_data(trial)
% merges x, y and t fields for fixation or rawGaze data structures across all trials
  x = [trial(:).x];
  y = [trial(:).y];
  t = [trial(:).t];
end  