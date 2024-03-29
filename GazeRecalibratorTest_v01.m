function [ output_args ] = GazeRecalibratorTest_v01( input_args )
%GAZERECALIBRATORTEST Summary of this function goes here
%   Detailed explanation goes here


%fileID='20190729T154225.A_Elmo.B_None.SCP_01.';
data_root_str = '/';
% network!
net_data_base_dir = fullfile(data_root_str, 'Volumes', 'social_neuroscience_data', 'taskcontroller');
net_data_base_dir = fullfile(data_root_str, 'Volumes', 'taskcontroller$');

net_data_base_dir = fullfile(data_root_str, 'Volumes', 'taskcontroller$');

% local
data_base_dir = fullfile('~', 'DPZ', 'taskcontroller');

% windows...
if (ispc)
	data_base_dir = fullfile('Y:');
	net_data_base_dir = data_base_dir;
end

data_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190729', '20190729T154225.A_Elmo.B_None.SCP_01.sessiondir');


% common parameters
velocity_threshold_pixels_per_sample = 0.05; % Eyelink
saccade_allowance_time_ms = 200;
acceptable_radius_pix = 10;	%Eyelink
%transformationType = 'lwm'; % 'affine', 'polynomial', 'pwl', 'lwm'
transformationType = []; % if empty attempt all
polynomial_degree = 2;	% degree 3 requires at least 10 control points
lwm_N = 10;
tracker_type = 'eyelink';

% lwm needs sensibly spaced control points, does not work yet
if strcmp(transformationType, 'lwm')
	polynomial_degree = 10;
end

% %% EyeLink decent HV9 eyelink calibration/validation, little distortions
% data_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190729', '20190729T154225.A_Elmo.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190729T154225.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
% reg_struct = fn_gaze_recalibrator_v01(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree, lwm_N);


% % still decent eyelink calibration
% data_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190705', '20190705T113230.A_Elmo.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190705T113230.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
% reg_struct = fn_gaze_recalibrator_v01(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree, lwm_N);


% % human HV9 calibration without validation, data from NHP heavy shearing
% data_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190312', '20190312T071737.A_Elmo.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190312T071737.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
% reg_struct = fn_gaze_recalibrator_v01(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree, lwm_N);

% % human HV9 calibration without validation, data from NHP heavy shearing
% data_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190320', '20190320T092435.A_Elmo.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190320T092435.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
% reg_struct = fn_gaze_recalibrator_v01(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree, lwm_N);




% % %EyeLink HV9 eyelink calibration/validation after the removal of the calibration files
% data_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190805', '20190805T122130.A_Elmo.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190805T122130.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
% reg_struct = fn_gaze_recalibrator_v01(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree, lwm_N);


% %EyeLink HV9 eyelink calibration/validation with 17 target positions
% data_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190816', '20190816T124444.A_Elmo.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190816T124444.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
% reg_struct = fn_gaze_recalibrator_v01(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree, lwm_N);


% %EyeLink HV9 eyelink calibration/validation with 41 target positions
% data_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190822', '20190822T153520.A_Elmo.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190822T153520.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
% reg_struct = fn_gaze_recalibrator_v01(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree, lwm_N);




% %% PRIMATAR
% %EyeLink HV9 eyelink calibration/validation with 41 target positions
% data_dir = fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190222', '20190222T125802.A_Elmo.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190222T125802.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
% reg_struct = fn_gaze_recalibrator_v01(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree, lwm_N);

% % %EyeLink HV9 eyelink calibration/validation after the removal of the calibration files
% data_dir = fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2020', '200107', '20200107T134055.A_Elmo.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20200107T134055.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
% reg_struct = fn_gaze_recalibrator_v01(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree, lwm_N);

% % %EyeLink HV9 eyelink calibration/validation after the removal of the calibration files
% data_dir = fullfile(data_base_dir, 'taskcontroller', 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2020', '200109', '20200109T131751.A_Elmo.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20200109T131751.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
% reg_struct = fn_gaze_recalibrator_v01(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree, lwm_N);


%return


% %%Pupillabs test
% tracker_type = 'pupillabs';
% data_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190419', '20190419T161006.A_190419ID111S1.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190419T161006.A_190419ID111S1.B_None.SCP_01.TID_PupilLabsTrackerA.trackerlog');
% reg_struct = fn_gaze_recalibrator_v01(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree, lwm_N);



% %%Pupillabs test
% tracker_type = 'pupillabs';
% data_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2020', '200522', '20200522T154315.A_20200522ID006S1.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20200522T154315.A_20200522ID006S1.B_None.SCP_01.TID_PupilLabsTrackerA.trackerlog');
% reg_struct = fn_gaze_recalibrator_v01(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree, lwm_N);


% %%Pupillabs test (PL 3.4.0, Vlad/VI with chin rest) ficudial/surface
% tracker_type = 'pupillabs';
% acceptable_radius_pix = 20;
% velocity_threshold_pixels_per_sample = 0.5;
% data_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2021', '211110', '20211110T154657.A_VI.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20211110T154657.A_VI.B_None.SCP_01.TID_PupilLabsTrackerA.trackerlog');
% reg_struct = fn_gaze_recalibrator_v01(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree, lwm_N);


% %%Pupillabs test (PL 3.4.0, Vlad/VI with chin rest) Pupil0
% tracker_type = 'pupillabs';
% acceptable_radius_pix = 20;
% velocity_threshold_pixels_per_sample = 0.5;
% data_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2021', '211110', '20211110T154924.A_VI.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20211110T154924.A_VI.B_None.SCP_01.TID_PupilLabsTrackerA.trackerlog');
% reg_struct = fn_gaze_recalibrator_v01(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree, lwm_N);




% %%Pupillabs test (PL 3.4.0, Vlad/VI with chin rest) ficudial/surface
% tracker_type = 'pupillabs';
% acceptable_radius_pix = 20;
% velocity_threshold_pixels_per_sample = 0.5;
% data_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2021', '211110', '20211110T154657.A_VI.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20211110T154657.A_VI.B_None.SCP_01.TID_PupilLabsTrackerA.trackerlog');
% reg_struct = fn_gaze_recalibrator_v01(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree, lwm_N);








% % %%Pupillabs Curius A
% tracker_type = 'pupillabs';
% acceptable_radius_pix = 20;
% velocity_threshold_pixels_per_sample = 0.5;
% data_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2023', '230623', '20230623T121142.A_Curius.B_None.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20230623T121142.A_Curius.B_None.SCP_01.TID_PupilLabsTrackerA.trackerlog');
% reg_struct = fn_gaze_recalibrator_v02(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree, lwm_N);
% close all
% 
% 
% % %%Pupillabs Elmo B
% tracker_type = 'pupillabs';
% acceptable_radius_pix = 20;
% velocity_threshold_pixels_per_sample = 0.5;
% data_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2023', '230623', '20230623T115050.A_None.B_Elmo.SCP_01.sessiondir');
% gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20230623T115050.A_None.B_Elmo.SCP_01.TID_PupilLabsTrackerB.trackerlog');
% reg_struct = fn_gaze_recalibrator_v02(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree, lwm_N);
% close all
% 



%%TODO: also test with EyeLinkData
% %EyeLink HV9 eyelink calibration/validation after the removal of the calibration files
tracker_type = 'eyelink';
acceptable_radius_pix = 10;
velocity_threshold_pixels_per_sample = 0.05;
data_dir = fullfile(data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2019', '190805', '20190805T122130.A_Elmo.B_None.SCP_01.sessiondir');
gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20190805T122130.A_Elmo.B_None.SCP_01.TID_EyeLinkProxyTrackerA.trackerlog');
reg_struct = fn_gaze_recalibrator_v02(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree, lwm_N);
close all


% %%Pupillabs test AM (PL 3.5.1) HPrig Pupil0
% 20240109T150811.A_AM.B_None.SCP_01.sessiondir
% test with new Detection Method filter in EventIDE (set to "2d c++" in this recording)
tracker_type = 'pupillabs';
acceptable_radius_pix = 20;
velocity_threshold_pixels_per_sample = 0.5;
data_dir = fullfile(net_data_base_dir, 'SCP_DATA', 'SCP-CTRL-01', 'SESSIONLOGS', '2024', '240109', '20240109T150811.A_AM.B_None.SCP_01.sessiondir');
gaze_tracker_logfile_FQN = fullfile(data_dir, 'trackerlogfiles', '20240109T150811.A_AM.B_None.SCP_01.TID_PupilLabsTrackerA.trackerlog');
reg_struct = fn_gaze_recalibrator_v02(gaze_tracker_logfile_FQN, tracker_type, velocity_threshold_pixels_per_sample, saccade_allowance_time_ms, acceptable_radius_pix, transformationType, polynomial_degree, lwm_N);
close all



%/Users/smoeller/DPZ/taskcontroller/SCP_DATA/SCP-CTRL-01/SESSIONLOGS/2020/200522/20200522T154606.A_20200522ID006S1.B_None.SCP_01.sessiondir/trackerlogfiles

% % use this to automatically find all sessions requiring recalibrations and
% % run those
% loop_over_sessions = 1;
% redo_existing_calibrations = 0; % otherwise just keep the existing GAZEREG
% 
% if (loop_over_sessions)
% 	% define a subset of sessions by giving a base_dir
% 	% where to searc
% 	session_base_dir = 'Y:\SCP_DATA\SCP-CTRL-01\SESSIONLOGS\2023\230703';
% 	% what to search for
% 	trackerlog_dir_wildcard_string_list = {'*.TID_PupilLabsTrackerA.trackerlog*', '*.TID_PupilLabsTrackerB.trackerlog*', '*.TID_EyeLinkProxyTrackerA.trackerlog*'};
% 	
% 	find_all_files_verbosity = 0;
% 	calibration_EVE_dir_match_string = ['*EyeTrackingCalibrator*.eve*'];
% 
% 	% find the gaze calibration sessions by looking at EVE file names
% 	% containing the following match string ['*EyeTrackingCalibrator*.eve*']
% 	GAZEREG_sessiondir_list = find_all_files(session_base_dir, calibration_EVE_dir_match_string, find_all_files_verbosity);
% 	if ~iscell(GAZEREG_sessiondir_list)
% 		GAZEREG_sessiondir_list = {GAZEREG_sessiondir_list};
% 	end
% 	
% 	% loop over all proto_GAZEREG_sessiondir_list and collect all
% 	% trackerlog files
% 	calibration_tarckerlog_fqn_list = {};
% 	
% 	for i_GAZEREG_sessiondir_list = 1 : length(GAZEREG_sessiondir_list)
% 		cur_GAZEREG_sessiondir = fileparts(GAZEREG_sessiondir_list{i_GAZEREG_sessiondir_list});
% 		for i_trackerlog_wildcard = 1 : length(trackerlog_dir_wildcard_string_list)
% 			cur_trackerlog_wildcard = trackerlog_dir_wildcard_string_list{i_trackerlog_wildcard};
% 			cur_trackerlog_wildcard_fqn_list =  find_all_files(cur_GAZEREG_sessiondir, cur_trackerlog_wildcard, find_all_files_verbosity);
% 	
% 			cur_trackerlog_wildcard_fqn_list = regexprep(cur_trackerlog_wildcard_fqn_list, '\.trackerlog.*$', '.trackerlog');
% 			cur_trackerlog_wildcard_fqn_list = unique(cur_trackerlog_wildcard_fqn_list);
% 			if ~iscell(cur_trackerlog_wildcard_fqn_list)
% 				cur_trackerlog_wildcard_fqn_list = {cur_trackerlog_wildcard_fqn_list};
% 			end			
% 			calibration_tarckerlog_fqn_list = [calibration_tarckerlog_fqn_list, cur_trackerlog_wildcard_fqn_list];
% 		end % i_trackerlog_wildcard
% 	end
% 
% 
% 	for i_calibration_tarckerlog_fqn = 1 : length(calibration_tarckerlog_fqn_list)
% 		cur_calibration_tarckerlog_fqn = calibration_tarckerlog_fqn_list{i_calibration_tarckerlog_fqn};
% 		disp(['Creating calibration transormation data from calibration file: ', cur_calibration_tarckerlog_fqn]);
% 		[ trackerlog_info ] = fn_parse_trackerlog_name(cur_calibration_tarckerlog_fqn);
% 		
% 		% figure out whether the current calibartion exists allready
% 		[~, cur_gaze_reg_string] = fn_gaze_recalibrator_v02(cur_calibration_tarckerlog_fqn, 'version');
% 		cur_GAZEREG_string = regexprep(trackerlog_info.GAZEREG_string, 'v\*', cur_gaze_reg_string);
% 				
% 		
% 		if (redo_existing_calibrations) || ~isfile(fullfile(fileparts(cur_calibration_tarckerlog_fqn), cur_GAZEREG_string))
% 			disp([mfilename, ': Running re-calibrator on ', cur_calibration_tarckerlog_fqn]);
% 			reg_struct = fn_gaze_recalibrator_v02(cur_calibration_tarckerlog_fqn, trackerlog_info.TRACKERID);
% 			close all
% 		else
% 			disp([mfilename, ': trackerlog already processed by re-calibrator, and redo_existing_calibrations not requested, skipping...']);
% 		end
% 	end	
% 		
% end


end

