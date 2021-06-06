addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/CanlabCore'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/Neuroimaging_Pattern_Masks'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/spm12'));

% load sample participant with correct voxel size to sample atlas to
template = fmri_data('/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP/Imaging/preprocessed/fmriprep/sub-M80344098/ses-1/func/sub-M80344098_ses-1_task-bladder_space-MNI152NLin2009cAsym_desc-preproc_bold.nii');
atl = load_atlas('canlab2018_2mm');
myatl = resample_space(atl, template);

label_descriptions = myatl.label_descriptions;
labels = myatl.labels;
myindices = zeros(size(myatl.label_descriptions,1), size(myatl.dat,1));
for i = 1:size(myatl.label_descriptions,1)
    myindices(i,:) = myatl.dat == i;
end

save('label_descriptions.mat', 'label_descriptions');
save('labels.mat', 'labels');
save('parcel_indices.mat', 'myindices');
