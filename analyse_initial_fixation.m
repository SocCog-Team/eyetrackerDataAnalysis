function analyse_initial_fixation(trial, fixationDetector, screenRect, fixPointRect)
% analyse_initial_fixation parses initial fixations in trials and
% plots distributions of raw gazes and fixations

stateName = {'fix1', 'fix2'};
stateCaption =  {'Fix 1', 'Fix 2'};
nFixState = length(stateName);
figure('Name', 'Initial fixations')
% first compute gazes and fixations before scrambled, then before true images
for iFixState = 1:nFixState
    [fixationOnFix, rawGazeOnFix, ~] = get_gaze_pos(trial, 'fix1', [], fixationDetector);
    fixationOnFix = bound_gaze_pos(fixationOnFix, screenRect);
    [x, y, t] = merge_trial_data(fixationOnFix);
    
    subplot(2, 2, 1)
    set(gca, 'YDir', 'reverse');
    hold on;
    histogram2([rawGazeOnFix(:).x], [rawGazeOnFix(:).y], [500, 500],'DisplayStyle','tile','ShowEmptyBins','off');
    rectangle('Position',fixPointRect, 'Curvature',[1 1], 'EdgeColor', 'm', 'LineWidth', 2)
    hold off;
    title([stateCaption{iFixState} ', raw gaze']);
    
    subplot(2, 2, 1 + nFixState)
    set(gca, 'YDir', 'reverse');
    hold on;
    gaussian_attention_map(x, y, fixationDetector.dispersionThreshold/2, t, fixationDetector.durationThreshold);
    rectangle('Position',fixPointRect, 'Curvature',[1 1], 'EdgeColor', 'm', 'LineWidth', 2);
    hold off;
    axis tight;
    title([stateCaption{iFixState} ', fixations']);
end
end