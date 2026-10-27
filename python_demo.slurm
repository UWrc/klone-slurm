#!/bin/bash

#SBATCH --job-name=python_demo
#SBATCH --account=uwit
#SBATCH --partition=compute
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:05:00
#SBATCH --output=logs/%x_%j.out

module load conda
conda activate base
export PYTHONNOUSERSITE=1
python "$SLURM_SUBMIT_DIR/python_demo.py"
