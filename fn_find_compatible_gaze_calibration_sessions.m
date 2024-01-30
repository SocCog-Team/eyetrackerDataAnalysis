function [ GAZEREG_FQN_list, GAZEREG_sessiondir_list, compatible_calibration_trackerlog_fqn_list, non_recalibrated_calibration_trackerlog_fqn_list ] = fn_find_compatible_gaze_calibration_sessions( cur_tracker_log_fqn )
%FN_FIND_GAZE_CALIBRATION_COMPATIBLE_SESSIONS Summary of this function goes here
%   Detailed explanation goes here
% for a given trackerlog file return compatible calibration sessions

find_all_files_verbosity = 0;
calibration_EVE_dir_match_string = ['*EyeTrackingCalibrator*.eve*'];


% get some information for the current trackerlog file...
[trackerlog_dir_fqn, trackerlog_name, trackerlog_ext] = fileparts(cur_tracker_log_fqn);
trackerlog_name_ext = [trackerlog_name, trackerlog_ext];
trackerlog_info = fn_parse_trackerlog_name(trackerlog_name_ext);


session_dir_fqn = fileparts(trackerlog_dir_fqn);
[session_dir, cur_session_id, session_ext] = fileparts(session_dir_fqn);
session_info = fn_parse_session_id(cur_session_id);


trackerlog_file_match_string = [session_info.YYYYMMDD_string, 'T', '*', session_info.(['subject_', trackerlog_info.SIDEID, '_string']), '*', '.TID_', trackerlog_info.TID, '.trackerlog', '.*'];


% find the gaze calibration sessions by looking at EVE file names
% containing the following match string ['*EyeTrackingCalibrator*.eve*']
proto_GAZEREG_sessiondir_list = find_all_files(session_dir, calibration_EVE_dir_match_string, find_all_files_verbosity);

% make sure the expected trackerlog file exists as well and is large enough
exclude_entry_list = logical(zeros([1, length(proto_GAZEREG_sessiondir_list)]));
for i_entry = 1 : length(proto_GAZEREG_sessiondir_list)
	cur_session_dir = fileparts(proto_GAZEREG_sessiondir_list{i_entry});
	if isempty(find_all_files(fullfile(cur_session_dir, 'trackerlogfiles'), trackerlog_file_match_string, find_all_files_verbosity))
		exclude_entry_list(i_entry) = 1;
	end
	proto_GAZEREG_sessiondir_list{i_entry} = cur_session_dir;
end
GAZEREG_sessiondir_list = proto_GAZEREG_sessiondir_list(~exclude_entry_list);
if ~iscell(GAZEREG_sessiondir_list)
	GAZEREG_sessiondir_list = {GAZEREG_sessiondir_list};
end

compatible_calibration_trackerlog_fqn_list = [];
for i_GAZEREG_sessiondir = 1 : length(GAZEREG_sessiondir_list)
	%cur_session_dir = fileparts(proto_GAZEREG_sessiondir_list{i_GAZEREG_sessiondir});
	cur_session_dir = GAZEREG_sessiondir_list{i_GAZEREG_sessiondir};
	cur_compatible_trackerlog_fqn_list = find_all_files(fullfile(cur_session_dir, 'trackerlogfiles'), trackerlog_file_match_string, find_all_files_verbosity);
	compatible_calibration_trackerlog_fqn_list = [compatible_calibration_trackerlog_fqn_list, cur_compatible_trackerlog_fqn_list];
end

% reduce the name end to '.trackerlog' for automatic file handling
compatible_calibration_trackerlog_fqn_list = regexprep(compatible_calibration_trackerlog_fqn_list, '\.trackerlog.*$', '.trackerlog');
compatible_calibration_trackerlog_fqn_list = unique(compatible_calibration_trackerlog_fqn_list);
if ~iscell(compatible_calibration_trackerlog_fqn_list)
	compatible_calibration_trackerlog_fqn_list = {compatible_calibration_trackerlog_fqn_list};
end

% find for which files we have existing GAZEREG_files and hence are already
% recaliibrated...
recalibrated_compatible_calibration_trackerlog_ldx = logical(zeros([1 length(compatible_calibration_trackerlog_fqn_list)]));
for i_compatible_calibration_trackerlog =  1: length(compatible_calibration_trackerlog_fqn_list)
	cur_compatible_calibration_trackerlog_fqn = compatible_calibration_trackerlog_fqn_list{i_compatible_calibration_trackerlog};
	
	[tmp_trackerlog_dir_fqn, tmp_trackerlog_name, tmp_trackerlog_ext] = fileparts(cur_compatible_calibration_trackerlog_fqn);
	tmp_trackerlog_info = fn_parse_trackerlog_name([tmp_trackerlog_name, tmp_trackerlog_ext]);
	% only search in the current directory
	if ~isempty(dir(fullfile(tmp_trackerlog_dir_fqn, tmp_trackerlog_info.GAZEREG_match_string)))
		recalibrated_compatible_calibration_trackerlog_ldx(i_compatible_calibration_trackerlog) = 1;
	end
end
non_recalibrated_compatible_calibration_trackerlog_ldx = ~recalibrated_compatible_calibration_trackerlog_ldx;
non_recalibrated_calibration_trackerlog_fqn_list = compatible_calibration_trackerlog_fqn_list(non_recalibrated_compatible_calibration_trackerlog_ldx);

% find the list of all GAZEREG files in rge day's directory
GAZEREG_FQN_list = find_all_files(session_dir, trackerlog_info.GAZEREG_match_string, find_all_files_verbosity);
% keep one copy per GAZEREG (these exist at least twice) for book keeping
% use th






return
end

