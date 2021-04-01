import glob
import os.path
import pandas as pd
import numpy as np

openpath = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/CHA_matrices/'
savepath = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/CHA_matrices/ses2_only'
myfiles = glob.glob(os.path.join(openpath,'*ses-2*'))

for f in myfiles:
    mysub = pd.read_csv(f, sep=',',header=None)
    npsub = mysub.to_numpy()
    fname1 = os.path.split(f)[1]
    fname = fname1[0:-4] + '.npy'
    ffull = os.path.join(savepath, fname)
    np.save(ffull, npsub, allow_pickle=True)
