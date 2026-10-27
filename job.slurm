#!/bin/bash

#SBATCH --job-name=myjob
#SBATCH --account=uwit
#SBATCH --partition=compute
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=00:10:00
#SBATCH --output=slurm-%j.out

hostname
echo "Job $SLURM_JOB_ID running on $(hostname)"
sleep 60