#!/bin/bash
# Job Name
#SBATCH --job-name=subject_first_level
# compute nodes
#SBATCH --nodes=1
# tasks per node
#SBATCH --ntasks-per-node=12
# Request memory
#SBATCH --mem=128G
# Walltime (job duration)
#SBATCH --time=96:00:00
# Name of partition
#SBATCH --partition=standard
# Email notifications (comma-separated options: BEGIN,END,FAIL)
#SBATCH --mail-type=BEGIN,END,FAIL
# Output and Error files
#SBATCH -o /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/%x_%A_%a.o
#SBATCH -e /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/%x_%A_%a.e
#SBATCH --account=DBIC

module load matlab

matlab -nodisplay -nosplash -nodesktop -r "cd('/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/scripts/parcelwise_ha');subject_firstlevel_bladderpain('AA');exit;"
