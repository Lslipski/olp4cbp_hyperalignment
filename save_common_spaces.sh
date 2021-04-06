#!/bin/bash -l
#PBS  -m bea
#PBS -M luke.slipski.gr@dartmouth.edu
#PBS -N olp4cbp_save_commonspace
#PBS -l nodes=1:ppn=24
#PBS -l walltime=7:00:00
#PBS -o /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/${PBS_JOBID}.o
#PBS -e /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/${PBS_JOBID}.e

source /optnfs/common/miniconda3/etc/profile.d/conda.sh
module load python/anaconda2

conda activate comp_meth_env

python /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/scripts/save_common_spaces.py
