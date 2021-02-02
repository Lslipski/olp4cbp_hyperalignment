#!/bin/bash -l
#PBS -m bea
#PBS -M torwa.gr@dartmouth.edu
#PBS -N subj24_all
#PBS -l nodes=1:ppn=2
#PBS -l walltime=24:00:00
#PBS -o /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP_old_2019_lukesIsUpdating/hyperalignment/log/${PBS_JOBID}.o
#PBS -e /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP_old_2019_lukesIsUpdating/hyperalignment/log/${PBS_JOBID}.e

module load python/anaconda2
source /optnfs/common/miniconda3/etc/profile.d/conda.sh
conda activate mvpa

python /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/data/OLP4CBP_old_2019_lukesIsUpdating/hyperalignment/scripts/convert_csv_to_nparray.py
