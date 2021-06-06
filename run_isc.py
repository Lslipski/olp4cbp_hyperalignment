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

helperfiles = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/helperfiles/'
chamats = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/CHA_matrices/'
common_space_dir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/common_spaces/commonspace_subs-202_radius-10/'
logdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/'
scriptsdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/scripts/'
basedir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/'
mapdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/transformation_matrices/'
resultsdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/isc_results/'
spondir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/CHA_matrices/sponpain/ses1_only'
bladdir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/data/cleaned_bladder'

nsubs = int(sys.argv[1])
radius = int(sys.argv[2])
space = str(sys.argv[3])
cnx_tx = 489

# specify number of targets in connectome
print('Space: ')
print(space)
print('Num Subs: ')
print(nsubs)
print('HA Radius: ')
print(radius)

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
nfiles = []
if space == 'AA':
    for sub in p_list:
        nfiles.append(os.path.join(chamats, 'bladderpain', 'ses1_only', sub + '_bladderpain_cleaned_AA_matrix.npy'))
elif space == 'HA':
    for sub in p_list:
        nfiles.append(os.path.join(chamats, 'bladderpain', 'ses1_only', sub + '_bladderpain_cleaned_CHA_matrix.npy'))
else:
     print('Error: Must specify space as either AA or HA')
        
mysubs = nfiles[0:nsubs]

# import connectomes into pymvpa dataset, zscore, then add chunks and voxel indices, append to list of datsets
print('Importing data into pymvpa.')
dss = []
for sub in range(len(mysubs)):
    ds = mv.Dataset(np.load(mysubs[sub]))
    ds.fa['voxel_indices'] = range(ds.shape[1])
    #ds.sa['chunks'] = np.repeat(i,cnx_tx)
    mv.zscore(ds, chunks_attr=None)
    dss.append(ds)
print('All subject data loaded.')

print('dss sizes')
print(len(dss))
print(dss[0].shape)


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


# save sim test and aligned
if space == 'AA':
	toutdir = os.path.join(resultsdir, 'bladderpain', 'anatomical_isc' + '_' + 'subs-'+  str(nsubs) + '_'+'radius-' + str(radius) +  '.hdf5.gz')
	h5save(toutdir, sim_test)
elif space =='HA':
	toutdir = os.path.join(resultsdir, 'bladderpain', 'cha_isc' + '_' + 'subs-' + str(nsubs) + '_' + 'radius-' + str(radius) + '.hdf5.gz')
	h5save(toutdir, sim_test)
else:
	print('Error upon saving: Must Specify space as either AA or HA')





