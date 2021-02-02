repodir = '/projects/joas2631/Repositories/OLP4CBP';
outdir = '/pl/active/ics/data/projects/wagerlab/labdata/projects/OLP4CBP/sponpain_results';
savedir = fullfile(outdir, 'CHA_matrices');
​
​
%% find data files
Ss = filenames(fullfile(outdir, 'cleaned_full_data', '*mat'));
​
%% load atlas
atl = load_atlas('canlab2018_2mm')
​
​
%% for each scan, compute CHA matrix
% targets x voxels Pearson correlation
% 489 x 170804 GM voxels 
​
for i=1:length(Ss)
    i
    load(Ss{i}); % loads dat_denoised
    dat_denoised_rs = resample_space(dat_denoised, atl);
        
    % get parcel timeseries
    parcel_timeseries = apply_atlas(dat_denoised_rs, atl);
    
    % get voxels in the mask (the atlas)
    dat_masked = apply_mask(dat_denoised_rs, atl);
    
    % parcel by voxel corr
    mat = corr(parcel_timeseries, dat_masked.dat');
    
    % save to csv file
    [~, name] = fileparts(Ss{i})
    writematrix(mat, fullfile(savedir, [name '_CHA_matrix.csv']));

