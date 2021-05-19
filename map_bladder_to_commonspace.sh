#!/bin/bash -l
#PBS  -m bea
#PBS -M luke.slipski.gr@dartmouth.edu
#PBS -N map_bladder_to_commonspace
#PBS -l nodes=1:ppn=24
#PBS -l walltime=50:00:00
#PBS -o /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/map_bladder_to_commonspace${PBS_JOBID}.o
#PBS -e /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/map_bladder_to_commonspace${PBS_JOBID}.e

source /optnfs/common/miniconda3/etc/profile.d/conda.sh
module load python/anaconda2


conda activate comp_meth_env

python /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/scripts/map_bladder_to_commonspace.py
