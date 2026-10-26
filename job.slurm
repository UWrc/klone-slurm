#!/bin/bash

#SBATCH --job-name=myjob
#SBATCH --partition=ckpt-all
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:05:00
#SBATCH --output=slurm-%j.out

# Submit from the repository directory with --account=<your_account>.
set -euo pipefail

hostname
echo "Job $SLURM_JOB_ID running on $(hostname)"
sleep 30
