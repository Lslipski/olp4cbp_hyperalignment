#!/bin/bash -l
#PBS  -m bea
#PBS -M luke.slipski.gr@dartmouth.edu
#PBS -N compute_cha_mats
#PBS -l nodes=1:ppn=12
#PBS -l walltime=24:00:00
#PBS -o /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/compute_cha_mats_${PBS_JOBID}.o
#PBS -e /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/compute_cha_mats_${PBS_JOBID}.e

module load matlab

matlab -nodisplay -nosplash -nodesktop -r "cd('/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/helper_scripts');compute_cha_mats;exit;"
