clear all
dbstop if error

fq_mfilename = mfilename('fullpath');
mfilepath = fileparts(fq_mfilename);
% make sure we find everything where we expect
cd(mfilepath);


%------------ specify files to be analysed ------------
if (ispc)
	baseDir = fullfile('C:');
	fullDir = fullfile(baseDir, 'SCP_CODE', 'eyetrackerDataAnalysis');
	baseDir = fullfile('X:', 'rhesus expressions');
	fullDir = fullfile(baseDir, 'PrimatarData_from_social_neuroscience_data');
else
	remote_baseDir = fullfile('/Volumes', 'social_neuroscience_data', 'taskcontroller');	
	local_base_dir = fullfile('/', 'Users', 'smoeller', 'DPZ', 'taskcontroller');
	
	baseDir = local_base_dir;
	fullDir = fullfile(baseDir, 'Projects', 'Primatar', 'PrimatarData');
end
%baseDir = fullfile('Y:');
%fullDir = fullfile(baseDir, 'Projekts', 'Primatar', 'PrimatarData');

files = {fullfile(fullDir, 'Cornelius_20170714_1250', 'TrackerLog--ArringtonTracker--2017-14-07--12-50.txt'), ...
	fullfile(fullDir, 'Session_on_07-11--15-27', 'TrackerLog--EyeLink--2017-07-11--15-27_fixed.txt'), ...
	fullfile(fullDir, 'Session_on_20190222T130620', 'TrackerLog--EyeLink--2019-22-02--13-06.txt.Fixed.txt')};
%fullfile(fullDir, 'Session_on_20190222T132742', 'TrackerLog--EyeLink--2019-22-02--13-27.txt.Fixed.txt')};

nFile = length(files);

sessionNameStem_list = {'Cornelius', 'Flaffus', 'Elmo'};

% whether the image was transformed for the use in the dyadic platform setup
% (true for data after 21.02.2019)
dyadicPlatformImageTransform = [false, false, true];

%------ specify the images used for the experiments -------
%baseStimuliDir = fullfile(baseDir, 'Stimuli', 'Primatar', '20170714');
baseStimuliDir = 'Stimuli';
stimulImage = {fullfile(baseStimuliDir, 'face1.png'), ...
	fullfile(baseStimuliDir, 'face2.png'), ...
	fullfile(baseStimuliDir, 'face3.png'), ...
	fullfile(baseStimuliDir, 'RealistcAvatar.png'), ...
	fullfile(baseStimuliDir, 'UnrealisticAvatar.png')};

%20200329, added obfuscated image underlays
stimulImage = {...
	fullfile(baseStimuliDir, 'face1.png'), ...
	fullfile(baseStimuliDir, 'face2.png'), ...
	fullfile(baseStimuliDir, 'face3.png'), ...
	fullfile(baseStimuliDir, 'RealistcAvatar.png'), ...
	fullfile(baseStimuliDir, 'UnrealisticAvatar.png'),...
	fullfile(baseStimuliDir, 'face1.mild.blur7.3x7.3.png'), ...
	fullfile(baseStimuliDir, 'face2.mild.blur7.3x7.3.png'), ...
	fullfile(baseStimuliDir, 'face3.mild.blur7.3x7.3.png'), ...
	fullfile(baseStimuliDir, 'RealistcAvatar.mild.blur7.3x7.3.png'), ...
	fullfile(baseStimuliDir, 'UnrealisticAvatar.mild.blur7.3x7.3.png'),...
	fullfile(baseStimuliDir, 'face1.strong.blur14.6x14.6.png'), ...
	fullfile(baseStimuliDir, 'face2.strong.blur14.6x14.6.png'), ...
	fullfile(baseStimuliDir, 'face3.strong.blur14.6x14.6.png'), ...
	fullfile(baseStimuliDir, 'RealistcAvatar.strong.blur14.6x14.6.png'), ...
	fullfile(baseStimuliDir, 'UnrealisticAvatar.strong.blur14.6x14.6.png'),...
	};


scramImage = {fullfile(baseStimuliDir, 'face1_scram.tif'), ...
	fullfile(baseStimuliDir, 'face2_scram.tif'), ...
	fullfile(baseStimuliDir, 'face3_scram.tif'), ...
	fullfile(baseStimuliDir, 'RealistcAvatar_scram.tif'), ...
	fullfile(baseStimuliDir, 'UnrealisticAvatar_scram.tif')};


%eyes in image coordinate system
eyesImageRect = [83, 60, 215, 85; ...
	75, 60, 215, 85; ...
	78, 63, 215, 85; ...
	78, 58, 215, 85; ...
	78, 63, 215, 85];

%mouth in image coordinate system
mouthImageRect = [ 90, 265, 200, 70; ...
	60, 245, 200, 70; ...
	65, 268, 200, 70; ...
	65, 283, 200, 70; ...
	65, 285, 200, 70];

% ------------ specify plotting parameters ------------
plotSetting = struct('initialFix', true,...
	'rawFix', true,...
	'perTrialAttentionMap', true, ...
	'averageAttentionMap', true, ...
	'nTrial', 8,...
	'summary', true, ...
	'fontSize', 12, ...
	'fontName', 'Arial',...
	'defaultFormatPaperSize', 'Plos_max', ...
	'outputTypeString', '.pdf');

% ------------ analyse all experiments ------------

%nObfuscationLevelToConsider = 0;
nObfuscationLevelToConsider_list = {0, 1, 2, 3};
%nObfuscationLevelToConsider_list = {0};

for i_nObfuscationLevelToConsider = 1 : length(nObfuscationLevelToConsider_list)
	nObfuscationLevelToConsider = 	nObfuscationLevelToConsider_list{i_nObfuscationLevelToConsider};
	disp(['Processing nObfuscationLevelToConsider: ', num2str(nObfuscationLevelToConsider)]);
	stimulStat = cell(1, nFile);
	scrambledStat = cell(1, nFile);

	sessionName = cell(size(sessionNameStem_list));
	for i_session = 1 : length(sessionNameStem_list)
		sessionName{i_session} = [sessionNameStem_list{i_session}, '_', num2str(nObfuscationLevelToConsider)];
	end
	
	iFile = 1;
	%iFile = 3; %Elmo
	while iFile <= nFile
		
		try
			[stimulStat{iFile}, scrambledStat{iFile}, stimulName] = analyse_eyetracker_experiment(...
				files{iFile}, sessionName{iFile}, dyadicPlatformImageTransform(iFile), ...
				nObfuscationLevelToConsider, stimulImage, scramImage, eyesImageRect, mouthImageRect, plotSetting);
		catch e
			if (strcmp(e.identifier, 'MATLAB:print:ProblemGeneratingOutput'))
				disp(['An server connection error occurred while parsing file ' files{iFile}]);
				disp('The file will be parsed again.');
				iFile = iFile - 1;
				close all;
			else
				e.message
			end
		end
		
		iFile = iFile + 1;
	end
	
	% save the stimulStat
	concatSessionNames = [];
	for iSession = 1 : length(sessionName)
		concatSessionNames = [concatSessionNames, sessionName{iSession}];
	end
	
	outFileName = ['stimulStat.nObfuscationLevels_', num2str(nObfuscationLevelToConsider), '.', concatSessionNames, '.mat'];
	save(fullfile(pwd, outFileName), 'stimulStat');
	save(fullfile(fullDir, outFileName), 'stimulStat');
	
	outFileName = ['scrambledStat.nObfuscationLevels_', num2str(nObfuscationLevelToConsider), '.', concatSessionNames, '.mat'];
	save(fullfile(pwd, outFileName), 'scrambledStat');
	save(fullfile(fullDir, outFileName), 'scrambledStat');
	close all
end

disp('Done');


