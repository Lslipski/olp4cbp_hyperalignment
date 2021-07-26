#!/bin/bash
# Name
#SBATCH --job-name=all_subs_parcelwise_bladder_cnxs
# compute nodes
#SBATCH --nodes=1
# tasks per node
#SBATCH --ntasks-per-node=1
# CPUs per task
#SBATCH --cpus-per-task=16
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

module load python/anaconda2
source /optnfs/common/miniconda3/etc/profile.d/conda.sh
conda activate comp_meth_env

python /dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/hyperalignment/scripts/parcelwise_ha/helper_scripts/all_subs_parcelwise_sponpain_cnxs.py 
