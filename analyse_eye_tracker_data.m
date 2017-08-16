function [trial, dataTable, trialStruct] = analyse_eye_tracker_data(filename, stimulName, needCorrectTimeStamps)
  dataTable = fnParseEventIDETrackerLog_simple_v01(filename, 'Primatar_20170714');   
  %ds = fnParseEventIDETrackerLog_simple_v01(filename, 'Primatar_20170714');   
  %dataTable = dataset2table(ds); 
  %clear ds;
  
  dataTable.CurrentEvent = categorical(dataTable.CurrentEvent);
  %dataTable.UserField = categorical(dataTable.UserField);
  
  [allStates, ~, stateIndex]  = unique(dataTable.CurrentEvent);
  [allStimuli, ~, stimuliIndices] = unique(dataTable.UserField);
  
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
  dt(dt == 0) = 0.001; %replace zero by 1 us
  dataTable.GazeTime = ([dt(1); dt] + [dt; dt(end)])/2;
  
  %compute gaze speed in pixels/s
  %speed = 1000.0*sqrt(diff(dataTable.GazeX).^2 + diff(dataTable.GazeY).^2)./dt;  
  %compute gaze speed in pixels/ms
  speed = sqrt(diff(dataTable.GazeX).^2 + diff(dataTable.GazeY).^2)./dt;
  dataTable.GazeSpeed = [speed; 0]; %last value of speed is set to zero
  
  %create trials
  %define borders of the states
  stateChange = stateIndex(2:end) - stateIndex(1:end-1);
  stateChange(stateChange ~= 0) = 1; 
  stateStart = [0; stateChange];
  stateEnd = [stateChange; 0];
  
  fixationStart = find((stateStart == 1) & (dataTable.CurrentEvent == 'Top event>Fix 1'));
  fixationEnd = find((stateEnd == 1) & (dataTable.CurrentEvent == 'Top event>Fix 1'));
  nTrial = length(fixationStart)/2; %for each trial there are two fixations

  trialStruct = struct('fix1Start', fixationStart(1:2:end), ...  % uneven fixations indicate trial start 
                       'fix1End', fixationEnd(1:2:end), ...
                       'fix2Start', fixationStart(2:2:end), ...  % even fixations are before stimulus presentations
                       'fix2End', fixationEnd(2:2:end), ...
                       'scrambledStart', find((stateStart == 1) & (dataTable.CurrentEvent == 'Top event>Scrambled Face')), ...
                       'scrambledEnd', find((stateEnd == 1) & (dataTable.CurrentEvent == 'Top event>Scrambled Face')), ...
                       'stimulStart', find((stateStart == 1) & (dataTable.CurrentEvent == 'Top event>Stimulus')), ...
                       'stimulEnd', find((stateEnd == 1) & (dataTable.CurrentEvent == 'Top event>Stimulus')), ...
                       'trialCaption', [], ...
                       'stimulus', []);  
  
%{  
  trialStruct = struct('fix1Start', num2cell(fixationStart(1:2:end)), ...  % uneven fixations indicate trial start 
                       'fix1End', num2cell(fixationEnd(1:2:end)), ...
                       'fix2Start', num2cell(fixationStart(2:2:end)), ...  % even fixations are before stimulus presentations
                       'fix2End', num2cell(fixationEnd(2:2:end)), ...
                       'scrambledStart', find((stateStart == 1) & (dataTable.CurrentEvent == 'Top event>Scrambled Face')), ...
                       'scrambledEnd', find((stateEnd == 1) & (dataTable.CurrentEvent == 'Top event>Scrambled Face')), ...
                       'stimulStart', find((stateStart == 1) & (dataTable.CurrentEvent == 'Top event>Stimulus')), ...
                       'stimulEnd', find((stateEnd == 1) & (dataTable.CurrentEvent == 'Top event>Stimulus')), ...
                       'stimulus', []);
  
  % scrambled pictures presentations
  startArray = num2cell( find((stateStart == 1) & (dataTable.CurrentEvent == 'Top event>Scrambled Face')) );
  [trialStruct.scrambledStart] = startArray{:};
  endArray = num2cell( find((stateEnd == 1) & (dataTable.CurrentEvent == 'Top event>Scrambled Face')) );
  [trialStruct.scrambledEnd] = endArray{:};
  % stimulus presentations
  startArray = num2cell( find((stateStart == 1) & (dataTable.CurrentEvent == 'Top event>Stimulus')) );
  [trialStruct.stimulStart] = startArray{:};
  endArray = num2cell( find((stateEnd == 1) & (dataTable.CurrentEvent == 'Top event>Stimulus')) );
  [trialStruct.stimulEnd] = endArray{:};
  trialCaption = dataTable.UserField([trialStruct.fix1Start]);  
%}  
  trialStruct.trialCaption = dataTable.UserField(trialStruct.fix1Start);
  nStimul = length(stimulName);
  for iStimul = 1:nStimul
    %find all captions containing current stimulus name 
    substrPos = strfind(trialStruct.trialCaption, stimulName{iStimul});  
    %set current stimulus for trials with labels containing this stimulus name
    trialStruct.stimulus(cellfun('isempty', substrPos) == 0) = iStimul; 
  end  
  
  trial = struct('stimulIndex', num2cell(trialStruct.stimulus), ...
                 'fix1Data', [], 'fix2Data', [], 'scrambledData', [], 'stimulusData', [] );
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



