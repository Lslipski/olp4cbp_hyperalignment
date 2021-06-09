#utils.py
# Contains small functions and paths for the olp4cbp parcelwise Hyperalignment analysis
import os
import numpy as np

project_dir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment'
parcelwise_dir = os.path.join(project_dir, 'parcelwise')
pw_data = os.path.join(parcelwise_dir, 'data')
pw_helper_files = os.path.join(parcelwise_dir, 'helper_files')
pw_helper_scripts = os.path.join(parcelwise_dir, 'helper_scripts')
trans_matrices = os.path.join(parcelwise_dir, 'transformation_matrices')
spon_ts = os.path.join(parcelwise_dir, 'data', 'sponpain', 'cleaned')
spon_cnx = os.path.join(parcelwise_dir, 'data', 'sponpain', 'connectomes')
bladder_ts_raw = os.path.join(parcelwise_dir, 'data', 'bladderpain', 'raw')
bladder_ts_cleaned = os.path.join(parcelwise_dir, 'data', 'bladderpain', 'cleaned')
bladder_cnx = os.path.join(parcelwise_dir, 'data', 'bladderpain', 'connectomes') 
bladderpain_by_parcel = '/dartfs-hpc/scratch/f0040y1/low_back_pain/all_subs_parcelwise_raw_bladderpain_timeseries'
sponpain_by_parcel = '/dartfs-hpc/scratch/f0040y1/low_back_pain/all_subs_parcelwise_cleaned_sponpain_connectomes'
common_space_dir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/data/bladder_raw_in_spon'


def load_canlab_atlas():
	atl = load_mat_file_to_npy(os.path.join(pw_helper_files, 'resampled_canlab2018_2mm_mask.mat'))
	return atl



def prep_parcelwise_data(subject, parcel, datatype):
    from mvpa2.datasets import Dataset
    from mvpa2.mappers.zscore import zscore
    if datatype == 'sponpain':
        ds = Dataset(np.load(os.path.join(sponpain_by_parcel, subject + '_sponpain_connectome_parcel-' + str(parcel) + '.npy')))
        ds.fa['voxel_indices'] = range(ds.shape[1])
        zscore(ds, chunks_attr=None)
    elif datatype == 'bladderpain':
        ds = Dataset(np.load(os.path.join(bladderpain_by_parcel, subject + '_bladderpain-raw-ts_parcel-' + str(parcel) + '.npy')))
        ds.fa['voxel_indices'] = range(ds.shape[1])
        zscore(ds, chunks_attr=None)
    else:
        print('Must specify datatyp as either sponpain or bladderpain')
    return ds



def load_subj_pain_data(subj_id, paintype, datatype, tstype='cleaned'):
        import glob
	import scipy.io as sio
        if paintype == 'sponpain':
                if datatype == 'ts':
                        ds = sio.loadmat(glob.glob(os.path.join(spon_ts, subj_id + '*'))[0])['sponpain_cha_mat']
			ds = np.transpose(ds)
                elif datatype == 'cnx':
                        ds = sio.loadmat(glob.glob(os.path.join(spon_cnx, subj_id + '*'))[0])['mat']
                else:
                        print('Must specify datatype as either ts for time series or cnx for connectomes')
        elif paintype == 'bladderpain':
                if datatype == 'ts':
                        if tstype == 'cleaned':
                                ds = sio.loadmat(glob.glob(os.path.join(bladder_ts_cleaned, subj_id + '*'))[0])['rbrain']
                        elif tstype == 'raw':
                                ds = sio.loadmat(glob.glob(os.path.join(bladder_ts_raw, subj_id + '*'))[0])['bladder_pain_ts']
				ds = np.transpose(ds)
                        else:
                                print('Must specify tstype as either cleaned or raw')
                elif datatype == 'cnx':
                        ds = sio.loadmat(glob.glob(os.path.join(bladder_cnx, subj_id + '*'))[0])['mat']
                else:
                        print('Must specify datatype as either ts for time series or cnx for connectomes')
        else:
                print('Must specify paintype as either sponpain or bladderpain')
        return ds


def load_mat_file_to_npy(filepath, matkey='thisone'): #default matkey is for atlas object
	import scipy.io as sio
	ds = sio.loadmat(filepath)
	ds = ds[matkey]
	return ds
