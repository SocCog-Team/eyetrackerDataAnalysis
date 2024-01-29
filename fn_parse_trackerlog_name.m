function [ trackerlog_info ] = fn_parse_tarckerlog_name( orig_trackerlog_name )
%FN_PARSE_TARCKERLOG_NAME Summary of this function goes here
%   Detailed explanation goes here

% eg: 20240109T151424.A_AM.B_BA.SCP_01.TID_PupilLabsTrackerA.trackerlog

trackerlog_info = struct();

[~, trackerlog_name, extension] = fileparts(orig_trackerlog_name);

if ~strcmp(extension, '.trackerlog')
	error([mfilename,': trackerlog_name should end in ''.trackerlog'', but does end in: ', extension]);
	return
end





%ALLCAPS_identifier_list_revresed = {'.TRACKERELEMENTID_', '.SUBJECTID_', '.SIDE_', '.SID_', 'GAZEREGv'};
ALLCAPS_identifier_list_revresed = {'.TID_'};

processed_trackerlog_name = trackerlog_name;

for i_AC_identifier = 1 : length(ALLCAPS_identifier_list_revresed)
	cur_AC_identifier = ALLCAPS_identifier_list_revresed{i_AC_identifier};
	identifier_start_idx = strfind(trackerlog_name, cur_AC_identifier);

	sanitized_cur_AC_identifier = regexprep(cur_AC_identifier, '^\.', '');
	sanitized_cur_AC_identifier = regexprep(sanitized_cur_AC_identifier, '\_$', '');

	trackerlog_info.(sanitized_cur_AC_identifier) = processed_trackerlog_name((identifier_start_idx + length(cur_AC_identifier)):end);
	
	processed_trackerlog_name(identifier_start_idx:end) = [];
end	

trackerlog_info.SESSIONID = processed_trackerlog_name;
trackerlog_info.SIDEID = trackerlog_info.TID(end);
trackerlog_info.session_info = fn_parse_session_id(trackerlog_info.SESSIONID);
trackerlog_info.SUBJECTID = trackerlog_info.session_info.(['subject_', trackerlog_info.SIDEID]);

if ~isempty(regexp(lower(trackerlog_info.TID), 'eyelink'))
	trackerlog_info.TRACKERID = 'eyelink';
end
if ~isempty(regexp(lower(trackerlog_info.TID), 'pupillabs'))
	trackerlog_info.TRACKERID = 'pupillabs';
end
if ~isempty(regexp(lower(trackerlog_info.TID), 'pqlabtracker'))
	trackerlog_info.TRACKERID = 'pqlabs';
end	
	

% output_mat_filename = ['GAZEREGv03.SESSIONID_', sessionID, '.SIDEID_', side, '.SUBJECTID_', subject_name, '.TRACKERID_', tracker_type, '.ELEMENTID_', tracker_elementID, '.mat'];
% GAZEREGv03.SESSIONID_20240109T150811.A_AM.B_None.SCP_01.SIDEID_A.SUBJECTID_AM.TRACKERID_pupillabs.ELEMENTID_PupilLabsTrackerA.mat
trackerlog_info.GAZEREG_match_string = ['GAZEREGv*', ...
	'.SESSIONID_', trackerlog_info.session_info.YYYYMMDD_string, 'T', '*', ...
	'.SIDEID_', trackerlog_info.SIDEID,...
	'.SUBJECTID_', trackerlog_info.SUBJECTID, ...
	'.TRACKERID_', trackerlog_info.TRACKERID, ...
	'.ELEMENTID_', trackerlog_info.TID, ...
	'.mat'];


trackerlog_info.GAZEREG_string = ['GAZEREGv*', ...
	'.SESSIONID_', trackerlog_info.SESSIONID, ...
	'.SIDEID_', trackerlog_info.SIDEID,...
	'.SUBJECTID_', trackerlog_info.SUBJECTID, ...
	'.TRACKERID_', trackerlog_info.TRACKERID, ...
	'.ELEMENTID_', trackerlog_info.TID, ...
	'.mat'];


return
end

