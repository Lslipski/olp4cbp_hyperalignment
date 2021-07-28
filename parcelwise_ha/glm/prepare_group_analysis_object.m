% This script works through all first level glm files and compiles beta
% estimate map estimates into a single file called
% bladder_pain_aCompCor_antpost_AA.mat

% Load repositories
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/OLP4CBP'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/CanlabCore'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/Neuroimaging_Pattern_Masks'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/spm12'));

fldir  = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/results/fl_glm';
scriptdir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/OLP4CBP/hyperalignment/scripts/parcelwise_ha/glm';
helpdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/helper_files';

%load master list of ursis
load(fullfile(scriptdir,'univariate_subject_table.mat'));

% load template fmri_data object
bladder_pain_aCompCor_antpost_AA = fmri_data(fullfile(helpdir, 'template_nii_in_100105_space.nii'));
bladder_pain_aCompCor_antpost_AA.metadata_table = univariate_subject_table;
bladder_pain_aCompCor_antpost_AA.dat = [];
bladder_pain_aCompCor_antpost_AA.image_names = [];
bladder_pain_aCompCor_antpost_AA.fullpath = '';
bladder_pain_aCompCor_antpost_AA.files_exist = logical(repmat(1,size(univariate_subject_table,1),1));
bladder_pain_aCompCor_antpost_AA.covariate_names = {'Pain Exp Decay VIFs'};

% load fl_flm files one at a time
for i = 1:height(univariate_subject_table)
    i
    % load this sub's glm file
    thisfile = fullfile(fldir, table2array(univariate_subject_table(i, 2)), 'bladder_pain_aCompCor_antpost', strcat('sub-',table2array(univariate_subject_table(i, 2)), '_FL_regressor_individual_model.mat'));
    thisglm = load(thisfile);
            
    % copy relevant info to 2nd level object
    bladder_pain_aCompCor_antpost_AA.dat(:,i) = thisglm.regression_results_ols.b.dat(:,1);
    bladder_pain_aCompCor_antpost_AA.fullpath(i,:) = thisfile;
    bladder_pain_aCompCor_antpost_AA.covariates(i) = thisglm.regression_results_ols.diagnostics.Variance_inflation_factors(1);                           
end

dat = preprocess(bladder_pain_aCompCor_antpost_AA, 'smooth', 6);
cd(fldir);
save('bladder_pain_aCompCor_antpost_AA.mat', 'dat', '-v7.3');
disp('Saved 2nd level summary file.');
