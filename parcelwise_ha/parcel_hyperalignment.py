# parcel_hyperalignment.py
# runs hyperalignment on each parcel individually, saves common spaces and mappers
import utils
import numpy as np
import os, sys, glob, time
import multiprocessing as mp
from mvpa2.mappers.zscore import zscore
from mvpa2.algorithms.hyperalignment import Hyperalignment
from mvpa2.datasets import Dataset
from mvpa2.base import debug
from datetime import timedelta

NPROC = 24
os.environ['TMPDIR']='/dartfs-hpc/scratch/f0040y1'
os.environ['TEMP']='/dartfs-hpc/scratch/f0040y1'
os.environ['TMP']='/dartfs-hpc/scratch/f0040y1'
TEMPORARY_OUTDIR='/dartfs-hpc/scratch/f0040y1'



def get_subject_list(nsubs=None):
    # load files 
    in_train_files = glob.glob(os.path.join(utils.sponpain_by_parcel, '*'))
    in_train_subs = np.unique([os.path.basename(x)[0:13] for x in in_train_files])

    in_test_files = glob.glob(os.path.join(utils.bladderpain_by_parcel, '*'))
    in_test_subs = np.unique([os.path.basename(x)[0:13] for x in in_test_files])

    bothsubs = [sub for sub in in_train_subs if sub in in_test_subs]
    
    if nsubs is not None:
        bothsubs = bothsubs[:nsubs]
    return bothsubs


# save and apply mappers
def apply_mappers((data_fn, mapper_fn, subject, mapper, parcel_num)):
    data = utils.prep_parcelwise_data(subject, parcel_num, 'bladderpain')
    aligned = zscore((np.asmatrix(data)*mapper._proj).A, chunks_attr=None)
    np.save(data_fn, aligned)
    np.savez(mapper_fn, mapper)


if __name__ == '__main__':
    # perform parcelwise hyperalignment for the parcel number passed in
    parcel_num = int(sys.argv[1])

    # get list of subjects to hyperalign
    sub_list = get_subject_list(None)
    
    aligned_dirname = os.path.join(utils.common_space_dir, 'parcel_{n:03d}'.format(n=parcel_num))
    mapper_dirname = os.path.join(utils.trans_matrices, 'parcel_{n:03d}'.format(n=parcel_num))

    for d in [aligned_dirname, mapper_dirname]:
        if not os.path.exists(d):
            os.makedirs(d)


    train_dss = [utils.prep_parcelwise_data(sub, parcel_num, 'sponpain') for sub in sub_list]
    print('-------- size of training data sets {A} -------------'.format(A=train_dss[0].shape))
    print('-------- beginning hyperalignment parcel {A} --------'.format(A=parcel_num))

    # train hyperalignment model on all subject's sponpain data for this parcel
    print('-------- length of train subjects={A} '.format(A=str(len(train_dss))))
    ha = Hyperalignment(nproc=NPROC, joblib_backend='multiprocessing')
    debug.active += ['HPAL']
    t0 = time.time()
    ha.train(train_dss)
    mappers = ha(train_dss)
    t1 = time.time()
    print('-------- done training hyperalignment at {B} --------'.format(B=str(timedelta(seconds=t1-t0))))
    del train_dss

    pool = mp.Pool(NPROC)
    data_fns = [os.path.join(aligned_dirname,'{s}_aligned_dtseries.npy'.format(s=s)) for s in sub_list]
    mapper_fns = [os.path.join(mapper_dirname,'{s}_trained_mapper.npz'.format(s=s)) for s in sub_list]
    iterable = zip(data_fns, mapper_fns, sub_list, mappers, np.repeat(parcel_num, len(mappers)))
    pool.map(apply_mappers, iterable)
    t2=time.time()
    print('-------- done aligning & saving test data at {B} --------'.format(B=str(timedelta(seconds=t2-t1))))








