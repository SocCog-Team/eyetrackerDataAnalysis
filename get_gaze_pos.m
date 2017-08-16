function [fixation, rawPos, trialIndices] = get_gaze_pos(trial, state, stimul, fixSelector, isDraw)
  if (nargin < 2)
    error('Too few parameters! Please pass to the function at least the trial structure and the state of interest');
  end 
  if (nargin < 3)
    stimul = 0;
  end 
  [rawPos, trialIndices] = get_raw_trial_data(trial, state, stimul);
  
  %%%
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
      fixation = getFixVelocityBased(rawPos, fixSelector.speedThreshold, fixSelector.durationThreshold, isDraw);
    elseif (strcmp(fixSelector.method, 'dispersion-based' ))
      if (~isfield( fixSelector, 'dispersionThreshold'))
        error('Please specify field dispersionThreshold for fixSelector structure (forth argument)!' );
      end       
      if (~isfield( fixSelector, 'method'))
        fixSelector.durationThreshold = 0; %we accept all fixations
      end  
      fixation = getFixDispersionBased(rawPos, fixSelector.dispersionThreshold, fixSelector.durationThreshold, isDraw);
    else
      error('Specified method for fixation detection is not implemented. Set the field "method"  to dispersion-based or velocity-based!' );
    end     
  end  
end



function [rawData, selectedTrialIndex] = get_raw_trial_data(trial, state, stimul)
  if (nargin < 2)
    error('Too few parameters! Please pass to the function at least the trial structure, the state of interest and the presented stimuli');
  end 
  
  %select all trials where specified stimul was presented
  if ((nargin < 3) || (stimul == 0))
    %consider all types of stimuli
    selectedTrialIndex = 1:length(trial);
  else    
    selectedTrialInCell = arrayfun(@(x) find([trial.stimulIndex] == x), stimul, 'UniformOutput', false);   
    selectedTrialIndex = sort([selectedTrialInCell{:}]); 
  end 
  
  %select the specified state
  selectedState = [state 'Data'];
  %{
  isThisStateName = strcmp({'fix1', 'fix2', 'scrambled', 'stimulus'}, state);
  if (any(isThisStateName)) 
    selectedState = [state 'Data'];
  else    
    error('Incorrect state name! Valid names are: fix1, scrambled, fix2, stimulus');
  end    
  %}
  
  rawData = struct('x', getTrialCells(trial(selectedTrialIndex), selectedState, 'GazeX'), ...
                   'y', getTrialCells(trial(selectedTrialIndex), selectedState, 'GazeY'), ...
                   't', getTrialCells(trial(selectedTrialIndex), selectedState, 'GazeTime'), ...
                   'speed', getTrialCells(trial(selectedTrialIndex), selectedState, 'GazeSpeed'), ...
                   'timestamp', getTrialCells(trial(selectedTrialIndex), selectedState, 'TimeStamp'));                     
end


function timeSeriesCells = getTrialCells(trials, selectedState, fieldName )
	timeSeriesCells = arrayfun(@(tr) [tr.(selectedState).(fieldName)]', trials, 'UniformOutput', false);
end
  

function fixation = getFixVelocityBased(rawPos, speedThreshold, fixationDurationThreshold, isDraw)
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
  
  