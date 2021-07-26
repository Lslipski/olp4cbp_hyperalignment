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
%function run_subject_firstlevel_bladderpain(align, sub)

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
%AA_clean = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/data/bladderpain/cleaned';
AA_regressor = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/analysis/regressors/raw_from_yoni';
AA_brain = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/data/bladderpain/raw';
CHA_clean = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/common_spaces/subs-201_parcels-487';
savedir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/results/match2yoni';



% load template participant with correct voxel size to use for glm
template = fmri_data('/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP/Imaging/preprocessed/fmriprep/sub-M80344098/ses-1/func/sub-M80344098_ses-1_task-bladder_space-MNI152NLin2009cAsym_desc-preproc_bold.nii');
template.dat = template.dat';
myindices = load('/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/helper_files/parcel_indices.mat');
[bladderpain, sponpain, bothpain] = get_T1_participant_lists();
%flRoot = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/first_level';
%modelname = 'bladder_pain_aCompCor_antpost';
%fnames = filenames(fullfile(flRoot, 'sub-*', 'ses-01', modelname, 'beta_0002.nii'), 'char'); %beta_0001 is the rating regressor, 0002 is pain/stim reg
%bothpain = fnames(:,75:82);

atl = load_atlas('canlab2018_2mm');

for sub = 1:size(bothpain,1) % for each subject
%for sub = sub % to be used with slurm jobarray
    thissub = bothpain{sub};
    if strcmp(align, 'AA')
        thisdat = load(fullfile(AA_brain, strcat(thissub,'_bladderpain_space-100105_raw_timeseries.mat'))); %1613 x 100105
        braindat = template;
        braindat.dat = thisdat.bladder_pain_ts(:,16:end);
        atl = resample_space(atl, braindat);
        %braindat.dat = zscore(thisdat.rbrain)'; % z scores brain data
        braindat = apply_mask(braindat, atl); % remove features that are 0 in the atlas, which were not included in HA
    elseif strcmp(align, 'CHA')
        thisdat = load(fullfile(CHA_clean, strcat(thissub, '_commonspace_noZ_subs-201_parcels-487.mat'))); % common_space: [1613x100105 double]
        braindat = template; 
        braindat.dat = thisdat.common_space';

    else
        error('Must specify align variable as either AA or CHA');
    end

    %load pain regressor
    thisreg = load(fullfile(AA_regressor, strcat(thissub, '_ses-1_raw_pain_regressor.mat'))); %rpain: [1613x1 double]
    %thisreg.rpain = intercept(thisreg.pain_reg(:,1), 'add');
    nuisance_covs = load(fullfile(AA_regressor, strcat(thissub, '_ses-1_nuisance_covariates.mat')));
    design_mat = [thisreg.pain_reg nuisance_covs.nuis_covs];
    % add regressor/intercept to dat object
    braindat.X = design_mat;
    %vifs = getvif(design_mat);

    % run 1st level GLM model
    fprintf(['Preparing 1st level model for BLADDERPAIN for: ' bothpain{sub} '\n'])
    sub
    regression_results_ols = regress(braindat, ...
        'analysis_name', 'Bladder Pain GLM (Cleaned)','grandmeanscale', 'nodisplay');

    % save individual's regression output
    savefile = fullfile(savedir, align, strcat(bothpain{sub}, '_FL_regressor_individual_model.mat'));
    save(savefile, 'regression_results_ols', '-v7.3');

    if sub == 1 % first time through loop, create group fmri_data obj
        cleaned_group_betas = braindat; % use copy of existing obj since it's already in correct dat dimensions
        cleaned_group_betas.image_names = '';
        cleaned_group_betas.metadata_table.URSI =  bothpain;
        cleaned_group_betas.X = []; % empty out first sub's X data
        cleaned_group_betas.dat = regression_results_ols.b.dat(:,1); % add first sub's beta map to group object

        cleaned_group_betas.covariates = zeros(length(bothpain), 4); % create zeros to fill in variance values
        cleaned_group_betas.covariates(sub, 1) = var(braindat.X(:,1)); % this sub's regressor variance
        cleaned_group_betas.covariates(sub, 2) = var(regression_results_ols.b.dat(:,1)); % this sub's beta map variance
        %cleaned_group_betas.covariates(sub, 3) = vifs(1);
        cleaned_group_betas.covariates(sub, 3) = size(nuisance_covs,2);
       % cleaned_group_betas.covariate_names = {'regressor_variance' 'beta_map_variance' 'pain_regressor_vif' 'number_of_nuisance_covs'};
        cleaned_group_betas.covariate_names = {'regressor_variance' 'beta_map_variance'  'number_of_nuisance_covs'};
    else
        cleaned_group_betas.dat = [cleaned_group_betas.dat regression_results_ols.b.dat(:,1)]; % add this sub's beta to group obj
        cleaned_group_betas.covariates(sub, 1) = var(braindat.X(:,1)); % this sub's regressor variance
        cleaned_group_betas.covariates(sub, 2) = var(regression_results_ols.b.dat(:,1)); % this sub's beta map variance
       % cleaned_group_betas.covariates(sub, 3) = vifs(1);
        cleaned_group_betas.covariates(sub, 3) = size(nuisance_covs,2);
    end
    savefile = fullfile(savedir, align, 'all_subject_FL_betamaps_noZ.mat');
    save(savefile, 'cleaned_group_betas');
end

end















