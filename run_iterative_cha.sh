#!/bin/bash -l
#PBS  -m bea
#PBS -M luke.slipski.gr@dartmouth.edu
#PBS -N olp4cbp_hyperalign
#PBS -l nodes=1:ppn=36
#PBS -l walltime=350:00:00
#PBS -o /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/iterative_cha_${PBS_JOBID}.o
#PBS -e /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/iterative_cha_${PBS_JOBID}.e

source /optnfs/common/miniconda3/etc/profile.d/conda.sh
module load python/anaconda2


conda activate comp_meth_env

python /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/scripts/run_iterative_cha.py 202 10
