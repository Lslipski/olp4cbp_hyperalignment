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

helperfiles = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/helperfiles/'
chamats = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/CHA_matrices/'
logdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/'
scriptsdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/scripts/'
basedir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/'
mapdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/transformation_matrices/'
spondir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/CHA_matrices/sponpain/ses1_only'
bladdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/data/cleaned_bladder'
savedir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/common_spaces/bladderpain/commonspace_subs-201_radius-10/'

# Load Transformation Matrices produces by CHA
mappers = h5load(os.path.join(mapdir,'olp4cbp_mappers_subs-202_radius-10.hdf5.gz'))
print('Mappers Loaded.')

# this is the order that files are loaded into hyperalignment
sponfiles = [os.path.basename(x) for x in glob(os.path.join(spondir, '*ses-*'))]
sponsubs = [z[0:13] for z in sponfiles]

# these are the bladder pain files
bladfiles = [os.path.basename(x) for x in glob(os.path.join(bladdir, 'sub*ses-1*.nii'))]
bladsubs = [z[0:13] for z in bladfiles]

# get a list of indices from the sponpain list (which corresponds to the order of CHA mappers) that does not include
# participants who aren't in both lists. mapper_indices will be used to load mappers, and p_list will be used to load 
# bladder data
mapper_indices = []
p_list = []
for sub in sponsubs:
    if sub in bladsubs and sub in sponsubs:
        mapper_indices.append(sponsubs.index(sub))
        p_list.append(sub)
    else:
        print('Not in both lists: ')
        print(sub)
        

# For each subject who has both sponpain and bladderpain data, load their bladderpain data and their CHA transformation matrix
# Apply the t-matrix and save the subject's common space bladderpain data
for i, sub in enumerate(p_list):
    this_blad = os.path.join(bladdir, sub + '_ses-1_task-bladderpain_space-canlab2018-2mm_desc-preproc-cleaned.nii')
    if os.path.isfile(this_blad):
        ds = fmri_dataset(this_blad, mask=os.path.join(helperfiles,'newbrainmask.nii'))
        ds_mapped = mappers[mapper_indices[i]].forward(ds)
        np.save(savedir + sub + '_commonspace-bladderinspon_subs-202_radius-10', ds_mapped)
    else:
        print('File does not exist: ')
        print(this_blad)
        break
        
        
        
        
        
        
        
        
        
        
        
        
        
