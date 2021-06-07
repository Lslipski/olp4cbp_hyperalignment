addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/CanlabCore'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/Neuroimaging_Pattern_Masks'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/spm12'));

datadir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/data/cleaned_bladder';
savedir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/analysis/bladderpain/first_level/AA';
maskimagename = '/dartfs-hpc/rc/home/1/f0040y1/repositories/Neuroimaging_Pattern_Masks/Atlases_and_parcellations/2018_Wager_combined_atlas/CANlab_2018_combined_atlas_2mm.nii';
atl = load_atlas('canlab2018_2mm');

regs = filenames(fullfile(datadir,'*.mat'));
brains = filenames(fullfile(datadir,'*.nii'));
brain_reg_var = zeros(length(regs), 2);
for i = 1:length(regs)
   thisbrain = apply_mask(fmri_data(brains(i), maskimagename), atl);
   thisreg = load(regs{i});
   brain_reg_var(i, 1) = var(thisbrain.dat(:));
   brain_reg_var(i, 2) = var(thisreg.rpain);
end

savestr = fullfile(savedir, 'all_subs_brain_regs_var.mat');
save(savestr, 'brain_reg_var');
