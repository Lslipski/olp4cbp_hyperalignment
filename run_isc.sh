#!/bin/bash -l
#PBS  -m bea
#PBS -M luke.slipski.gr@dartmouth.edu
#PBS -N olp4cbp_isc
#PBS -l nodes=1:ppn=32
#PBS -l walltime=1:00:00
#PBS -o /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP_old_2019_lukesIsUpdating/hyperalignment/log/${PBS_JOBID}.o
#PBS -e /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP_old_2019_lukesIsUpdating/hyperalignment/log/${PBS_JOBID}.e

source /optnfs/common/miniconda3/etc/profile.d/conda.sh
module load python/anaconda2

conda activate comp_meth_env

python /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP_old_2019_lukesIsUpdating/hyperalignment/scripts/run_isc.py 337 5
