#!/bin/bash
# Name
#SBATCH --job-name=combine_all_parcels
# compute nodes
#SBATCH --nodes=1
# tasks per node
#SBATCH --ntasks-per-node=16
# CPUs per task
#SBATCH --cpus-per-task=1
# Request memory
#SBATCH --mem=12G
# Walltime (job duration)
#SBATCH --time=48:00:00
# Name of partition
#SBATCH --partition=standard
# Email notifications (comma-separated options: BEGIN,END,FAIL)
#SBATCH --mail-type=BEGIN,END,FAIL
# Output and Error files
#SBATCH -o /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/%x_%A.o
#SBATCH -e /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/%x_%A.e
# Set Account
#SBATCH --account=DBIC


module load matlab
matlab -nodisplay -nosplash -nodesktop -r "cd('/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/scripts/parcelwise_ha/helper_scripts');combine_cha_parcels_into_brain;exit;"
