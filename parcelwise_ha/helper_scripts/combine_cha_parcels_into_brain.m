% this script loads the CHA data for each subject parcel by parcel
% and combines the data into a single matrix of brain data
% final size is 1613 x 100105

%paths
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/OLP4CBP'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/CanlabCore'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/Neuroimaging_Pattern_Masks'));
addpath(genpath('/dartfs-hpc/rc/home/1/f0040y1/repositories/spm12'));

%vars
myindices = load('/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/helper_files/parcel_indices.mat');
[bladderpain, sponpain, bothpain] = get_T1_participant_lists();
thisdat = zeros(1613, 100105);
CHA_clean = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/data/bladder_cleaned_in_spon';
save_CHA = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/common_spaces/subs-201_parcels-487';

for sub = 1:size(bothpain,1) % for each subject
        thissub = bothpain{sub};
        sprintf(['Starting: ', thissub])
        common_space = zeros(1613, 100105);
        for i = 1:size(myindices.myindices,1) % for each parcel, CHA is saved in parcelwise folders
            %load this parcel for this subject
            folder_num = i-1;
            hfile = fullfile(CHA_clean, strcat('parcel_', sprintf('%03d',folder_num)), strcat(thissub, '_aligned_cleaned_bladder_ts_noZ.hdf5'));
            hinfo = h5info(hfile);
            hdat = h5read(hfile, strcat(hinfo.Name, hinfo.Datasets.Name))';
            if (size(hdat,1) == 1609 && i == 1) % some subs only have 1609 time points
                common_space = zeros(1609, 100105);
            end
            % add to correct location in thisdat
            this_parcel_indices = find(myindices.myindices(i, :) ~= 0);
            common_space(:, this_parcel_indices) = hdat;
        end

        savefile = fullfile(save_CHA, strcat(thissub, '_commonspace_noZ_subs-201_parcels-487.mat'));
        save(savefile, 'common_space');
        sprintf(['Saved: ', savefile])

end

