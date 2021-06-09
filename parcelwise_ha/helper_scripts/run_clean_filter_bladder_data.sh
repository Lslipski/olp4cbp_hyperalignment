#!/bin/bash -l
#PBS  -m bea
#PBS -M luke.slipski.gr@dartmouth.edu
#PBS -N clean_filter_bladder
#PBS -l nodes=1:ppn=16
#PBS -l walltime=70:00:00
#PBS -o /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/clean_filter_bladder_${PBS_JOBID}.o
#PBS -e /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/clean_filter_bladder_${PBS_JOBID}.e

module load matlab

matlab -nodisplay -nosplash -nodesktop -r "cd('/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/scripts/parcelwise_ha/helper_scripts/');prepare_bladder_data_for_HA;exit;"
