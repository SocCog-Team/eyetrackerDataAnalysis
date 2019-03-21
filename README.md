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

# Structure of the project
1. folder **Stimuli** contains images used in the experiment
2. **eye_tracker_analysis_basic_primatar_vs_real_script.m** - main script, runnung the analysis
3. **analyse_eyetracker_experiment.m** - function performing the analysis for a single EventIDE eye-tracker files
4. auxilary functions
4.1 **remove_trials** - removes trials corresponding to the specified stimul from the ``trial`` data structure
