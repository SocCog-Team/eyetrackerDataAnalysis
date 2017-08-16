function [x, y, t] = merge_trial_data(trial)
  x = [trial(:).x];
  y = [trial(:).y];
  t = [trial(:).t];
end  