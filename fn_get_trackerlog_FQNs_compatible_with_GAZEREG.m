function [ compatible_trackerlog_fqn_list ] = fn_get_trackerlog_FQNs_compatible_with_GAZEREG( cur_GAZEREG_fqn, inputArg2)
%FN_GET_TRACKERLOG_FQNS_COMPATIBLE_WITH_GAZEREG Summary of this function goes here
%   Detailed explanation goes here

compatible_tracker_log_fqn_list = [];

find_all_files_verbosity = 0;
calibration_EVE_dir_match_string = ['*EyeTrackingCalibrator*.eve*'];


[cur_GAZEREG_dir, cur_GAZEREG_id] = fileparts(cur_GAZEREG_fqn);

% extract the GAZEREG_session _ID and compare date with session_info, take
% the last suitable registration... if multiple exist
gazereg_info = fn_parse_GAZEREG_id(cur_GAZEREG_id);
cur_gazereg_sessionID = gazereg_info.session_info.session_id;
compatible_trackerlog_fqn_list = find_all_files(cur_GAZEREG_dir, gazereg_info.trackerlog_match_string, find_all_files_verbosity);
% now prune this list by removing all entries from the calibration session
exclude_entry_list = logical(zeros([1, length(compatible_trackerlog_fqn_list)]));
for i_entry = 1 : length(compatible_trackerlog_fqn_list)
	% since we know this calibration session ID we remove it immediately
	if ~isempty(regexp(compatible_trackerlog_fqn_list{i_entry}, [cur_gazereg_sessionID, '.sessiondir']))
		exclude_entry_list(i_entry) = 1;
	end
	% check wether it is a calibration session, and exclude if it is
	[cur_entry_dir, ~, ~] = fileparts(compatible_trackerlog_fqn_list{i_entry});
	if ~isempty(dir(fullfile(cur_entry_dir, '..', calibration_EVE_dir_match_string)))
		exclude_entry_list(i_entry) = 1;
	end
	% reduce the name end to '.trackerlog' for automatic file handling
	compatible_trackerlog_fqn_list{i_entry} = regexprep(compatible_trackerlog_fqn_list{i_entry}, '\.trackerlog.*$', '.trackerlog');
	
end
compatible_trackerlog_fqn_list(exclude_entry_list) = [];
% remove duplicated entries (due to squashing of the true prefixes...)
compatible_trackerlog_fqn_list = unique(compatible_trackerlog_fqn_list);

return
end

