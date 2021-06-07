import mvpa2.suite as mv
import sys
from scipy.stats import zscore as sciz
import scipy.io as sio
import os.path, time
import glob
from scipy.io import loadmat 
import numpy as np
import pandas as pd
import nibabel as nb
import h5py
from mvpa2.datasets.base import Dataset
from mvpa2.misc.surfing.queryengine import SurfaceQueryEngine
from mvpa2.support.nibabel.surf import read as read_surface
from mvpa2.datasets.mri import fmri_dataset
from mvpa2.misc.neighborhood import IndexQueryEngine, Sphere
from mvpa2.datasets.base import mask_mapper
import mvpa2.misc.surfing.volume_mask_dict as volmask
from mvpa2.algorithms.hyperalignment import Hyperalignment
from mvpa2.mappers.zscore import zscore
from mvpa2.base.hdf5 import h5save, h5load
from scipy.spatial.distance import pdist, cdist
import pickle
from datetime import date

helperscripts = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/helper_scripts'
helperfiles = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/helper_files'
chamats = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/data/sponpain/cha_matrices'
logdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/'
savedir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/transformation_matrices'
bladdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/data/bladderpain/raw'

def compute_average_similarity(dss, metric='correlation'):
    """
    Returns
    =======
    sim : ndarray
        A 1-D array with n_features elements, each element is the average
        pairwise correlation similarity on the corresponding feature.
    """
    n_features = dss[0].shape[1]
    sim = np.zeros((n_features, ))
    for i in range(n_features):
        data = np.array([ds.samples[:, i] for ds in dss])
        dist = pdist(data, metric)
        sim[i] = 1 - dist.mean()
    return sim

# load atlas label descriptions
x = sio.loadmat(os.path.join(helperfiles,'label_descriptions.mat'))
label_descriptions = [str(lab[0][0]) for lab in x['label_descriptions']]
# load atlas labels
x = sio.loadmat(os.path.join(helperfiles,'labels.mat'))
labels = [str(lab[0]) for lab in x['labels'][0]]
# load atlas indices
x = sio.loadmat(os.path.join(helperfiles,'parcel_indices.mat'))
indices = np.empty((len(x['myindices']), len(x['myindices'][0])))
for row in range(len(x['myindices'])):
    indices[row,:] = x['myindices'][row]
    
#parameters
nsubs = int(sys.argv[1])
df_results = pd.DataFrame(np.nan, index=range(len(indices)), columns=['Parcel_desc','Parcel_label', 'Voxels_in_parcel',
                                                                     'Train_AA_ISC', 'Train_HA_ISC', 'Test_AA_ISC', 
                                                                     'Test_HA_ISC'])


# Training HYPERALIGN ON HALF OF BLADDER, TESTING ON OTHER HALF
# get relevant subject files
nfiles = glob.glob(os.path.join(chamats, '*sub*mat'))
print('Loading participant data from: {0}'.format(chamats))
mysubs = nfiles[0:nsubs]
print('Number of Subs going into HA: {0}'.format(str(len(mysubs))))


# TRAINING ON Sponpain Connectomes, Testing on Bladder
# Load all spon  mat files
mats = []
for sub in range(len(mysubs)):
    f = os.path.join(mysubs[sub])
    mat = np.array(sio.loadmat(f)['mat'])
    mats.append(mat)
print('Loaded TRAINING .mat files.')
    
# LOAD TESTING DATA (BLADDER)
sponfiles  = glob.glob(os.path.join(chamats, '*sub*mat'))
sponsubs = [os.path.basename(x)[0:13] for x in sponfiles]
testnfiles = [os.path.join(bladdir, sub + '_bladderpain_space-100105_raw_timeseries.mat') for sub in sponsubs]
print('Loading participant data from: {0}'.format(bladdir))
testmysubs = testnfiles[0:nsubs]
print('Number of Subs in Testing Data: {0}'.format(str(len(testmysubs))))

# Load all bladder mat files
testmats = []
for sub in range(len(mysubs)):
    f = os.path.join(testmysubs[sub])
    mat = np.transpose(sio.loadmat(f)['bladder_pain_ts'])
    testmats.append(mat)
print('Loaded TESTING .mat files.')


            
for parcel in range(len(indices)):
    PARCEL_NUMBER =  parcel #int(sys.argv[2])
    print('Number of Subjects: {0}'.format(nsubs))
    print('Parcel Number: {0}'.format(PARCEL_NUMBER))
    print('Parcel Label: {0}'.format(labels[PARCEL_NUMBER]))
    print('Parcel Description: {0}'.format(label_descriptions[PARCEL_NUMBER]))
    print('Voxels in Parcel: {0}'.format(sum(indices[PARCEL_NUMBER])))
    df_results.loc[parcel, 'Parcel_desc'] = label_descriptions[PARCEL_NUMBER]
    df_results.loc[parcel, 'Parcel_label'] = labels[PARCEL_NUMBER]
    df_results.loc[parcel, 'Voxels_in_parcel'] = sum(indices[PARCEL_NUMBER])

    myvoxels = np.nonzero(indices[PARCEL_NUMBER])
    dss = []
    for sub in range(len(mats)):
        ds = mats[sub][:,myvoxels[0]]
        ds = mv.Dataset(ds)
        ds.fa['voxel_indices'] = range(ds.shape[1])
        mv.zscore(ds, chunks_attr=None)
        dss.append(ds)


    print('Size of Training data sets: {0}'.format(dss[0].shape))
    print('Beginning Hyperalignment.')



    # create hyperalignment instance
    hyper = Hyperalignment(
        nproc=1, 
    )
    hyper.train(dss)

    # get mappers to common space created by hyper.train (2x procrustes iteration)
    mappers = hyper(dss)

    # apply mappers back onto training data
    ds_hyper = [h.forward(sd) for h, sd in zip(mappers, dss)]

    train_aa_isc = compute_average_similarity(dss)
    train_ha_isc = compute_average_similarity(ds_hyper)
    
    df_results.loc[parcel, 'Train_AA_ISC'] = np.mean(train_aa_isc)
    df_results.loc[parcel, 'Train_HA_ISC'] = np.mean(train_ha_isc)


    # create test dss
    test_dss = []

    for sub in range(len(testmats)):
        ds = testmats[sub][15:,myvoxels[0]]
        ds = mv.Dataset(ds)
        ds.fa['voxel_indices'] = range(ds.shape[1])
        mv.zscore(ds, chunks_attr=None)
        test_dss.append(ds)
    
    print('Size of Test data sets: {0}'.format(test_dss[0].shape))

    ds_hyper = [h.forward(sd) for h, sd in zip(mappers, test_dss)]
    
    test_aa_isc = compute_average_similarity(test_dss)
    test_ha_isc = compute_average_similarity(ds_hyper)
    
    df_results.loc[parcel, 'Test_AA_ISC'] = np.mean(test_aa_isc)
    df_results.loc[parcel, 'Test_HA_ISC'] = np.mean(test_ha_isc)


df_results['Train_HA_m_AA'] = df_results['Train_HA_ISC'] - df_results['Train_AA_ISC']
df_results['Test_HA_m_AA'] = df_results['Test_HA_ISC'] - df_results['Test_AA_ISC']
df_results.to_csv(os.path.join(savedir, 'bladder_in_sponpain_parcelwise_iscs_subs-' + str(nsubs) + '.csv'))
