#!/bin/bash
# Name
#SBATCH --job-name=parcel_hyperalignment
# compute nodes
#SBATCH --nodes=1
# tasks per node
#SBATCH --ntasks-per-node=6
# CPUs per task
#SBATCH --cpus-per-task=1
# Request memory
#SBATCH --mem=8G
# Walltime (job duration)
#SBATCH --time=00:15:00
# Name of partition
#SBATCH --partition=standard
# Email notifications (comma-separated options: BEGIN,END,FAIL)
#SBATCH --mail-type=BEGIN,END,FAIL
# Output and Error files
#SBATCH -o /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/%x_%A_%a.o
#SBATCH -e /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/log/%x_%A_%a.e
#SBATCH --account=DBIC
# Array 
#SBATCH --array=[393,487]


source /optnfs/common/miniconda3/etc/profile.d/conda.sh
module load python/anaconda2
conda activate comp_meth_env
echo Successfully sourced conda, loaded anaconda2, and activated comp_meth_env.

parcel=$((${SLURM_ARRAY_TASK_ID}-1))
python /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/scripts/parcelwise_ha/parcel_hyperalignment.py $parcel
