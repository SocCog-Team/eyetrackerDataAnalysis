function [fixation, rawGaze, trialIndices] = get_gaze_pos(trial, state, stimul, fixSelector, isDraw)
% get_gaze_pos extract raw gaze data in given state from trials corresponding to the given stimulus.
%   Optionally, fixations are also computed. 
% INPUT
%   - trial - array of structures containing data about trials for each specified stimulus. 
%     Each entry contains the following fields:
%      - caption - full caption of the trial (coincides with corresponding element of trialCaption)
%      - fix1Data, fix2Data, scrambledData, stimulusData - structures with
%        raw gaze data for each state within the trial. Contain the fields
%         - GazeX - x gaze coordinate;
%         - GazeY - y gaze coordinate;
%         - GazeSpeed - gaze speed;
%         - GazeTime - duration of this data sample;
%         - TimeStamp - timestamp of this data sample;;
%   - state - string specifying the state for that data should be provided.
%     state can be either fix1, fix2, scrambled or stimulus.   

% OPTIONAL INPUT (these values may be omitted)
%   - stimul - string specifying the stimuli (captions of trials) of interest.  
%              If specified, only respective trials are processed. If not
%              specified, all trials are processed.
%   - fixSelector - structure describing the algorithm for fixation
%                   detection. If not specified, only raw gaze data is extracted. 
%   - isDraw - boolean, specifies whether Gaze Traces nead to be plotted 
%              (useful for debug purposes)

% OUTPUT:
%   - fixations - array of structures containing fixation data for 
%     the trial parts related to specified state,
%     for the trials corresponding to specified stimuli
%     Each structure describe single trial and contains three fields:
%      - x - array of fixations x-coordinates;
%      - x - array of fixations y-coordinates;
%      - t - array of fixations durations;
%
%   - rawGaze - array of structures containing raw gaze data for 
%     the trial parts related to the specified state,
%     for the trials corresponding to the specified stimuli
%     Each structure describe single trial and contains three fields:
%      - x - array of gaze x-coordinates;
%      - y - array of gaze y-coordinates;
%      - t - array of gaze durations;
%      - speed - array of gaze speeds for each sample;
%      - timestamp - array of timestamp of this data sample;
%
%   - trialIndices - indices of trials corresponding to the specified stimuli 
%

  if (nargin < 2)
    error('Too few parameters! Please pass to the function at least the trial structure and the state of interest');
  end 
  if (nargin < 3)
    stimul = []; % data for all stimuli is requested
  end 
  [rawGaze, trialIndices] = getRawTrialData(trial, state, stimul);
  
  fixation = [];
  if ((nargin >= 4) && (isfield( fixSelector, 'method') ))
    if (nargin < 5)
      isDraw = false;
    end
    if (isDraw)
      figure('Name', ['Gaze Traces: Stimul: ' num2str(stimul) ', state: ' state])
    end    
    if (strcmp(fixSelector.method, 'velocity-based' ))
      if (~isfield( fixSelector, 'speedThreshold'))
        error('Please specify field speedThreshold for fixSelector structure (forth argument)!' );
      end       
      if (~isfield( fixSelector, 'method'))
        fixSelector.durationThreshold = 0; %we accept all fixations
      end  
      fixation = getFixVelocityBased(rawGaze, fixSelector.speedThreshold, fixSelector.durationThreshold, isDraw);
    elseif (strcmp(fixSelector.method, 'dispersion-based' ))
      if (~isfield( fixSelector, 'dispersionThreshold'))
        error('Please specify field dispersionThreshold for fixSelector structure (forth argument)!' );
      end       
      if (~isfield( fixSelector, 'method'))
        fixSelector.durationThreshold = 0; %we accept all fixations
      end  
      fixation = getFixDispersionBased(rawGaze, fixSelector.dispersionThreshold, fixSelector.durationThreshold, isDraw);
    else
      error('Specified method for fixation detection is not implemented. Set the field "method" to dispersion-based or velocity-based!' );
    end     
  end  
end


% getRawTrialData extract raw gaze data for given state from trials where given stimulus was presented
function [rawData, selectedTrialIndex] = getRawTrialData(trial, state, stimul)
  %select all trials where specified stimul was presented
  if (isempty(stimul))    %if all stimuli are of interest
    selectedTrialIndex = 1:length(trial); %select all trials
  else       
    selectedTrialInCell = strfind({trial.caption}, stimul);   
    selectedTrialIndex = find( cellfun(@(x) ~isempty(x), selectedTrialInCell) ); 
  end 
  
  %select the specified state
  selectedState = [state 'Data'];   
  rawData = struct('x', getTrialCells(trial(selectedTrialIndex), selectedState, 'GazeX'), ...
                   'y', getTrialCells(trial(selectedTrialIndex), selectedState, 'GazeY'), ...
                   't', getTrialCells(trial(selectedTrialIndex), selectedState, 'GazeTime'), ...
                   'speed', getTrialCells(trial(selectedTrialIndex), selectedState, 'GazeSpeed'), ...
                   'timestamp', getTrialCells(trial(selectedTrialIndex), selectedState, 'TimeStamp'));                     
end


function timeSeriesCells = getTrialCells(trials, selectedState, fieldName )
	timeSeriesCells = arrayfun(@(tr) [tr.(selectedState).(fieldName)]', trials, 'UniformOutput', false);
end
  

function fixation = getFixVelocityBased(rawPos, speedThreshold, fixationDurationThreshold)
  %incomplete
  nTrial = length(rawPos);
  fixation = repmat(struct('x', [], 'y', [], 't', []), 1, nTrial);
  for iTrial = 1:nTrial
    nDataPoints = length(rawPos(iTrial).x);
    saccadeIndex = find(rawPos(iTrial).speed > speedThreshold);
    if (saccadeIndex(1) > 1)
      saccadeIndex = [0, saccadeIndex];
    end
    if (saccadeIndex(end) < nDataPoints)
      saccadeIndex = [saccadeIndex, nDataPoints];      
    end
    interSaccadeTime = rawPos(iTrial).timestamp(saccadeIndex(2:end)) - rawPos(iTrial).timeInTrial(saccadeIndex(1:end-1) + 1);
    
    nFixation = length(interSaccadeTime);
    
    fixationDuration = zeros(1, nDataPoints);
    for iFixation = 1:nFixation
      currentFixIndices = (saccadeIndex(iFixation)+1):(saccadeIndex(iFixation+1)-1);
      fixationDuration(currentFixIndices) = interSaccadeTime(iFixation);        
    end
    fixationIndex = fixationDuration > fixationDurationThreshold;
    fixation(iTrial).x = rawPos(iTrial).x(fixationIndex);
    fixation(iTrial).y = rawPos(iTrial).y(fixationIndex);
    fixation(iTrial).t = rawPos(iTrial).t(fixationIndex);
  end	
end


function fixation = getFixDispersionBased(rawPos, dispThreshold, fixationDurationThreshold, isDraw)
% see Salvucci D, Goldberg J (2000) Identifying fixations and saccades in eye-tracking protocols. In, pp 71?78.

  nTrial = length(rawPos);
  fixation = repmat(struct('x', [], 'y', [], 't', []), 1, nTrial);
  if (isDraw)                                           
    nTrialCol = floor(sqrt(2*nTrial));
    nTrialRow = ceil(nTrial/nTrialCol);       
  end  
  for iTrial = 1:nTrial    
    nFix = 0;
    fixWindowStart = 1;
    isFix = false;
    fixWindowEnd = find(rawPos(iTrial).timestamp > rawPos(iTrial).timestamp(fixWindowStart) + fixationDurationThreshold, 1);
    nDataPoints = length(rawPos(iTrial).x);
    
    if (isDraw)   
      xfix = zeros(size(rawPos(iTrial).x));
      yfix = xfix;
    end  
    while (fixWindowEnd <= nDataPoints)
      fixIndices = fixWindowStart:fixWindowEnd;
      dx = max(rawPos(iTrial).x(fixIndices)) - min(rawPos(iTrial).x(fixIndices));
      dy = max(rawPos(iTrial).y(fixIndices)) - min(rawPos(iTrial).y(fixIndices));      
      dispersion = (dx + dy)/2;
      
      if (dispersion < dispThreshold)
        isFix = true;
        fixWindowEnd = fixWindowEnd + 1;
      else  
        if (isFix)   %save fixation
          nFix = nFix + 1;        
          fixIndices = fixWindowStart:fixWindowEnd-1;
          %fixation time is sum of all times
          fixation(iTrial).t(nFix) = sum(rawPos(iTrial).t(fixIndices)); 
          %fixation pos is the average of all pos (taking time of each pos into account)
          fixation(iTrial).x(nFix) = dot(rawPos(iTrial).x(fixIndices), rawPos(iTrial).t(fixIndices))/fixation(iTrial).t(nFix);
          fixation(iTrial).y(nFix) = dot(rawPos(iTrial).y(fixIndices), rawPos(iTrial).t(fixIndices))/fixation(iTrial).t(nFix);
          
          isFix = false;                    
          fixWindowStart = fixWindowEnd; 

          if (isDraw)
            xfix(fixIndices) = fixation(iTrial).x(nFix);
            yfix(fixIndices) = fixation(iTrial).y(nFix);
          end 
        else 
          fixWindowStart = fixWindowStart + 1;
        end 
        if (fixWindowStart > nDataPoints)
          break;
        end  
        fixWindowEnd = find(rawPos(iTrial).timestamp > rawPos(iTrial).timestamp(fixWindowStart) + fixationDurationThreshold, 1);          
      end  
    end
    if (isFix)  %save last fixation
      nFix = nFix + 1;
      %fixation time is sum of all times
      fixation(iTrial).t(nFix) = sum(rawPos(iTrial).t(fixIndices)); 
      %fixation pos is the averageof all pos (taking time of each pos into account)
      fixation(iTrial).x(nFix) = dot(rawPos(iTrial).x(fixIndices), rawPos(iTrial).t(fixIndices))/fixation(iTrial).t(nFix);
      fixation(iTrial).y(nFix) = dot(rawPos(iTrial).y(fixIndices), rawPos(iTrial).t(fixIndices))/fixation(iTrial).t(nFix);
    end
    
    if (isDraw) 
      maxY = max(rawPos(iTrial).y);
      maxX = max(rawPos(iTrial).x);
      subplot(nTrialRow, nTrialCol, iTrial);
      hold on;
      plot(rawPos(iTrial).x/maxX, 'b-')
      plot(-rawPos(iTrial).y/maxY, 'b--')
      plot(xfix/maxX, 'r--')
      plot(-yfix/maxY, 'm--')

      hold off;    
    end
  end  
end
  
  