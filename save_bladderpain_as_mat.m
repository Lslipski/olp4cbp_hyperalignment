addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/CanlabCore'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/Neuroimaging_Pattern_Masks'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/spm12'));

savedir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/data/bladderpain/raw';
spondir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/sponpain_results/cleaned_full_data_aCompCor_lpf';
path_to_repos = '/dartfs-hpc/rc/home/1/f0040y1/repositories/'

load(fullfile(path_to_repos, 'OLP4CBP', 'data','subject_metadata.mat'))
mytabl = tabl(tabl.time==1, :); % maybe also only use patients? is_patient==1. I can't remember what we decided


% load preproc bladder data, at time 1
bladfiles = {};
for i = 1:height(mytabl)
    preprocdata_basedir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP/Imaging/preprocessed/fmriprep';
    fname = filenames(fullfile(preprocdata_basedir, ['sub-' mytabl.URSI(i,:)], 'ses-1', 'func', '*task-bladder_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'));
    if size(fname,1) == 0
        fname = filenames(fullfile(preprocdata_basedir, ['sub-' mytabl.URSI(i,:)], 'ses-1', 'func', '*task-bladder_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'));
    end
    if size(fname,1) == 0 % if brain data does not exist, skip participant
        disp('No Brain Data. Skipping Participant: ');
        mytabl.id(i);
        mytabl.URSI(i, :);
        continue
    end
    bladfiles{end + 1} = fname;
end

for i = 1:size(bladfiles,2)
    dat_denoised = fmri_data(bladfiles{i}{1});
    bladder_pain_ts = dat_denoised.dat;
    sub = dat_denoised.image_names(:,1:13)
    save_str = fullfile(savedir, strcat(sub, '_bladderpain_space-100105_raw_timeseries.mat'));
    save(save_str, 'bladder_pain_ts'); 
end
