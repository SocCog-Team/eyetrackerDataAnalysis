function [dataTable, trialStruct, trial] = read_primatar_data_from_file(filename, needCorrectTimeStamps)
% read_primatar_data_from_file reads data of primatar experiment trials from a
% single EVENT IDE eye-tracker file and stores it in a dataset and in a structures describing trials.
% Each trial consists of the following stages: 
% 1) first initial fixation
% 2) first reward
% 3) viewing real face
% 4) second initial fixation
% 5) second reward
% 6) viewing scrambled face
%
% INPUT
%   - filename - name of EVENT IDE file, char array;
%   - needCorrectTimeStamps - if true, subsequent equal timestamps are replaced
%     by interpolation of nearest unequal values
%
% OUTPUT:
%   - dataTable - contents of the file in a dataset form. Additionally time
%    (difference of time stamps) and gaze speed are computed for each data
%    sample.
%   - trialStruct - structure containing indices of various events in dataTable. 
%     Contains the following fields:
%      - fix1Start -- indices of first initial fixations onsets;
%      - fix1End -- indices of first initial fixations ends;
%      - fix2Start -- indices of second initial fixations onsets;
%      - fix2End -- indices of second initial fixations ends;
%      - scrambledStart -- indices of scrambled image presentations onsets;
%      - scrambledEnd -- indices of scrambled image presentations ends;
%      - stimulStart -- indices of stimulus image presentations onsets;
%      - stimulEnd -- indices of stimulus image presentations ends;
%      - trialCaption - full caption for each trial (describes the stimuli 
%        presented at this trial, contents of the UserField row of dataTable)
%   - trial - array of structures containing data about trials for each specified stimulus. 
%     Each entry contains the following fields:
%      - caption - full caption of the trial (coincides with corresponding element of trialCaption)
%      - fix1Data, fix2Data, scrambledData, stimulusData - structures wtih
%        raw gaze data for each of the trial step. Contain the fields
%         - GazeX - x gaze coordinate;
%         - GazeY - y gaze coordinate;
%         - GazeSpeed - gaze speed;
%         - GazeTime - duration of this data sample;
%         - TimeStamp - timestamp of this data sample;
%
% EXAMPLE of use 
% filename = 'TrackerLog--ArringtonTracker--2017-14-07--12-50.txt';
% normStimulName = {'Real face 1 - Normal 0', 'Real face 2 - Normal 0', 'Real face 3 - Normal 0', ... 
%                   'Realistic avatar - Normal 1', 'Unrealistic avatar - Normal 2'};          
% [normTrial, ~, normTrialStruct] = parse_eye_tracker_file(filename, normStimulName, true);      
%
  if (~isempty(strfind(filename, 'TrackerLog--ArringtonTracker--2017-14-07--12-50.txt')))
    logVersion = 'Primatar_20170714';
  elseif (~isempty(strfind(filename, 'TrackerLog--EyeLink--2017'))) 
    logVersion = 'Primatar_20171020';
  else 
    logVersion = 'Primatar_20180802';
  end  
  dataTable = fnParseEventIDETrackerLog_simple_v01(filename, logVersion);   
  dataTable.CurrentEvent = categorical(dataTable.CurrentEvent);
  
  [~, ~, stateIndex]  = unique(dataTable.CurrentEvent);
  %[allStates, ~, stateIndex]  = unique(dataTable.CurrentEvent);
  %[allStimuli, ~, stimuliIndices] = unique(dataTable.UserField);
  
  %compute gaze speed
  dt = diff(dataTable.EventIDETimeStamp);
  
  if (needCorrectTimeStamps)
    nTimestamps = length(dt);
    lastCorrect = 0;
    for i = 1:nTimestamps - 1
      if ((dt(i) > 0) && (dt(i+1) == 0))
        lastCorrect = i;
      elseif (((dt(i) == 0) && (dt(i+1) > 0)) && (lastCorrect > 0))
        meanDT = (dataTable.EventIDETimeStamp(i+1) - dataTable.EventIDETimeStamp(lastCorrect))/(i + 1 - lastCorrect);
        dataTable.EventIDETimeStamp(lastCorrect:i+1) = ...
              dataTable.EventIDETimeStamp(lastCorrect):meanDT:dataTable.EventIDETimeStamp(i+1);
        dt(lastCorrect:i) = meanDT;
      end  
    end
  end
  dt(dt == 0) = 0.001; %replace zero by 1 us to avoid division by zero
  dataTable.GazeTime = ([dt(1); dt] + [dt; dt(end)])/2;
  
  %compute gaze speed in pixels/s
  speed = sqrt(diff(dataTable.GazeX).^2 + diff(dataTable.GazeY).^2)./dt;
  dataTable.GazeSpeed = [speed; 0]; %last value of speed is set to zero
  
  %create trials
  %define borders of the states
  stateChange = stateIndex(2:end) - stateIndex(1:end-1);
  stateChange(stateChange ~= 0) = 1; 
  stateStart = [0; stateChange];
  stateEnd = [stateChange; 0];
  
  fixationStart = find((stateStart == 1) & ((dataTable.CurrentEvent == 'Top event>Fix 1') | (dataTable.CurrentEvent == 'Top event>Fix 2')));
  fixationEnd = find((stateEnd == 1) & ((dataTable.CurrentEvent == 'Top event>Fix 1') | (dataTable.CurrentEvent == 'Top event>Fix 2')));

  trialStruct = struct('fix1Start', fixationStart(1:2:end), ...  % uneven fixations indicate trial start 
                       'fix1End', fixationEnd(1:2:end), ...
                       'fix2Start', fixationStart(2:2:end), ...  % even fixations are before stimulus presentations
                       'fix2End', fixationEnd(2:2:end), ...
                       'scrambledStart', find((stateStart == 1) & (dataTable.CurrentEvent == 'Top event>Scrambled Face')), ...
                       'scrambledEnd', find((stateEnd == 1) & (dataTable.CurrentEvent == 'Top event>Scrambled Face')), ...
                       'stimulStart', find((stateStart == 1) & (dataTable.CurrentEvent == 'Top event>Stimulus')), ...
                       'stimulEnd', find((stateEnd == 1) & (dataTable.CurrentEvent == 'Top event>Stimulus')), ...
                       'trialCaption', []); %this is necessary to get a single strucute instead of array                        
  trialStruct.trialCaption = dataTable.UserField(trialStruct.fix1Start);
  
  trial = struct('caption', trialStruct.trialCaption, ...
                 'fix1Data', [], 'fix2Data', [], 'scrambledData', [], 'stimulusData', [] );
  nTrial = length(trialStruct.fix1Start);            
  for iTrial = 1:nTrial             
    trial(iTrial).fix1Data = createTrialField(dataTable, ...
                                trialStruct.fix1Start(iTrial):trialStruct.fix1End(iTrial));                        
    trial(iTrial).fix2Data = createTrialField(dataTable, ...
                                trialStruct.fix2Start(iTrial):trialStruct.fix2End(iTrial));
    trial(iTrial).scrambledData = createTrialField(dataTable, ...
                                trialStruct.scrambledStart(iTrial):trialStruct.scrambledEnd(iTrial));
    trial(iTrial).stimulusData = createTrialField(dataTable, ...
                                trialStruct.stimulStart(iTrial):trialStruct.stimulEnd(iTrial));                              
  end                
end

function gazeData = createTrialField(dataTable, indices)
  gazeData = struct('GazeX', dataTable.GazeX(indices), ...
                    'GazeY', dataTable.GazeY(indices), ...
                    'GazeSpeed', dataTable.GazeSpeed(indices), ...
                    'GazeTime', dataTable.GazeTime(indices), ...
                    'TimeStamp', dataTable.EventIDETimeStamp(indices)); 
end






