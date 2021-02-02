import glob
import os.path
import pandas as pd
import numpy as np

openpath = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP_old_2019_lukesIsUpdating/hyperalignment/CHA_matrices'
savepath = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP_old_2019_lukesIsUpdating/hyperalignment/CHA_matrices/ndarrays'
myfiles = glob.glob(os.path.join(openpath,'*ses-1*'))

for f in myfiles:
    mysub = pd.read_csv(f, sep=',',header=None)
    npsub = mysub.to_numpy()
    fname1 = os.path.split(f)[1]
    fname = fname1[0:-4] + '.npy'
    ffull = os.path.join(savepath, fname)
    np.save(ffull, npsub, allow_pickle=True)
