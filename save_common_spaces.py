import mvpa2.suite as mv
from scipy.stats import zscore as sciz, pearsonr
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
from mvpa2.algorithms.searchlight_hyperalignment import SearchlightHyperalignment
from mvpa2.mappers.zscore import zscore
from mvpa2.base.hdf5 import h5save, h5load
from scipy.spatial.distance import pdist, cdist
import matplotlib.pyplot as plt


helperfiles = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/helperfiles/'
chamats = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/CHA_matrices/'
logdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/'
scriptsdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/scripts/'
basedir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/'
mapdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/transformation_matrices/'
resultsdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/common_spaces/commonspace_subs-202_radius-5/'
nsubs = 202
cnx_tx = 489

# get original file names
nfiles = glob.glob(os.path.join(chamats, 'ses1_only', '*'))
mysubs = nfiles[0:nsubs]

# load transformation matrices
mappers = h5load(os.path.join(mapdir,'olp4cbp_mappers_subs-202_radius-5.hdf5.gz'))


# loop through subjects, apply transformation matrix and save
for sub in range(len(mysubs)):
    sub_ds = mv.Dataset(np.load(mysubs[sub]))
    dss_aligned = mappers[sub].forward(sub_ds)
    np.save(resultsdir+'commonspace_subs-202_radius-20_'+os.path.split(mysubs[sub])[1], dss_aligned)
    print(sub)
    print('commonspace_subs-202_radius-20_'+os.path.split(mysubs[sub])[1])




