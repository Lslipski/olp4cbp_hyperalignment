%% This script runs a subject-by-subject univariate GLM using SPM on all
% participants included in the low back pain study. It takes as input
% an integer, which tells it which subject in the univariate_subject_table to load,
% a directory to where the brain data for that subject is, and a string indicating
% the type of alignment that was done to the data (either 'AA' or 'CHA');
%
% It is used for both the anatomical and hyperalignment bladderpain analyses.


function run_subject_firstlevel_bladder_pain_expdecay_HA(sub, datadir, regdir,  align_type)

% set folders and repos
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/OLP4CBP'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/CanlabCore'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/Neuroimaging_Pattern_Masks'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/spm12'));
fl_dir  = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/results/fl_glm';
helper_files = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/helper_files';

ndummies = 15;
TR = .46;

% load participant list to get ID and URSI
load('univariate_subject_table.mat');
thisid = table2array(univariate_subject_table(sub,1));
thisursi = table2array(univariate_subject_table(sub,2));

% load template canlab data object to hold this sub's data
glm_obj = fmri_data(fullfile(helper_files, 'template_nii_in_100105_space.nii'));
glm_obj.image_names = '';
glm_obj.fullpath = [];
glm_obj.files_exist = [];

% load brain data
thisf = filenames(fullfile(datadir, strcat('sub-',thisursi, '*.mat')));
load(thisf{1}); % loads as bladder_pain_ts
bladder_pain_ts = bladder_pain_ts(:, ndummies + 1:end); % discard dummies

% load nuisance regressors
thisreg = filenames(fullfile(regdir, strcat('sub-',thisursi, '*nuisance_covariates*.mat')));
load(thisreg{1}); % loads as nuis_covs

% load pain regressor
thispain = filenames(fullfile(regdir, strcat('sub-',thisursi, '*raw_pain*.mat')));
load(thispain{1}); % loads as pain_reg

% prep glm_obj for regression
glm_obj.dat = bladder_pain_ts; % inject bladder timeseries into glm object
design_mat = [pain_reg nuis_covs];
design_mat = intercept(design_mat, 'add');
glm_obj.X = design_mat;

%% Model for bladder task
print_header(['Preparing 1st level model for BLADDER task for ' thisursi ' / ' thisid], ['Alignment type: ' align_type, '   Job Iteration: ', num2str(sub)]);

subfolder = fullfile(fl_dir, thisursi, 'bladder_pain_aCompCor_antpost'); 
if ~exist(subfolder, 'dir')
   mkdir(subfolder)
end

% run GLM with regress() function
regression_results_ols = regress(glm_obj, ...
        'analysis_name', 'Bladder Pain GLM', 'grandmeanscale',  'nodisplay');

savefile = fullfile(subfolder, strcat('sub-',thisursi, '_FL_regressor_individual_model.mat'));
save(savefile, 'regression_results_ols', '-v7.3');






