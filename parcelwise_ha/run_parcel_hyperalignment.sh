#!/bin/bash -l
#PBS  -m bea
#PBS -M luke.slipski.gr@dartmouth.edu
#PBS -N parcelwise_hyperalignment
#PBS -l nodes=1:ppn=3
#PBS -l walltime=3:00:00
#PBS -o /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/parcel_HA_${PBS_JOBID}.o
#PBS -e /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/parcel_HA_${PBS_JOBID}.e
#PBS -t 1-3
source /optnfs/common/miniconda3/etc/profile.d/conda.sh
module load python/anaconda2


conda activate comp_meth_env


parcel=$((${PBS_ARRAYID}-1))
echo "python /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/scripts/parcelwise_ha/parcel_hyperalignment.py  ${parcel}"
python /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/scripts/parcelwise_ha/parcel_hyperalignment.py $parcel

