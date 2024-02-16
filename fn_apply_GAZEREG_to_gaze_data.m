function [ out_gaze_data_struct ] = fn_apply_GAZEREG_to_gaze_data( gaze_data_struct, calibration_set_struct, transformationType )
%FN_APPLY_GAZEREG_TO_GAZE_DATA Summary of this function goes here
%   Detailed explanation goes here

out_gaze_data_struct = gaze_data_struct;

tracker_type = [];
if ~isempty(regexpi(gaze_data_struct.info.tracker_name_from_filename, 'eyelink'))
	tracker_type = 'eyelink';
end
	
if ~isempty(regexpi(gaze_data_struct.info.tracker_name_from_filename, 'pupillabs'))
	tracker_type = 'pupillabs';
end

% from the gaze_data_struct
GAZERDATA_calibration_setID_list = gaze_data_struct.unique_lists.calibration_setID_sanitized;
% from the GAZEREG
GAZEREG_calibration_setID_list = fieldnames(calibration_set_struct);

n_samples_total = size(gaze_data_struct.data, 1);

transformed_gaze_data_array = [];

for i_calibration_set_ID = 1 : length(GAZEREG_calibration_setID_list)
	cur_calibration_set_ID = GAZEREG_calibration_setID_list{i_calibration_set_ID};
	% find the current calibration_set_id_name in the unique list and use
	% that idx to find all matching rows, those contain the data we want to
	% apply a specific calibration to...
	cur_GAZEDATA_caibration_ID_idx = find(ismember(GAZERDATA_calibration_setID_list, cur_calibration_set_ID));
	cur_cal_set_ID_data_idx = find(gaze_data_struct.data(:, gaze_data_struct.cn.calibration_setID_idx) == cur_GAZEDATA_caibration_ID_idx);
	
	cur_registration_struct = calibration_set_struct.(cur_calibration_set_ID).registration_struct;
	%check whether the requested registartion type exists
	if isfield(cur_registration_struct, transformationType) && ~isempty(cur_registration_struct.(transformationType))
		cur_columndata_stem_list = fieldnames(cur_registration_struct.(transformationType));
		cur_info_idx = find(ismember(cur_columndata_stem_list, 'info'));
		if ~isempty(cur_info_idx)
			cur_columndata_stem_list(cur_info_idx) = [];
		end
		
		% only create this once after we know the number of data columns
		if isempty(transformed_gaze_data_array)
			transformed_gaze_data_array = nan([n_samples_total, (length(cur_columndata_stem_list) * 2)]); % *2 as we always have X and Y data
			transformed_col_name_list = {};
		end
		
		% loop over all fields, but skip "info"
		for i_col_data = 1 : length(cur_columndata_stem_list)
			cur_columndata_stem = cur_columndata_stem_list{i_col_data};
			
			% to get the names of the columns this transfomation matrix
			% applies to
			cur_data_colnames = cur_registration_struct.(transformationType).(cur_columndata_stem).colnames;
			X_col_name = cur_data_colnames{find(contains(cur_data_colnames, 'Raw_X'))};
			Y_col_name = cur_data_colnames{find(contains(cur_data_colnames, 'Raw_Y'))};
			
			% where to put the data (needed for multi culumn formats like eyeling where each data table row contains data for left and right eye)
			cur_col_offset = (2 * (i_col_data - 1));
			
			if length(transformed_col_name_list) <= cur_col_offset || length(transformed_col_name_list) == 0
				transformed_col_name_list(1 + cur_col_offset) = {[transformationType, '_registered_', X_col_name]};
				transformed_col_name_list(2 + cur_col_offset) = {[transformationType, '_registered_', Y_col_name]};
			else
				if ~strcmp(transformed_col_name_list(1 + cur_col_offset), [transformationType, '_registered_', X_col_name])...
						|| ~strcmp(transformed_col_name_list(2 + cur_col_offset), [transformationType, '_registered_', Y_col_name])...
					error(['These names should probabaly match...']);
				end		
			end
			% select th correct columns...
			cur_out_col_list = [1 2] + cur_col_offset;
			% transform away
			transformed_gaze_data_array(cur_cal_set_ID_data_idx, cur_out_col_list) = ...
				transformPointsInverse(cur_registration_struct.(transformationType).(cur_columndata_stem).tform, ...
				[gaze_data_struct.data(cur_cal_set_ID_data_idx, gaze_data_struct.cn.(X_col_name)) ...
				gaze_data_struct.data(cur_cal_set_ID_data_idx, gaze_data_struct.cn.(Y_col_name))]);			
		end
	else
		disp([mfilename, '; WARN: No transformation struct found for requested tranformation type ', transformationType]);
		return
	end
	
end	%i_calibration_set_ID

% add columns (numeric array) and column names to the gaze_data_struct
out_gaze_data_struct = fn_handle_data_struct('add_columns', out_gaze_data_struct, transformed_gaze_data_array, transformed_col_name_list);

out_gaze_data_struct.GAZEREG.out_gaze_data_struct = out_gaze_data_struct;
out_gaze_data_struct.GAZEREG.tracker_type = tracker_type;


return
end

