function residualize_regressors = residualize_regressors(to_remove, dcm_cutoff)
if ~exist('dcm_cutoff', 'var')
    dcm_cutoff = 180;
end
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/CanlabCore'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/Neuroimaging_Pattern_Masks'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/spm12'));
path_to_repos = '/dartfs-hpc/rc/home/1/f0040y1/repositories/';
regressordir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/analysis/regressors/raw_from_yoni';
savedir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/analysis/regressors/';
rawregs = filenames(fullfile(regressordir, '*raw_pain_regressor.mat'));
variances = zeros(length(rawregs), 2); % first column raw, second residualized
for i = 1:length(rawregs)
    [path, mysub, ext] = fileparts(x{i,:});
    sub = mysub(1:13);
    % load this sub's regressor
    reg = load(fullfile(regressordir, strcat(sub, '_ses-1_raw_pain_regressor.mat')));
    reg = reg.pain_reg;
    if strcmp(to_remove, 'nuis_covs')
        subpath = 'nuis_cov_removed';
        % load this sub's nuisance covariates matrix
        nuis_covs = load(fullfile(regressordir, strcat(sub, '_ses-1_nuisance_covariates.mat')));
        nuis_covs = nuis_covs.nuis_covs;
        % regress nuis covs out of pain regressor
        [regressor, Xpain] = resid(nuis_covs, reg, 1); % 1 adds mean back in after residualizing
        variances(i, 1) = var(reg);
        variances(i, 2) = var(regressor);
        savefile = fullfile(savedir, subpath, strcat(sub, '_regressor_nuis_covs_removed.mat'));
        save(savefile, 'regressor');
    elseif strcmp(to_remove, 'dcm')
        subpath = 'dcm_180_removed';
        % load a dcm for this sub for high pass filter
        K_input = struct('RT', .46, 'HParam', 180, 'row', ones(1, length(reg,1)));
        K = spm_filter(K_input);
        K = K.X0;
        % regress dcm out of pain regressor
        [regressor, Xpain] = resid(K, reg, 1); % 1 adds mean back in after residualizing
        variances(i, 1) = var(reg);
        variances(i, 2) = var(regressor);
        savefile = fullfile(savedir, subpath, strcat(sub, '_regressor_dcm_removed.mat'));
        save(savefile, 'regressor');
    elseif strcmp(to_remove, 'both')
        subpath = 'nuis_dcm_180_removed';
        % load this sub's nuisance covariates matrix
        nuis_covs = load(fullfile(regressordir, strcat(sub, '_ses-1_nuisance_covariates.mat')));
        nuis_covs = nuis_covs.nuis_covs;
        % load a dcm for this sub for high pass filter
        K_input = struct('RT', .46, 'HParam', 180, 'row', ones(1, length(reg,1)));
        K = spm_filter(K_input);
        K = K.X0;
        nuis_covs = [nuis_covs K];
        % regress dcm out of pain regressor
        [regressor, Xpain] = resid(nuis_covs, reg, 1); % 1 adds mean back in after residualizing
        variances(i, 1) = var(reg);
        variances(i, 2) = var(regressor);
        savefile = fullfile(savedir, subpath, strcat(sub, '_regressor_nuis_covs_dcm_removed.mat'));
        save(savefile, 'regressor');
    else 
        error('Must provide to_remove variable as nuis_covs, dcm, or both.')
    end
end
savefile = fullfile(savedir, subpath, 'all_subject_variances.mat');
save(savefile, 'variances');
end
