# Analysis of EventIDE eye-tracker files
this file describes the eyetrackerDataAnalysis project, a set of MATLAB scripts for parsing EventIDE eye-tracker files and analysing eye-tracking data for the "Attention to PRIMATAR faces" experiment

# User instruction.
To process the eye-tracker data you need to set the parameters of analysis in **eye_tracker_analysis_basic_primatar_vs_real_script.m** and run this script
1. specify paths to the eye-tracker files in the ``files`` cell array.
2. for each file 
2.1 specify thesession name in the ``sessionName`` cell array. It will be used for generating the output files.
2.2 specify whether the stimuli images in a session were transformed for the use in the dyadic platform setup in ``dyadicPlatformImageTransform`` boolean array
The values should be ``true`` for data after 21.02.2019 and ``false`` otherwise.
3. Specify paths to stimuli images in ``stimulImage`` cell array.
4. For each image specify coordinates of eyes and mouth in ``eyesImageRect`` and ``mouthImageRect`` arrays, respectively.
5. Specify plotting parameters in ``plotSetting`` structure.
6. Speciffy how different obfuscation levels should be treated in variable ``nObfuscationLevelToConsider``
6.1 Set ``nObfuscationLevelToConsider = 1;`` if only normal obfuscation should be considered.
6.2 Set ``nObfuscationLevelToConsider = 2;`` if normal&moderate obfuscations should be considered.
6.3 Set ``nObfuscationLevelToConsider = 3;`` if all obfuscation levels should be considered.
6.4 Set ``nObfuscationLevelToConsider = 0;`` if you want to compare the effect of obfuscation across all stimuli.
7. After all this parameters are set to the desired values, please run the script eye_tracker_analysis_basic_primatar_vs_real_script.m. Please note that it takes a while to prepare all the images. Results are saved in the same folder where the script is located, in subfolders corresponding to the "sessionName" entries

# EventIDE eye-tracker file format description
files contists of rows of values separated by ";".  
1. stimul (= trial caption) - description of the presented image. There are 15 types of stimuli defined by two parameters: *originalImage* and *obfuscationLevel*. The stimuli labaling has the format 'originalImage - obfuscationLevel'.
1.1 Original image (according to the ``stimulImage`` cell array, in present experiments 5 images were used): 'Real face 1', 'Real face 2', 'Real face 3', 'Realistic avatar', 'Unrealistic avatar'. 
1.2 Obfuscation level: 'Normal', 'Moderate obfuscation', 'Strong obfuscation' 

2 State: 
2.1 'fix1' - initial fixation
2.2 'stimulus' - stimulus presentation
2.3 'fix2' - fixation prior to scrambled image presentation
2.4 'scrambled' - scrambled image presentation

# Structure of the project
1. folder **Stimuli** contains images used in the experiment

2. **eye_tracker_analysis_basic_primatar_vs_real_script.m** - main script, runnung the analysis

3. **analyse_eyetracker_experiment.m** - function performing the analysis for a single EventIDE eye-tracker files

4. Intermediate-level functions:
4.1. **read_primatar_data_from_file** reads data of primatar experiment trials from a single EventIDE eye-tracker file and stores it in an array of structures ``trial`` describing trials.
4.2. **get_gaze_pos.m** extracts raw gaze data and computes fixations for them in given state from trials corresponding to the given stimulus. 
4.2. **analyse_initial_fixation.m** plots raw gazes and fixations during initial fixations across all trials
4.3. **analyse_stimul_fixation.m** plots raw gazes and fixations during sitmuli and scrambled images presentations. Also computes fixation statistics (frequencies of fixations in various regions of the stimuli image).

5. Principal data structures
5.1. ``trial`` array of structures containes data about trials for each specified stimulus. Each entry contains the following fields:
- ``caption`` - full caption of the trial
- ``fix1Data``, ``fix2Data``, ``scrambledData``, ``stimulusData`` - structures with raw gaze data for each state within the trial. Each of the structures contains the fields
        - ``GazeX`` - x gaze coordinate;
        - ``GazeY`` - y gaze coordinate;
        - ``GazeSpeed`` - gaze speed;
        - ``GazeTime`` - duration of this data sample;
        - ``TimeStamp`` - timestamp of this data sample;
``trial`` data is extracted from the eye-tracker log file means of ``read_primatar_data_from_file`` function        
        
5.2. ``fixation`` array of structures containes fixation data for the trial parts related to a specified state, for the trials corresponding to a specified stimuli. Each structure describe single trial and contains three fields:
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
6.2 **display_fixation_proportions.m**

7. auxilary functions
7.1 **remove_trials.m** - removes trials corresponding to the specified stimul from the ``trial`` data structure
7.2 **bound_gaze_pos.m**
7.3 **merge_trial_data.m** - merges x, y and t fields for fixation or rawGaze data structures across all trials
7.4 **compute_fixation_statistic.m**
7.5 **compute_fixation_statistic.m**
