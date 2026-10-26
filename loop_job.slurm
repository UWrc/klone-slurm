#!/bin/bash

#SBATCH --job-name=loop_job
#SBATCH --partition=ckpt-all
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:10:00
#SBATCH --output=logs/slurm-%j.out

# Submit from the repository directory with --account=<your_account>.
set -euo pipefail

# Print environment info
echo "Running on host: $(hostname)"
echo "Job started at: $(date)"

# Run your workflow
time ./loop_script.sh 0 1000000

echo "Job finished at: $(date)"
