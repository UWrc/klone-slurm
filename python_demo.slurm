#!/bin/bash

#SBATCH --job-name=python_demo
#SBATCH --partition=ckpt-all
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:05:00
#SBATCH --output=logs/%x_%j.out

# Submit from the repository directory with --account=<your_account>.
set -euo pipefail
module load conda
conda activate base
python "$SLURM_SUBMIT_DIR/python_demo.py"
