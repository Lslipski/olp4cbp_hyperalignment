%load sample subject nifti from Yoni's dataset 
mysubj = load('searchlight_sphere_test_sub.mat'); % dat dimensions [100105×1043 double]

% load atlas that was used to compute connectomes
atl = load_atlas('canlab2018_2mm'); % dat dimensions [352328×1 int32]

%% this was an issue before canlabcore updates. It is now skipped.
% load brainmask file
%brainmask = fmri_data('/Users/lukie/Documents/canlab/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/brainmask.nii'); % dat dimensions [352328×1 single]

% first resample, then mask to get correct dimensions.
% bm_rs_subjspace = resample_space(brainmask, mysubj.dat_denoised); % dat dimensions [100105×1 double]
% bm_rs = resample_space(bm_rs_subjspace, atl); % dat dimensions [352328×1 double]
% bm_masked = apply_mask(bm_rs, atl); % dat dimensions [170804×1 double]

%% resample then mask
mysubj_rs = resample_space(mysubj.dat_denoised, atl);
mysubj_rs_masked = apply_mask(mysubj_rs, atl);

% save properly sampled brainmask.nii
mysubj_rs_masked.fullpath = strcat(pwd, '/newbrainmask.nii');
write(mysubj_rs_masked);
