#!/bin/bash

#SBATCH --job-name=loop_var
#SBATCH --partition=ckpt-all
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:10:00
#SBATCH --output=logs/slurm-%j.out

# Submit from the repository directory with --account=<your_account>.
set -euo pipefail

# Define variables
WORKDIR="$SLURM_SUBMIT_DIR"
SCRIPT="loop_script.sh"

echo "Working directory: $WORKDIR"
cd "$WORKDIR"

# Run Bash script
time "./$SCRIPT" 0 1000000

echo "Job completed successfully!"
