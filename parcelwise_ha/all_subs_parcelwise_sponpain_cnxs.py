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
savedir = '/dartfs-hpc/scratch/f0040y1/low_back_pain/all_subs_parcelwise_cleaned_sponpain_connectomes'
cnxs = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/data/sponpain/connectomes'

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

# Get connectome file list
mysubs = glob.glob(os.path.join(cnxs, '*sub*mat'))
print('Loading participant data from: {0}'.format(cnxs))
print('Number of Subs going into HA: {0}'.format(str(len(mysubs))))


for sub in range(len(mysubs)):
    f = mysubs[sub]
    thissub = os.path.basename(f)
    print(thissub)
    mat = sio.loadmat(f)['mat']
    
    for parcel in range(len(indices)):
        PARCEL_NUMBER =  parcel #int(sys.argv[2]	)
        print('Parcel Number: {0}'.format(PARCEL_NUMBER))
        print('Parcel Label: {0}'.format(labels[PARCEL_NUMBER]))
        print('Parcel Description: {0}'.format(label_descriptions[PARCEL_NUMBER]))
        print('Voxels in Parcel: {0}'.format(sum(indices[PARCEL_NUMBER])))

        myvoxels = np.nonzero(indices[PARCEL_NUMBER])
        ds = mat[:,myvoxels[0]]
        savestr = os.path.join(savedir, thissub[0:13] + '_sponpain_connectome_parcel-' + str(PARCEL_NUMBER) + '.npy')
	np.save(savestr, ds)






















