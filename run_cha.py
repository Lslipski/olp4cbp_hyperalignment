import mvpa2.suite as mv
import sys
from scipy.stats import zscore as sciz
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


helperfiles = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP_old_2019_lukesIsUpdating/hyperalignment/helperfiles/'
chamats = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP_old_2019_lukesIsUpdating/hyperalignment/CHA_matrices/ses1_only/'
logdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP_old_2019_lukesIsUpdating/hyperalignment/log/'
scriptsdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP_old_2019_lukesIsUpdating/hyperalignment/scripts/'
basedir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP_old_2019_lukesIsUpdating/hyperalignment/'

#parameters
nsubs = int(sys.argv[1])
print(nsubs)

# constants 
N_BLOCKS=128
HYPERALIGNMENT_RADIUS=15
cnx_tx = 489
toutdir = os.path.join(basedir, 'transformation_matrices', 'olp4cbp_mappers' +'_' + 'subs-' + str(nsubs) + '_'+ 'radius-' +  str(HYPERALIGNMENT_RADIUS) + '.hdf5.gz')
print(toutdir)

# load nifti as a pymvpa dataset and then use that as ref_ds in the queryengine definition
# mask with data in brainmask so only 170k (size of connectomes) voxels are included
ref_ds = fmri_dataset(os.path.join(helperfiles,'brainmask.nii'), mask=os.path.join(helperfiles,'brainmask.nii'))
print('Size of brain mask:')
print(str(len(ref_ds.fa.voxel_indices)))

# set searchlight sphere radius
sl_radius = HYPERALIGNMENT_RADIUS

#create query engine
qe = IndexQueryEngine(voxel_indices=Sphere(sl_radius))
qe.train(ref_ds)

# load all subject 
nfiles = glob.glob(os.path.join(chamats, '*ses-*'))
print('Loading participant data from: ')
print(glob.glob(os.path.join(chamats,'ses_all')))
mysubs = nfiles[0:nsubs]

# import connectomes into pymvpa dataset, zscore, then add chunks and voxel indices, append to list of datsets
dss = []
for sub in range(len(mysubs)):
    ds = mv.Dataset(np.load(mysubs[sub]))
    ds.fa['voxel_indices'] = range(ds.shape[1])
    #ds.sa['chunks'] = np.repeat(i,cnx_tx)
    mv.zscore(ds, chunks_attr=None)
    dss.append(ds)
    
    
print('Number of data sets in dss: ')
print(len(dss))
print('Size of data sets: ')
print(dss[0].shape)
    
# create SL hyperalignment instance
hyper = SearchlightHyperalignment(
    queryengine=qe,
    compute_recon=False, # We don't need to project back from common space to subject space
    nproc=1, 
    nblocks=N_BLOCKS,
    dtype ='float64'
)

# start timer
t0 = time.time()

# hyperalign dss
mappers = hyper(dss)

#save mappers
try:
    h5save(toutdir, mappers)
    print('saved hdf5 mappers')
except: 
    print('could not save hdf5 mappers')

elapsed = time.time()-t0
print('-------- time elapsed: {elapsed} --------'.format(elapsed=(time.strftime("%H:%M:%S",time.gmtime(elapsed)))))
print('saving at location: {0}'.format(toutdir))
    
    
    
    
    
    
    
    
    
    
