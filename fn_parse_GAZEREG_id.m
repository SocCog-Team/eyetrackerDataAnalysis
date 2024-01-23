function [ GAZEREG_info ] = fn_parse_GAZEREG_id( GAZEREG_id_string )
%FN_PARSE_GAZEREG_ID Summary of this function goes here
%   Detailed explanation goes here
%output_mat_filename = ['GAZEREGv02.SID_', sessionID, '.SIDE_', side, '.SUBJECTID_', subject_name, '.', tracker_type, '.TRACKERELEMENTID_', tracker_elementID, '.mat'];%
% output_mat_filename = ['GAZEREGv03.SESSIONID_', sessionID, '.SIDEID_', side, '.SUBJECTID_', subject_name, '.TRACKERID_', tracker_type, '.ELEMENTID_', tracker_elementID, '.mat'];

GAZEREG_info = struct();
GAZEREG_info.GAZEREG_id_string = GAZEREG_id_string;

% consume this from the end, searching for the known all caps identifiers

%ALLCAPS_identifier_list_revresed = {'.TRACKERELEMENTID_', '.SUBJECTID_', '.SIDE_', '.SID_', 'GAZEREGv'};
ALLCAPS_identifier_list_revresed = {'.ELEMENTID_', '.TRACKERID_', '.SUBJECTID_', '.SIDEID_', '.SESSIONID_', 'GAZEREGv'};

processed_GAZEREG_id_string = GAZEREG_id_string;

for i_AC_identifier = 1 : length(ALLCAPS_identifier_list_revresed)
	cur_AC_identifier = ALLCAPS_identifier_list_revresed{i_AC_identifier};
	identifier_start_idx = strfind(GAZEREG_id_string, cur_AC_identifier);
% 	if strcmp(cur_AC_identifier, '.SUBJECTID_')
% 		% also extract the trackertype
% 		[~, processed_GAZEREG_id_string, trackertype] = fileparts(processed_GAZEREG_id_string); % abuse becsuse this does the right thing with the final dot
% 		GAZEREG_info.tracker_type = trackertype(2:end);
% 	end
	sanitized_cur_AC_identifier = regexprep(cur_AC_identifier, '^\.', '');
	sanitized_cur_AC_identifier = regexprep(sanitized_cur_AC_identifier, '\_$', '');
	sanitized_cur_AC_identifier = regexprep(sanitized_cur_AC_identifier, '^GAZEREGv', 'version_string');

	GAZEREG_info.(sanitized_cur_AC_identifier) = processed_GAZEREG_id_string((identifier_start_idx + length(cur_AC_identifier)):end);
	
	processed_GAZEREG_id_string(identifier_start_idx:end) = [];
end	

GAZEREG_info.session_info = fn_parse_session_id(GAZEREG_info.SESSIONID);


% we can predict which trackerlogfiles will work with this calibration...
% so generate the strig to use via dir and regexp
if (strcmp(GAZEREG_info.SIDEID, 'A'))
	subject_X_string_name = 'subject_A_string';
else
	subject_X_string_name = 'subject_B_string';
end
GAZEREG_info.trackerlog_match_string = [GAZEREG_info.session_info.YYYYMMDD_string, 'T', '*', ...
	'.', GAZEREG_info.session_info.(subject_X_string_name), '*',...
	'.', GAZEREG_info.session_info.setup_id_string, ...
	'.TID_', GAZEREG_info.ELEMENTID, ...
	'.trackerlog', '.*'];

return
end




function [ session_info ] = fn_parse_session_id_local( session_id )
%Extract the information from the session_id, e.g. from 20200106T154947.A_None.B_Curius.SCP_01

unprocessed_session_id = session_id;

% extract the session date and time
[session_date_time_string, unprocessed_session_id] = strtok(unprocessed_session_id, '.');
session_info.session_date_time_string = session_date_time_string;
[tmp_date, tmp_T_time] = strtok(session_info.session_date_time_string, 'T');
session_info.year_string = tmp_date(1:4);
session_info.month_string = tmp_date(5:6);
session_info.day_string = tmp_date(7:8);
session_info.hour_string = tmp_T_time(2:3);	% offset by the leading T
session_info.minute_string = tmp_T_time(4:5);
session_info.second_string = tmp_T_time(6:7);
session_info.YYMMDD_string = [session_info.year_string(3:4), session_info.month_string, session_info.day_string];
session_info.YYYYMMDD_string = [session_info.year_string(1:4), session_info.month_string, session_info.day_string];
session_info.HHmmSS_string = tmp_T_time(2:end);

% get the marker for a merged session (needs to be concise)
if strcmp('M', session_date_time_string(end))
	session_info.merged_session = 1;
	session_info.merged_session_id = tmp_T_time;
else
	session_info.merged_session = 0;
	session_info.merged_session_id = [];
end

% extract the subjects
[subject_A_string, unprocessed_session_id] = strtok(unprocessed_session_id, '.');
session_info.subject_A_string = subject_A_string;
session_info.subject_A = subject_A_string(3:end);
% subject B
[subject_B_string, unprocessed_session_id] = strtok(unprocessed_session_id, '.');
session_info.subject_B_string = subject_B_string;
session_info.subject_B = subject_B_string(3:end);
session_info.subjects_string = [subject_A_string, '.', subject_B_string];

% the set-up
session_info.setup_id_string = unprocessed_session_id(2:end);

% the full session_id just in case
session_info.session_id = session_id;

return
end