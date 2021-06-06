addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/CanlabCore'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/Neuroimaging_Pattern_Masks'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/spm12'));

datadir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/data/sponpain/cleaned';
savedir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/data/sponpain/cha_matrices';
templatedir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/sponpain_results/cleaned_full_data_aCompCor_lpf';

Ss = filenames(fullfile(datadir, 'sub*.mat'));
load(fullfile(templatedir, 'sub-M80399971_ses-2_task-sponpain_space-MNI152NLin2009cAsym_desc-preproc-cleaned_bold.mat')); % loads as dat_denoised
atl = resample_space(load_atlas('canlab2018_2mm'), dat_denoised);

for i = 1:length(Ss)
   load(Ss{i}); % loads as sponpain_cha_mat
   dat_denoised.dat = sponpain_cha_mat;
   
   % get parcel timeseries
    parcel_timeseries = apply_atlas(dat_denoised, atl); % 1043 x 487
    
    % parcel by voxel corr
    mat = corr(parcel_timeseries, dat_denoised.dat');
   
    % save to .mat file
    [a, name] = fileparts(Ss{i});
    sub = name(1:13)
    savestr = fullfile(savedir, strcat(sub, '_sponpain_cleaned_cha_matrix.mat'));
    save(savestr, 'mat');
end
