function analyse_initial_fixation(trial, fixationDetector, screenRect, fixPointRect)
  [fixationOnFix1, rawGazeOnFix1, ~] = get_gaze_pos(trial, 'fix1', 0, fixationDetector);
  [fixationOnFix2, rawGazeOnFix2, ~] = get_gaze_pos(trial, 'fix2', 0, fixationDetector);
  fixationOnFix1 = bound_gaze_pos(fixationOnFix1, screenRect);
  fixationOnFix2 = bound_gaze_pos(fixationOnFix2, screenRect);
  [x1, y1, t1] = merge_trial_data(fixationOnFix1);
  [x2, y2, t2] = merge_trial_data(fixationOnFix2);
  figure('Name', 'Initial fixations')
  subplot(2, 2, 1)
  set(gca, 'YDir', 'reverse');
  hold on;
  histogram2([rawGazeOnFix1(:).x], [rawGazeOnFix1(:).y], [500, 500],'DisplayStyle','tile','ShowEmptyBins','off');
  rectangle('Position',fixPointRect, 'Curvature',[1 1], 'EdgeColor', 'm', 'LineWidth', 2)  
  hold off;
  title('Fix 1, row gaze');
  subplot(2, 2, 2)
  set(gca, 'YDir', 'reverse');
  hold on;
  histogram2([rawGazeOnFix2(:).x], [rawGazeOnFix2(:).y], [500, 500],'DisplayStyle','tile','ShowEmptyBins','off');
  rectangle('Position',fixPointRect, 'Curvature',[1 1], 'EdgeColor', 'm', 'LineWidth', 2)
  hold off;
  title('Fix 2, row gaze');
  subplot(2, 2, 3)
  set(gca, 'YDir', 'reverse');
  hold on;
  gaussian_attention_map(x1, y1, fixationDetector.dispersionThreshold/4, t1, fixationDetector.durationThreshold);
  %plot_fixation(fixationOnFix1, fixationDetector.durationThreshold, fixationDetector.dispersionThreshold);
  rectangle('Position',fixPointRect, 'Curvature',[1 1], 'EdgeColor', 'm', 'LineWidth', 2);
  hold off;
  axis tight;
  title('Fix 1, fixations');
  subplot(2, 2, 4)
  set(gca, 'YDir', 'reverse');
  hold on;
  gaussian_attention_map(x2, y2, fixationDetector.dispersionThreshold/4, t2, fixationDetector.durationThreshold);
  %plot_fixation(fixationOnFix2, fixationDetector.durationThreshold, fixationDetector.dispersionThreshold);
  rectangle('Position',fixPointRect, 'Curvature',[1 1], 'EdgeColor', 'm', 'LineWidth', 2);
  hold off;
  axis tight;
  title('Fix 2, fixations');
end