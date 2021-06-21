% This script loads the preprocessed bladder brain data, the bladder pain
% regressor, and the nuisance covariates. It then regresses the nuisance
% covariates out of the bladder brain data and the bladder pain regressor.
% It saves each of these objects for all Time 1 subjects.

savepath = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/data/bladderpain/cleaned'
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/CanlabCore'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/Neuroimaging_Pattern_Masks'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/spm12'));
path_to_repos = '/dartfs-hpc/rc/home/1/f0040y1/repositories/';

% Load metadata table for full study
load(fullfile(path_to_repos, 'OLP4CBP', 'data','subject_metadata.mat'))
disp('Loaded subject_metadata.mat');

% select for Time 1 subjects only
mytabl = tabl(tabl.time==1, :); % maybe also only use patients? is_patient==1. I can't remember what we decided

for i = 1:height(mytabl) % for each subj
    i
    sprintf('sub-%04d', mytabl.id(i))
    
    %% load preproc bladder data, at time 1
    preprocdata_basedir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP/Imaging/preprocessed/fmriprep';
    fname = filenames(fullfile(preprocdata_basedir, ['sub-' mytabl.URSI(i,:)], 'ses-1', 'func', '*task-bladder_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'))
    if size(fname,1) == 0
        fname = filenames(fullfile(preprocdata_basedir, ['sub-' mytabl.URSI(i,:)], 'ses-1', 'func', '*task-bladder_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'))
    end
    if size(fname,1) == 0 % if brain data does not exist, skip participant
        disp('No Brain Data. Skipping Participant: ')
        mytabl.id(i)
        mytabl.URSI(i, :)
        continue
    end
    
    bladder_brain = fmri_data(fname); % import brain data
    
    %% load in pain regressor and nuisance covs
    % proj_basedir = '/Volumes/f0040y1/CANlab/labdata/projects/OLP4CBP/';
    proj_basedir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/';
    confound_pain_fname = fullfile(proj_basedir, 'first_level', sprintf('sub-%04d', mytabl.id(i)),'ses-01', 'spm_modeling', 'bladder_confounds.mat')
    
    if isfile(confound_pain_fname) == 0 % if pain data DNE, skip participant
       disp('No Pain Data. Skipping Participant: ')
       mytabl.id(i)
       mytabl.URSI(i, :)
       continue 
    end
    
    load(confound_pain_fname); % should load in R 
    disp('Loaded bladder_confounds.mat')
    
    % our important variables to use going forward
    pain_reg = R(:,1);
    nuis_covs = R(:, 2:end);
   
    % set up discrete cosine transform for temporal filtering and add to nuis_covs
    K_input = struct('RT', .46, 'HParam', 100, 'row', ones(1, size(nuis_covs,1)));
    K = spm_filter(K_input);
    K = K.X0;

    nuis_covs = [nuis_covs K];

    %% regress nuis covs out of brain data
    [rbrain, Xbrain] = resid(nuis_covs, bladder_brain.dat(:,16:end)', 1);
    % use resid command, i think. also put back in mean of each voxel (?)
    
    
    %% regress nuis covs out of pain regressor
    [rpain, Xpain] = resid(nuis_covs, pain_reg, 1);
    
    
    %% save out cleaned brain data and residualized pain regressor. that's the end of this script.
    savefile = fullfile(savepath,strcat(['sub-' mytabl.URSI(i,:)], '_ses-1', '_cleaned-filtered-bladderpain.mat'))
    save(savefile, 'rbrain');
    
    regfile = fullfile(savepath,strcat(['sub-' mytabl.URSI(i,:)], '_ses-1', '_cleaned-filtered-bladderpain-regressor.mat'))
    save(regfile, 'rpain');
    
    
end
