%% Save all Ses-1 Spontaneous and Bladder data as .mat matrices
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/CanlabCore'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/Neuroimaging_Pattern_Masks'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/spm12'));

savedir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/data/sponpain/CHA_matrices';
spondir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/sponpain_results/cleaned_full_data_aCompCor_lpf';

Ss = filenames(fullfile(spondir, '*ses-1*'));

for i = 1:size(Ss,1)
    load(Ss{i});
    sponpain_cha_mat = dat_denoised.dat;
    sub = dat_denoised.image_names(:,1:13)
    save_str = fullfile(savedir, strcat(sub, '_sponpain_space-100105_CHA_matrix.mat'));
    save(save_str, 'sponpain_cha_mat'); 
end
