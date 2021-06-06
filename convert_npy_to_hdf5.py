import mvpa2.suite as mv
from scipy.stats import zscore as sciz, pearsonr
import os.path, time
from glob import glob
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

datadir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/common_spaces/bladderpain/commonspace_subs-201_radius-10'

# get list of npy files to convert
myfiles = glob(os.path.join(datadir, '*.npy'))

# loop files, load as pymvpa dataset, save as hdf5.gz
for sub in myfiles:
    mysub = mv.Dataset(np.load(sub))
    savepath = os.path.join(datadir, os.path.split(sub)[1][0:-4] + '.hdf5.gz')
    h5save(savepath, mysub)