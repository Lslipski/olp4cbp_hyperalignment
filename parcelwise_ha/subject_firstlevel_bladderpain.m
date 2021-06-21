% Run first level models for bladderpain task for all subjects in anatomical
% space or connectivity-based parcel hyperalignment space. This script takes
% the space of the brain data ('AA' for anatomical
% or 'CHA' for hyperaligned common space), 
% This is based on Yoni's previous first level script found
% at OLP4CBP/scripts/analyses/SubjectLevelAnalysisScripts/run_subject_firstlevel_sponpain.m
% 
% Before running this script, make sure all parcels from hyperalignment have been combined using:
% /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/scripts/parcelwise_ha/helper_scripts/srun_combine_cha_parcels_into_brain.sh

function run_subject_firstlevel_bladderpain(align)

%% var set up and path setting
if nargin==0 % defaults just for testing
        align = 'AA';
    end

align

% Load repositories
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/OLP4CBP'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/CanlabCore'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/Neuroimaging_Pattern_Masks'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/spm12'));

% Dirs
helperdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/helperfiles';
AA_clean = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/data/bladderpain/cleaned';
CHA_clean = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/common_spaces/subs-201_parcels-487';
savedir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/results/fl_glm';

% load template participant with correct voxel size to use for glm
template = fmri_data('/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP/Imaging/preprocessed/fmriprep/sub-M80344098/ses-1/func/sub-M80344098_ses-1_task-bladder_space-MNI152NLin2009cAsym_desc-preproc_bold.nii');
template.dat = template.dat';
myindices = load('/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/helper_files/parcel_indices.mat');
[bladderpain, sponpain, bothpain] = get_T1_participant_lists();
atl = load_atlas('canlab2018_2mm');

for sub = 1:size(bothpain,1) % for each subject
    thissub = bothpain{sub};
    if strcmp(align, 'AA')
        thisdat = load(fullfile(AA_clean, strcat(thissub, '_ses-1_cleaned-filtered-bladderpain.mat'))); %1613 x 100105
        braindat = template;
        braindat.dat = zscore(thisdat.rbrain)';
        braindat = apply_mask(braindat, atl); % remove features that are 0 in the atlas, which were not included in HA
    elseif strcmp(align, 'CHA')
        thisdat = load(fullfile(CHA_clean, strcat(thissub, '_commonspace_noZ_subs-201_parcels-487.mat'))); % common_space: [1613x100105 double]
        braindat = template; 
        braindat.dat = thisdat.common_space';

    else
        error('Must specify align variable as either AA or CHA');
    end

    %load pain regressor
    thisreg = load(fullfile(AA_clean, strcat(thissub, '_ses-1_cleaned-filtered-bladderpain-regressor.mat'))); %rpain: [1613x1 double]
    thisreg.rpain = intercept(thisreg.rpain, 'add');
    % add regressor/intercept to dat object
    braindat.X = thisreg.rpain;

    % run 1st level GLM model
    fprintf(['Preparing 1st level model for BLADDERPAIN for: ' bothpain{sub} '\n'])
    regression_results_ols = regress(braindat, ...
        'analysis_name', 'Bladder Pain GLM (Cleaned)','grandmeanscale', 'nodisplay');

    % save individual's regression output
    savefile = fullfile(savedir, align, strcat(bothpain{sub}, '_FL_regressor_indvidual_model_noZ.mat'));
    save(savefile, 'regression_results_ols');

    if sub == 1 % first time through loop, create group fmri_data obj
        cleaned_group_betas = braindat; % use copy of existing obj since it's already in correct dat dimensions
        cleaned_group_betas.X = []; % empty out first sub's X data
        cleaned_group_betas.dat = regression_results_ols.b.dat(:,1); % add first sub's beta map to group object

        cleaned_group_betas.covariates = zeros(length(bothpain), 2); % create zeros to fill in variance values
        cleaned_group_betas.covariates(sub, 1) = var(braindat.X(:,1)); % this sub's regressor variance
        cleaned_group_betas.covariates(sub, 2) = var(regression_results_ols.b.dat(:,1)); % this sub's beta map variance
    else
        cleaned_group_betas.dat = [cleaned_group_betas.dat regression_results_ols.b.dat(:,1)]; % add this sub's beta to group obj
        cleaned_group_betas.covariates(sub, 1) = var(braindat.X(:,1)); % this sub's regressor variance
        cleaned_group_betas.covariates(sub, 2) = var(regression_results_ols.b.dat(:,1)); % this sub's beta map variance
    end

end

savefile = fullfile(savedir, align, 'all_subject_FL_betamaps_noZ.mat');
save(savefile, 'cleaned_group_betas');

end















