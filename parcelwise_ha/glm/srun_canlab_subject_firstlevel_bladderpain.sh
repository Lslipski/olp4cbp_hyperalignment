#!/bin/bash
# Name
#SBATCH --job-name=fl_glm
# compute nodes
#SBATCH --nodes=1
# tasks per node
#SBATCH --ntasks-per-node=1
# CPUs per task
#SBATCH --cpus-per-task=2
# Request memory
#SBATCH --mem=64G
# Walltime (job duration)
#SBATCH --time=01:00:00
# Name of partition
#SBATCH --partition=standard
# Email notifications (comma-separated options: BEGIN,END,FAIL)
#SBATCH --mail-type=BEGIN,END,FAIL
# Output and Error files
#SBATCH -o /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/%x_%A_%a.o
#SBATCH -e /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/%x_%A_%a.e
#SBATCH --account=DBIC
# Array 
# original SBATCH --array=1-175%10
#SBATCH --array=[12]


module load matlab

datadir="/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/data/bladderpain/raw"
regdir="/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/parcelwise/analysis/regressors/raw_from_yoni"


matlab -nodisplay -nosplash -nodesktop -r "cd('/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/scripts/parcelwise_ha/glm');canlab_subject_firstlevel_bladderpain(${SLURM_ARRAY_TASK_ID},'$datadir', '$regdir', 'AA');exit;"
