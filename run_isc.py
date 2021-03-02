import mvpa2.suite as mv
from scipy.stats import zscore as sciz
import sys
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

helperfiles = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP_old_2019_lukesIsUpdating/hyperalignment/helperfiles/'
chamats = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP_old_2019_lukesIsUpdating/hyperalignment/CHA_matrices/'
logdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP_old_2019_lukesIsUpdating/hyperalignment/log/'
scriptsdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP_old_2019_lukesIsUpdating/hyperalignment/scripts/'
basedir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP_old_2019_lukesIsUpdating/hyperalignment/'
mapdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP_old_2019_lukesIsUpdating/hyperalignment/transformation_matrices/'
resultsdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP_old_2019_lukesIsUpdating/hyperalignment/isc_results/'

nsubs = int(sys.argv[1])
radius = int(sys.argv[2])
cnx_tx = 489

load_file = os.path.join(mapdir, 'olp4cbp_mappers' + '_' + 'subs-' + str(nsubs) + '_'+ 'radius-' +  str(radius) + '.hdf5.gz')

# specify number of targets in connectome
print('Num Subs: ')
print(nsubs)
print('HA Radius: ')

if nsubs == 337:
	nfiles = glob.glob(os.path.join(chamats, 'ses_all', '*'))
elif nsubs == 202:
	nfiles = glob.glob(os.path.join(chamats, 'ses1_only', '*'))
else:
	nfiles = glob.glob(os.path.join(chamats, '*'))

mysubs = nfiles[0:nsubs]

# import connectomes into pymvpa dataset, zscore, then add chunks and voxel indices, append to list of datsets
print('importing anatomical subs')
dss = []
for sub in range(len(mysubs)):
    ds = mv.Dataset(np.load(mysubs[sub]))
    ds.fa['voxel_indices'] = range(ds.shape[1])
    #ds.sa['chunks'] = np.repeat(i,cnx_tx)
    mv.zscore(ds, chunks_attr=None)
    dss.append(ds)
print('anatomical subs loaded')

print('dss sizes')
print(len(dss))
print(dss[0].shape)

print(len(dss))
print(dss[0].shape)
print('loading hyperaligned mappers')
mappers = h5load(load_file)
print('loaded mappers. creating dss_aligned list')
dss_aligned = [mapper.forward(ds) for ds, mapper in zip(dss, mappers)]
print(len(mappers))
print(dss_aligned[0].shape)

print('loading ISC function')
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




sim_test = compute_average_similarity(dss)
print('done sim_test')
sim_aligned = compute_average_similarity(dss_aligned)
print('done sim_aligned')

# save sim test and aligned
toutdir = os.path.join(resultsdir, 'anatomical_isc' + '_' + 'subs-'+  str(nsubs) + '_'+'radius-' + str(radius) +  '.hdf5.gz')
h5save(toutdir, sim_test)

toutdir = os.path.join(resultsdir, 'cha_isc' + '_' + 'subs-' + str(nsubs) + '_' + 'radius' + str(radius) + '.hdf5.gz')
h5save(toutdir, sim_aligned)





