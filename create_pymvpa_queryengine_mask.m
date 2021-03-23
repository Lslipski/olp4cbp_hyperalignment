% load sample subject nifti from Yoni's dataset 
mysubj = load('searchlight_sphere_test_sub.mat'); % dat dimensions [100105×1043 double]

% load atlas that was used to compute connectomes
atl = load_atlas('canlab2018_2mm'); % dat dimensions [352328×1 int32]

% load brainmask file
brainmask = fmri_data(which('brainmask.nii')); % dat dimensions [352328×1 single]

% first resample, then mask to get correct dimensions.
bm_rs_subjspace = resample_space(brainmask, mysubj.dat_denoised); % dat dimensions [100105×1 double]
bm_rs = resample_space(bm_rs_subjspace, atl); % dat dimensions [352328×1 double]
bm_masked = apply_mask(bm_rs, atl); % dat dimensions [170804×1 double]


% save properly sampled brainmask.nii
bm_masked.fullpath = strcat(pwd, '/newbrainmask.nii');
write(bm_masked);
