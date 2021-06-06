#!/bin/bash -l
#PBS -m bea
#PBS -M torwa.gr@dartmouth.edu
#PBS -N summarize_bladder_in_sponpain_iscs
#PBS -l nodes=1:ppn=24
#PBS -l walltime=48:00:00
#PBS -o /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/summarize_bladder_in_sponpain_iscs_${PBS_JOBID}.o
#PBS -e /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/summarize_bladder_in_sponpain_iscs_${PBS_JOBID}.e

module load python/anaconda2
source /optnfs/common/miniconda3/etc/profile.d/conda.sh
conda activate comp_meth_env

python /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/helper_scripts/summarize_bladder_in_sponpain_iscs.py 100 
