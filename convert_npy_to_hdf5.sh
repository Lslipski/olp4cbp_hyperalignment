#!/bin/bash -l
#PBS -m bea
#PBS -M luke.slipski.gr@dartmouth.edu
#PBS -N convert_npy_to_hdf5
#PBS -l nodes=1:ppn=12
#PBS -l walltime=48:00:00
#PBS -o /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/convert_npy_to_hdf5${PBS_JOBID}.o
#PBS -e /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/convert_npy_to_hdf5${PBS_JOBID}.e

module load python/anaconda2
source /optnfs/common/miniconda3/etc/profile.d/conda.sh
conda activate comp_meth_env

python /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/scripts/convert_npy_to_hdf5.py
