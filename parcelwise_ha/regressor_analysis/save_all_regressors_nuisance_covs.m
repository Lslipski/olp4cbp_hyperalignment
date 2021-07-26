savepath = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/analysis/regressors';
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/CanlabCore'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/Neuroimaging_Pattern_Masks'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/spm12'));
path_to_repos = '/dartfs-hpc/rc/home/1/f0040y1/repositories/';

% Load metadata table for full study
load(fullfile(path_to_repos, 'OLP4CBP', 'data','subject_metadata.mat'))
disp('Loaded subject_metadata.mat');
% select for Time 1 subjects only
mytabl = tabl(tabl.time==1, :); % maybe also only use patients? is_patient==1. I can't remember what we decided


for i = 1:height(mytabl)
    proj_basedir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/';
    confound_pain_fname = fullfile(proj_basedir, 'first_level', sprintf('sub-%04d', mytabl.id(i)),'ses-01', 'spm_modeling', 'bladder_confounds.mat'); 
    if isfile(confound_pain_fname) == 0 % if pain data DNE, skip participant
        disp('No Pain Data. Skipping Participant: ')
        mytabl.id(i)
        mytabl.URSI(i, :)
        continue 
    end
    % our important variables to use going forward
    pain_reg = R(:,1);
    nuis_covs = R(:, 2:end);
    % save raw regressor
    savefile = fullfile(savepath, strcat(['sub-' mytabl.URSI(i,:)], '_ses-1', '_raw_pain_regressor.mat'));
    save(savefile, 'pain_reg');
    % save nuisance covariates
    savefile = fullfile(savepath, strcat(['sub-' mytabl.URSI(i,:)], '_ses-1', '_nuisance_covariates.mat'));
    save(savefile, 'nuis_covs');
end
