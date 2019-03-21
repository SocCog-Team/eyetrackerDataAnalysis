% remove_trials extract removes trials corresponding to the stimulus specified by stimulToRemove 
% from the ``trial`` data structure 
% INPUT
%   - trial - array of structures containing data about trials for each specified stimulus. 
%     Each entry contains the following fields:
%      - caption - full caption of the trial (coincides with corresponding element of trialCaption)
%      - fix1Data, fix2Data, scrambledData, stimulusData - structures wtih
%        raw gaze data for each of the trial step. Contain the fields
%         - GazeX - x gaze coordinate;
%         - GazeY - y gaze coordinate;
%         - GazeSpeed - gaze speed;
%         - GazeTime - duration of this data sample;
%         - TimeStamp - timestamp of this data sample;;
%   - stimulToRemove - a string, which is a substring of the trial.caption for those trials that should be removed.
% OUTPUT
%  clearedTrial - array of structures containing data about trials with captions DO NOT contain the stimulToRemove substring
  
function clearedTrial = remove_trials(trial, stimulToRemove)
    selectedTrialInCell = strfind({trial.caption}, stimulToRemove);   
    indexOfTrialToRemove = find( cellfun(@(x) ~isempty(x), selectedTrialInCell) ); 
    clearedTrial = trial;
    clearedTrial(indexOfTrialToRemove) = [];
end    