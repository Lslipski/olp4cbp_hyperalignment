addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/CanlabCore'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/Neuroimaging_Pattern_Masks'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/spm12'));

datadir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/data/bladderpain/raw';
savedir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/data/bladderpain/connectomes';
templatedir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/helper_files';
templatefile = 'bladderpain_templatefile.nii';

Ss = filenames(fullfile(datadir, 'sub*.mat'));
templatedat = fmri_data(fullfile(templatedir, templatefile)); % loads as dat_denoised
atl = resample_space(load_atlas('canlab2018_2mm'), templatedat);

for i = 1:length(Ss)
   load(Ss{i}); % loads as sponpain_cha_mat
   %templatedat.dat = sponpain_cha_mat;
   templatedat.dat = bladder_pain_ts;

   % get parcel timeseries
    parcel_timeseries = apply_atlas(templatedat, atl); % 1043 x 487
    
    % parcel by voxel corr
    mat = corr(parcel_timeseries, templatedat.dat');
   
    % save to .mat file
    [a, name] = fileparts(Ss{i});
    sub = name(1:13)
    savestr = fullfile(savedir, strcat(sub, '_bladderpain_raw_connectome.mat'));
    save(savestr, 'mat');
end
