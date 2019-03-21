# Analysis of EventIDE eye-tracker files

eyetrackerDataAnalysis project is a set of MATLAB scripts for parsing EventIDE eye-tracker files and analysing eye-tracking data for the "Attention to PRIMATAR faces" experiment

# User instruction

To process the eye-tracker data one needs to set the parameters of analysis in **eye_tracker_analysis_basic_primatar_vs_real_script.m** and run this script (currently all the parameters are set and one can omit steps 1-6: one needs to perform them when changes are necessary)

1. Specify paths to the eye-tracker files in the ``files`` cell array.

2. For each file 

2.1. specify the session name in the ``sessionName`` cell array. It will be used for generating the output files.

2.2. specify whether the stimuli images in a session were transformed for the use in the dyadic platform setup in ``dyadicPlatformImageTransform`` boolean array.
The values should be ``true`` for data after 21.02.2019 and ``false`` otherwise.

3. Specify paths to stimuli images in ``stimulImage`` cell array.

4. For each image specify coordinates of eyes and mouth in ``eyesImageRect`` and ``mouthImageRect`` arrays, respectively.

5. Specify plotting parameters in ``plotSetting`` structure.

6. Speciffy how different obfuscation levels should be treated in variable ``nObfuscationLevelToConsider``

6.1 Set ``nObfuscationLevelToConsider = 1;`` if only normal obfuscation should be considered.

6.2 Set ``nObfuscationLevelToConsider = 2;`` if normal&moderate obfuscations should be considered.

6.3 Set ``nObfuscationLevelToConsider = 3;`` if all obfuscation levels should be considered.

6.4 Set ``nObfuscationLevelToConsider = 0;`` if one wants to compare the effect of obfuscation across all stimuli.

7. After all these parameters are set to the desired values, please run the script eye_tracker_analysis_basic_primatar_vs_real_script.m. Please note that it takes a while to prepare all the images. Results are saved in the same folder where the script is located, in subfolders corresponding to the "sessionName" entries.

# Experiment structure

1. Experiment consists of multiple trials. Each trial is associated with a stimulus (specified in trial caption) characterizing the presented image. There are 15 types of stimuli defined by two parameters: *originalImage* and *obfuscationLevel*. 
The stimuli labeling in trial caption has the format 'originalImage - obfuscationLevel':

- originalImage (according to the ``stimulImage`` cell array, in present experiments 5 images were used): 'Real face 1', 'Real face 2', 'Real face 3', 'Realistic avatar', 'Unrealistic avatar'. 

- obfuscationLevel: 'Normal', 'Moderate obfuscation', 'Strong obfuscation' 

2. Each trial consists of the following stages: 

2.1. first initial fixation (stage label 'fix1')

2.2. first reward (eye-tracking data are not analyzed)

2.3. viewing real face (stage label 'stimulus')

2.4. second initial fixation (stage label 'fix2', eye-tracking data are not analyzed)

2.5. second reward (eye-tracking data are not analyzed)

2.6. viewing scrambled face (stage label 'scrambled')


# Structure of the project

1. folder **Stimuli** contains images used in the experiment

2. **eye_tracker_analysis_basic_primatar_vs_real_script.m** - main script, runnung the analysis

3. **analyse_eyetracker_experiment.m** - function performing the analysis for a single EventIDE eye-tracker files

4. Intermediate-level functions:

4.1. **read_primatar_data_from_file** reads data of primatar experiment trials from a single EventIDE eye-tracker file and stores it in an array of structures ``trial`` describing trials.

4.2. **get_gaze_pos.m** extracts raw gaze data and computes fixations for them in the given state from trials corresponding to the given stimulus. 

4.2. **analyse_initial_fixation.m** plots raw gazes and fixations during initial fixations across all trials.

4.3. **analyse_stimul_fixation.m** plots raw gazes and fixations during sitmuli and scrambled images presentations. Also computes fixation statistics (frequencies of fixations in various regions of the stimulus image).

5. Principal data structures

5.1. ``trial`` - array of structures that contains data about trials for each specified stimulus. Each entry contains the following fields:
- ``caption`` - full caption of the trial
- ``fix1Data``, ``fix2Data``, ``scrambledData``, ``stimulusData`` - structures with raw gaze data for each state within the trial. Each of the structures contains the fields
        - ``GazeX`` - x gaze coordinate;
        - ``GazeY`` - y gaze coordinate;
        - ``GazeSpeed`` - gaze speed;
        - ``GazeTime`` - duration of this data sample;
        - ``TimeStamp`` - timestamp of this data sample;
``trial`` data is extracted from the eye-tracker log file by means of ``read_primatar_data_from_file`` function        
        
5.2. ``fixation`` - array of structures that contains fixation data for the trial parts related to a specified state, for the trials corresponding to a specified stimuli. Each structure describe single trial and contains three fields:
- ``x`` - array of fixations x-coordinates;
- ``y`` - array of fixations y-coordinates;
- ``t`` - array of fixations durations;
``fixation`` is computed for the given state (optionally - for given stimuli only) from ``fixation`` data by means of ``get_gaze_pos`` function

5.3. ``rawGaze`` - array of structures containing raw gaze data for the trial parts related to the specified state, for the trials corresponding to the specified stimuli. Each structure describe single trial and contains three fields:
- ``x`` - array of gaze x-coordinates;
- ``y`` - array of gaze y-coordinates;
- ``t`` - array of gaze durations;
- ``speed`` - array of gaze speeds for each sample;
- ``timestamp`` - array of timestamp of this data sample;

6. Visualisation functions

6.1 **gaussian_attention_map.m** draws fixation heat maps (fixation areas are shown as 2D Gaussian distributions) overlayed with the presented image.

6.2 **display_fixation_proportions.m** draws two overview firures characterizing the experiment
- plot of fixation proportions for each stimul as a function of trial number
- bar graphs of fixation proportions averaged over stimuli presentations

6.3 **draw_error_bar.m** creates a bar graph with grouped bars and (optionally) with confidence intervals

7. auxilary functions

7.1 **remove_trials.m** removes trials corresponding to the specified stimulus from the ``trial`` data structure

7.2 **bound_gaze_pos.m** for ``fixation`` or ``rawGaze`` data structures removes all the entries with x, y lying outside of the specified region of interest (ROI)

7.3 **merge_trial_data.m** merges x, y and t fields for ``fixation`` or ``rawGaze`` data structures across all trials

7.4 **compute_fixation_statistic.m** computes durations and number of fixations for the whole face, eye and mouth regions for each trial and total over all trials (mean and confidence intervals)

7.5 **compute_time_in_region.m** calculates total duration and amount of fixations in a specified region (eyes, mouth, etc).

7.6 **fnParseEventIDETrackerLog_simple_v01.m** - eye-tracker file parser (authors - Igor Kagan, Sebastian Moeller)

7.7 **calc_cihw.m** - function for computing confidence intervales (author - Sebastian Moeller)
