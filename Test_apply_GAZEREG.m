function [ ] = Test_apply_GAZEREG( )
%TEST_APPLY_GAZEREG Summary of this function goes here
%   Detailed explanation goes here

% TODO:
%	automatically find the best matching calibration session (same day same
%		set-up), and if not processed already process it
%	match the session by subject_ID and position and date and time...
%	later convert gaze traces into 1000 or 500 Hz continuous traces 
%		(use NaN for blinks... and low confidence) also extract difference
%		between pupil 0 (right eye) and pupil 1 (left eye) _> vergence...
%		calculate equivalent binocular fixation as average of both pupils
%		with average pupil diameter




% load a gaze track file
cur_session_dir = fullfile('Y:', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190805', '20190805T123913.A_Elmo.B_RN.SCP_01.sessiondir');
cur_gazelog_fqn = fullfile(cur_session_dir, 'trackerlogfiles', '20190805T123913.A_Elmo.B_RN.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
[session_dir, cur_session_id, session_ext] = fileparts(cur_session_dir);
session_info = fn_parse_session_id(cur_session_id);
trackerlog_struct = fnParseEventIDETrackerLog_v01( cur_gazelog_fqn, [], [], []);

% 

%[ gaze_calibration_session_fqn_list, GAZEREG_FQN_list] = fn_find_compatible_gaze_calibration_sessions( cur_gazelog_fqn )

[GAZEREG_FQN_list, GAZEREG_sessiondir_list, compatible_calibration_trackerlog_fqn_list, missing_calibration_trackerlog_fqn_list] = fn_find_compatible_gaze_calibration_sessions(cur_gazelog_fqn);



%% find the best matching GAZEREG
%GAZEREG_dirstruct = dir(fullfile(cur_session_dir, '..', 'GAZEREGv02.SID*'));
%cur_GAZEREG_fqn = fullfile(cur_session_dir, '..', 'GAZEREGv02.SID_20190805T122130.A_Elmo.B_None.SCP_01.SIDE_A.SUBJECTID_Elmo.eyelink.TRACKERELEMENTID_EyeLinkProxyTrackerA.mat');
cur_GAZEREG_fqn = fullfile(cur_session_dir, '..', 'GAZEREGv03.SESSIONID_20190805T122130.A_Elmo.B_None.SCP_01.SIDEID_A.SUBJECTID_Elmo.TRACKERID_eyelink.ELEMENTID_EyeLinkProxyTrackerA.mat');


compatible_tracker_log_fqn_list = fn_get_trackerlog_FQNs_compatible_with_GAZEREG(cur_GAZEREG_fqn);






% load the registration matrix...
load(cur_GAZEREG_fqn, 'out_registration_struct');

transformationType = 'polynomial';
[ out_trackerlog_struct ] = fn_apply_GAZEREG_to_gaze_data(trackerlog_struct, out_registration_struct, transformationType);


% load a gaze track file
cur_session_dir = fullfile('Y:', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2024', '240109', '20240109T151424.A_AM.B_BA.SCP_01.sessiondir');
cur_gazelog_fqn = fullfile(cur_session_dir, 'trackerlogfiles', '20240109T151424.A_AM.B_BA.SCP_01.TID_PupilLabsTrackerA.trackerlog');
[session_dir, cur_session_id, session_ext] = fileparts(cur_session_dir);
session_info = fn_parse_session_id(cur_session_id);
trackerlog_struct = fnParseEventIDETrackerLog_v01( cur_gazelog_fqn, [], [], []);

%% find the best matching GAZEREG
%GAZEREG_dirstruct = dir(fullfile(cur_session_dir, '..', 'GAZEREGv02.SID*'));
cur_GAZEREG_fqn = fullfile(cur_session_dir, '..', 'GAZEREGv02.SID_20240109T150811.A_AM.B_None.SCP_01.SIDE_A.SUBJECTID_AM.pupillabs.TRACKERELEMENTID_PupilLabsTrackerA.mat');

% extract the GAZEREG_session _ID and compare date with session_info, take
% the last suitable registration... if multiple exist

% load the registration matrix...
load(cur_GAZEREG_fqn, 'out_registration_struct');

transformationType = 'polynomial';
[ out_trackerlog_struct ] = fn_apply_GAZEREG_to_gaze_data(trackerlog_struct, out_registration_struct, transformationType);









% apply...





return
end

