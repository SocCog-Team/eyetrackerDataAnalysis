function [] = fn_plot_gaze_by_datasource_event_trialsubtype( session_ID, event_name_list, subject_name, trackertype, data_basedir, InvisibleFigures )

%this is the directory to get to the data files. we use fullfile so it will
%add the correct slash independent of computer. even name is changed with
%t

timestamps.(mfilename).start = tic;
disp(['Starting: ', mfilename]);
dbstop if error
fq_mfilename = mfilename('fullpath');
% mfilepath = fileparts(fq_mfilename);


% no GUI means no figure windows possible, so try to work around that
if ~exist('InvisibleFigures', 'var') || isempty(InvisibleFigures)
	InvisibleFigures = 0;
end

if (fnIsMatlabRunningInTextMode())
	InvisibleFigures = 1;
end
if (InvisibleFigures)
	figure_visibility_string = 'off';
	disp('Using invisible figures, for speed.');
else
	figure_visibility_string = 'on';
	disp('Using visible figures, for debugging/formatting.');
end
plotting_options.figure_visibility_string = figure_visibility_string;

output_format_string = '.pdf';
plotting_options.panel_width_cm = 15;
plotting_options.panel_height_cm = 12;
plotting_options.margin_cm = 1;
ci_alpha = 0.05;


% colors for side choices as objective Sides (from perspective of A)
% these work, but are pretty garish...
colors.Al = [1 0 0];
colors.Ar = [0 1 0];
colors.Bl = [1 0 1];
colors.Br = [0 0 1];
% https://colorbrewer2.org/#type=diverging&scheme=BrBG&n=4
colors.Al = [230,97,1]/255; % orange
colors.Ar = [94,60,153]/255;% purple
colors.Bl = [166,97,26]/255;% brown/beige
colors.Br = [1,133,113]/255;% tan/teal greenish


if ~exist('session_ID', 'var') || isempty(session_ID)
	session_ID = '20230623T124557.A_Curius.B_Elmo.SCP_01';
	session_ID = '20210423T105645.A_Elmo.B_KN.SCP_01';
end

if ~exist('event_name_list', 'var') || isempty(event_name_list)
	% 'A_TargetOnsetTime_ms', 'A_GoSignalTime_ms', 'B_GoSignalTime_ms', 	'A_InitialFixationReleaseTime_ms', 'B_InitialFixationReleaseTime_ms','A_TargetTouchTime_ms', 'B_TargetTouchTime_ms'
	%event_name_list = {'A_TargetTouchTime_ms'};
	event_name_list = {'A_TargetOnsetTime_ms', 'A_GoSignalTime_ms', 'B_GoSignalTime_ms', 'A_InitialFixationReleaseTime_ms', 'B_InitialFixationReleaseTime_ms','A_TargetTouchTime_ms', 'B_TargetTouchTime_ms'};
end

if ~exist('subject_name', 'var') || isempty(subject_name)
	% Curius or Elmo
	subject_name = 'Elmo';
end

if ~exist('trackertype', 'var') || isempty(trackertype)
	% Curius or Elmo
	trackertype = '*'; % eyelink or pupillabs
end


% parse the session ID to get easy acces to its components
session_info = fn_parse_session_id(session_ID);
side_string = [];

if strcmp(session_info.subject_A, subject_name)
	side_string = 'A';
end
if strcmp(session_info.subject_B, subject_name)
	side_string = 'B';
end
if isempty(side_string)
	error([mfilename, ': Requested subject name does not exist in this session:', subject_name]);
end


if ~exist('data_basedir', 'var') || isempty(data_basedir)
	data_basedir = fullfile('Y:', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', session_info.year_string, session_info.YYMMDD_string, [session_ID, '.sessiondir'], 'GAZE_TOUCH');
	if isunix
		data_basedir = fullfile('/', 'Volumes', 'snd', 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', session_info.year_string, session_info.YYMMDD_string, [session_ID, '.sessiondir'], 'GAZE_TOUCH');
	end
end

stat_struct = struct();
% loop over events
for i_event = 1 : length(event_name_list)
	event_name = event_name_list{i_event};
	disp(['Processing: ', event_name]);

	% GAZE.20230623T124557.A_Curius.B_Elmo.SCP_01.Curius.A.pupillabs.PreMS_2000.PostMS_2000.EVENTID_A_TargetTouchTime_ms.event_aligned_trial_table
	% GAZE.20230623T124557.A_Curius.B_Elmo.SCP_01.Elmo.B.pupillabs.PreMS_2000.PostMS_2000.EVENTID_A_TargetTouchTime_ms.event_aligned_trial_table

	% data_file_name = 'GAZE.table.SESSID_20230623T124557.A_Curius.B_Elmo.SCP_01.SUBID_Curius.SIDEID_A.TRACKERID_pupillabs.PreMS_2000.PostMS_2000.EVENTID_A_GoSignalTime_ms.event_aligned_trial_table.mat';
	% data_file_name = 'GAZE.table.SESSID_20230623T124557.A_Curius.B_Elmo.SCP_01.EVENTID_A_TargetOnsetTime_ms.event_aligned_trial_table.mat';

	%In one session' elmo vs curius
	% data_file_name_stem_Curius = ['GAZE.', session_ID, '.Curius.A.pupillabs.PreMS_2000.PostMS_2000.EVENTID_'];
	% data_file_name_stem_Elmo = ['GAZE.', session_ID,'.Elmo.B.pupillabs.PreMS_2000.PostMS_2000.EVENTID_'];

	data_file_name_stem = ['GAZE.', session_ID, '.', subject_name, '.', side_string, '.', trackertype, '.PreMS_2000.PostMS_2000.EVENTID_'];
	data_file_name = [ data_file_name_stem, event_name, '.event_aligned_trial_table.mat'];
	if strcmp(trackertype, '*')
		data_file_name_dirstruct = dir(fullfile(data_basedir, event_name, data_file_name));
		if length(data_file_name_dirstruct) == 1
			data_file_name = data_file_name_dirstruct.name;
		end
	end


	% load the structuure called cur_PETH_struct from the filename constructed
	% by fullfile
	disp('Loading datafile, might take a while...');
	load(fullfile(data_basedir, event_name, data_file_name), 'cur_PETH_struct');

	datasource_names = fieldnames(cur_PETH_struct.data);
	datasource_prefix_list = [];
	if sum(ismember(datasource_names, {'RIGHT_EYE_RAW_resampled_registered_X', 'RIGHT_EYE_RAW_resampled_registered_Y'})) == 2
		datasource_prefix_list{end+1} = 'RIGHT_EYE_RAW';
	end
	if sum(ismember(datasource_names, {'LEFT_EYE_RAW_resampled_registered_X', 'LEFT_EYE_RAW_resampled_registered_Y'})) == 2
		datasource_prefix_list{end+1} = 'LEFT_EYE_RAW';
	end
	if sum(ismember(datasource_names, {'BINOCCULAR_RAW_resampled_registered_X', 'BINOCCULAR_RAW_resampled_registered_Y'})) == 2
		datasource_prefix_list{end+1} = 'BINOCCULAR_RAW';
	end


	% load information about the trials
	load(fullfile(data_basedir, [session_ID, '.trialinfo.mat']), 'TrialInfo_struct');


	% extract subsets of trials
	%cur_raster labels contain info about the sessions. we will use this to
	%separate files with different conditions
	TrialInfo_struct.cur_raster_labels.TrialSubType_list;

	% we get the list of subtypes
	[unique_instances, ~, instance_ID_by_trial] = unique(TrialInfo_struct.cur_raster_labels.TrialSubType_list);

	% here we are telling it to give us e.g. only the dyadic sessions
	if ismember('Dyadic', unique_instances)
		trialsubtypes.Dyadic_idx = find(instance_ID_by_trial == find(ismember(unique_instances, {'Dyadic'})));
	end
	if ismember('SoloARewardAB', unique_instances)
		trialsubtypes.SoloARewardAB_idx = find(instance_ID_by_trial == find(ismember(unique_instances, {'SoloARewardAB'})));
	end
	if ismember('SoloBRewardAB', unique_instances)
		trialsubtypes.SoloBRewardAB_idx = find(instance_ID_by_trial == find(ismember(unique_instances, {'SoloBRewardAB'})));
	end
	if ismember('SoloA', unique_instances)
		trialsubtypes.SoloA_idx = find(instance_ID_by_trial == find(ismember(unique_instances, {'SoloA'})));
	end
	if ismember('SoloB', unique_instances)
		trialsubtypes.SoloB_idx = find(instance_ID_by_trial == find(ismember(unique_instances, {'SoloB'})));
	end
	if ismember('SemiSolo', unique_instances)
		trialsubtypes.SemiSolo_idx = find(instance_ID_by_trial == find(ismember(unique_instances, {'SemiSolo'})));
	end
	% filter data by the choice of A
	[unique_instances, ~, instance_ID_by_trial] = unique(TrialInfo_struct.cur_raster_labels.A_LR_pos_list);
	Al_trial_idx = find(instance_ID_by_trial == find(ismember(unique_instances, {'Al'})));
	Ar_trial_idx = find(instance_ID_by_trial == find(ismember(unique_instances, {'Ar'})));

	% filter data by the choice of B
	[unique_instances, ~, instance_ID_by_trial] = unique(TrialInfo_struct.cur_raster_labels.B_LR_pos_list);
	Bl_trial_idx = find(instance_ID_by_trial == find(ismember(unique_instances, {'Bl'})));
	Br_trial_idx = find(instance_ID_by_trial == find(ismember(unique_instances, {'Br'})));

	% filter data by the timing of the go signal
	[unique_instances, ~, instance_ID_by_trial] = unique(TrialInfo_struct.cur_raster_labels.go_seq_1000_list);
	if ismember('ABgo', unique_instances)
		action_sequences.ABgo_idx = find(instance_ID_by_trial == find(ismember(unique_instances, {'ABgo'})));
	end
	if ismember('AgoB', unique_instances)
		action_sequences.AgoB_idx = find(instance_ID_by_trial == find(ismember(unique_instances, {'AgoB'})));
	end
	if ismember('BgoA', unique_instances)
		action_sequences.BgoA_idx = find(instance_ID_by_trial == find(ismember(unique_instances, {'BgoA'})));
	end
	action_sequence_list = fieldnames(action_sequences);



	%TODO
	% plot a tiledplot with:
	% columns different
	column_split_struct = action_sequences;
	column_name_list = fieldnames(column_split_struct);
	n_cols = length(column_name_list);


	% 	my_colors.RightEyeX_B_left = [1 0 0];
	% 	my_colors.RightEyeX_B_right = [0 1 0];

	%TODO loop over trial subsets, add legend...
	% we get the list of subtypes
	[trialsubtype_unique_instances, ~, trialsubtype_instance_ID_by_trial] = unique(TrialInfo_struct.cur_raster_labels.TrialSubType_list);
	for i_trialsubtype = 1 : length(trialsubtype_unique_instances)
		cur_trialsubtype = trialsubtype_unique_instances{i_trialsubtype};
		% skip trial sub type None, nothing to do here...
		if strcmp(cur_trialsubtype, 'None')
			continue
		end

		cur_trailsubtype_ldx = trialsubtype_instance_ID_by_trial == i_trialsubtype;
		cur_trailsubtype_idx = find(cur_trailsubtype_ldx);

		for i_datasource = 1 : length(datasource_prefix_list)
			cur_datasource_prefix = datasource_prefix_list{i_datasource};
			
			% also show vergence...
			if strcmp(cur_datasource_prefix, 'BINOCCULAR_RAW') && ismember({'BINOCCULAR_RAW_resampled_registered_ABDepthPix'}, datasource_names)
				n_rows = 3; % plot Y over X
				row_datasource_suffix_list = {'_resampled_registered_Y', '_resampled_registered_X', '_resampled_registered_ABDepthPix'};
				lines_for_X = [802, 849, 960 1072, 1119];
				lines_for_Y = [450, 550, 612, 389, 500];
				lines_for_Depth = [-50, -27.8, 0 27.8, 50];
				helper_lines_by_row = {lines_for_Y, lines_for_X, lines_for_Depth};
				YLim_by_row = {[(389-200) (612+200)], [(960-200) (960+200)], [(-60) (60)]};
				Y_label_by_row = {'Y position [pixel]', 'X position [pixel]', 'XYdiff +B/-A[pixel]'};
				plot_width_cm = (plotting_options.panel_width_cm * n_cols);
				plot_height_cm = (plotting_options.panel_height_cm * n_rows);
			else
				n_rows = 2; % plot Y over X
				row_datasource_suffix_list = {'_resampled_registered_Y', '_resampled_registered_X'};
				lines_for_X = [802, 849, 960 1072, 1119];
				lines_for_Y = [450, 550, 612, 389, 500];
				helper_lines_by_row = {lines_for_Y, lines_for_X};
				YLim_by_row = {[(389-200) (612+200)], [(960-200) (960+200)]};
				Y_label_by_row = {'Y position [pixel]', 'X position [pixel]'};
				plot_width_cm = (plotting_options.panel_width_cm * n_cols);
				plot_height_cm = (plotting_options.panel_height_cm * n_rows);
			end

			out_name = [subject_name, '_', event_name, '_', cur_trialsubtype,'_', cur_datasource_prefix, '_A'];
			cur_fh = figure('Name', out_name, 'Visible', plotting_options.figure_visibility_string);
			output_rect = fn_set_figure_outputpos_and_size(cur_fh, plotting_options.margin_cm, plotting_options.margin_cm, plot_width_cm, plot_height_cm, 1.0, 'portrait', 'inch');
			cur_th = tiledlayout(cur_fh, n_rows, n_cols);

			for i_colum = 1 : length(column_name_list)
				legend_text = {};
				for i_row = 1 : n_rows
					row_offset = n_cols * (i_row - 1);
					nexttile(i_colum + row_offset);

					
					current_column_name = column_name_list{i_colum};
					current_column_idx = column_split_struct.(current_column_name);
					included_trials_idx =  intersect(current_column_idx, cur_trailsubtype_idx);

					[ah, stat_struct.(event_name).(cur_trialsubtype).([cur_datasource_prefix, row_datasource_suffix_list{i_row}]).by_Al.data] = ...
						plot_data( cur_PETH_struct.info.realtive_x_time_ms, cur_PETH_struct.data.([cur_datasource_prefix, row_datasource_suffix_list{i_row}]), ...
							intersect(included_trials_idx, Al_trial_idx), helper_lines_by_row{i_row}, [0], colors.Al, ci_alpha);
					stat_struct.(event_name).(cur_trialsubtype).([cur_datasource_prefix, row_datasource_suffix_list{i_row}]).by_Al.x_vec_ms = cur_PETH_struct.info.realtive_x_time_ms;
					legend_text(end+1) = {'by Al'};
					[ah, stat_struct.(event_name).(cur_trialsubtype).([cur_datasource_prefix, row_datasource_suffix_list{i_row}]).by_Ar.data] = ...
						plot_data( cur_PETH_struct.info.realtive_x_time_ms, cur_PETH_struct.data.([cur_datasource_prefix, row_datasource_suffix_list{i_row}]), ...
							intersect(included_trials_idx, Ar_trial_idx), helper_lines_by_row{i_row}, [0], colors.Ar, ci_alpha);
					stat_struct.(event_name).(cur_trialsubtype).([cur_datasource_prefix, row_datasource_suffix_list{i_row}]).by_Ar.x_vec_ms = cur_PETH_struct.info.realtive_x_time_ms;
					legend_text(end+1) = {'by Ar'};
					% set(ah, 'YDir', 'reverse');
					title([current_column_name, ' ', cur_datasource_prefix,'; Al/Ar'], 'Interpreter', 'none', 'Fontsize', 14);
					%title ([subject_name, ' ' , event_name], 'Interpreter', 'none')
					subtitle({event_name, cur_trialsubtype}, 'Interpreter', 'none', 'Fontsize', 12);
					xlabel('Time');
					ylabel(Y_label_by_row{i_row});
					set(gca, 'YLim', YLim_by_row{i_row});
					%legend(legend_text,'Orientation','horizontal', 'Location', 'north');
				end
			end
			disp([mfilename, ': saving figure to ', fullfile(data_basedir, event_name, [out_name, output_format_string])]);
			write_out_figure(cur_fh, fullfile(data_basedir, event_name, [out_name, output_format_string]));


			out_name = [subject_name, '_', event_name, '_', cur_trialsubtype,'_', cur_datasource_prefix, '_B'];
			cur_fh = figure('Name', out_name, 'Visible', plotting_options.figure_visibility_string);
			output_rect = fn_set_figure_outputpos_and_size(cur_fh, plotting_options.margin_cm, plotting_options.margin_cm, plot_width_cm, plot_height_cm, 1.0, 'portrait', 'inch');

			cur_th = tiledlayout(cur_fh, n_rows, n_cols);

			for i_colum = 1 : length(column_name_list)
				legend_text = {};
				for i_row = 1 : n_rows
					row_offset = n_cols * (i_row - 1);
					nexttile(i_colum + row_offset);

					current_column_name = column_name_list{i_colum};
					current_column_idx = column_split_struct.(current_column_name);
					included_trials_idx =  intersect(current_column_idx, cur_trailsubtype_idx);

					[ah, stat_struct.(event_name).(cur_trialsubtype).([cur_datasource_prefix, row_datasource_suffix_list{i_row}]).by_Bl.data] = ...
						plot_data( cur_PETH_struct.info.realtive_x_time_ms, cur_PETH_struct.data.([cur_datasource_prefix, row_datasource_suffix_list{i_row}]), ...
							intersect(included_trials_idx, Bl_trial_idx), helper_lines_by_row{i_row}, [0], colors.Bl, ci_alpha);
							stat_struct.(event_name).(cur_trialsubtype).([cur_datasource_prefix, row_datasource_suffix_list{i_row}]).by_Bl.x_vec_ms = cur_PETH_struct.info.realtive_x_time_ms;
					legend_text(end+1) = {'by Bl'};
					[ah, stat_struct.(event_name).(cur_trialsubtype).([cur_datasource_prefix, row_datasource_suffix_list{i_row}]).by_Br.data] = ...
						plot_data( cur_PETH_struct.info.realtive_x_time_ms, cur_PETH_struct.data.([cur_datasource_prefix, row_datasource_suffix_list{i_row}]), ...
							intersect(included_trials_idx, Br_trial_idx), helper_lines_by_row{i_row}, [0], colors.Br, ci_alpha);
					stat_struct.(event_name).(cur_trialsubtype).([cur_datasource_prefix, row_datasource_suffix_list{i_row}]).by_Br.x_vec_ms = cur_PETH_struct.info.realtive_x_time_ms;
					legend_text(end+1) = {'by Br'};
					% set(ah, 'YDir', 'reverse');
					title([current_column_name, ' ', cur_datasource_prefix,'; Bl/Br'], 'Interpreter', 'none', 'Fontsize', 14);
					%title ([subject_name, ' ' , event_name], 'Interpreter', 'none')
					subtitle({event_name, cur_trialsubtype}, 'Interpreter', 'none', 'Fontsize', 12);
					xlabel('Time');
					ylabel(Y_label_by_row{i_row});
					set(gca, 'YLim', YLim_by_row{i_row});
					%legend(legend_text,'Orientation','horizontal', 'Location', 'north');
				end
			end
			disp([mfilename, ': saving figure to ', fullfile(data_basedir, event_name, [out_name, output_format_string])]);
			write_out_figure(cur_fh, fullfile(data_basedir, event_name, [out_name, output_format_string]));
		end % i_datasource
	end % i_trialsubtype
end % i_event

% save the collected stat struct...
cur_stat_struct_name = [session_ID, '.GAZE.statistic_summary.mat'];
cur_stat_struct_name_fqn = fullfile(data_basedir, cur_stat_struct_name);
disp([mfilename, ': saving collected statistics as ', cur_stat_struct_name, '; ', cur_stat_struct_name_fqn]);
save(cur_stat_struct_name_fqn, 'stat_struct');



if (InvisibleFigures)
	close all;
end

% clean up
timestamps.(mfilename).end = toc(timestamps.(mfilename).start);
disp([mfilename, ' took: ', num2str(timestamps.(mfilename).end), ' seconds.']);
disp([mfilename, ' took: ', num2str(timestamps.(mfilename).end / 60), ' minutes.']);
disp([mfilename, ' took: ', num2str(timestamps.(mfilename).end / (60 * 60)), ' hours.']);
disp([mfilename, ' took: ', num2str(timestamps.(mfilename).end / (60 * 60 * 24)), ' days. Done...']);
 
return
end


function [cur_ah, summary_stat_struct] = plot_data( x_vec, data_table, good_trial_idx, ylines, xlines, cur_color, ci_alpha )
cur_ah = gca;
hold on
for i_row = 1 : length(good_trial_idx)
	cur_row = good_trial_idx(i_row);
	patchline(x_vec, data_table(cur_row, :), 'edgecolor', cur_color, 'linewidth', 1, 'edgealpha', 0.05);
	%plot(cur_PETH_struct.info.realtive_x_time_ms, cur_PETH_struct.data.RIGHT_EYE_RAW_resampled_registered_X(cur_row, :))
end
for i_ylines = 1 : length(ylines)
	yline(ylines(i_ylines));
end
for i_xlines = 1 : length(xlines)
	xline(xlines(i_xlines));
end

% set(gcf, 'Visible', 'on');
[summary_stat_struct] = fn_calc_summary_stats(data_table(good_trial_idx, :), ci_alpha, 1, 'omitnan');
if ~isempty(ci_alpha)
	% plot the CI
	inverse_index = (length(x_vec):-1:1);
	current_x_vec_patch = [x_vec, x_vec(inverse_index)];
	tmp_upper_ci = (summary_stat_struct.mean + summary_stat_struct.ci_halfwidth);
	tmp_lower_ci = (summary_stat_struct.mean - summary_stat_struct.ci_halfwidth);
	% the confidence intervals as transparent patch...
	patch(cur_ah, 'XData', current_x_vec_patch, 'YData', [tmp_upper_ci, tmp_lower_ci(inverse_index)], 'FaceColor', cur_color, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
end

%mean_data = mean(data_table(good_trial_idx, :), 'omitnan');
plot(x_vec, summary_stat_struct.mean, 'Color', cur_color, 'linewidth', 2);

hold off

end