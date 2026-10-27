#!/bin/bash

#SBATCH --job-name=pytorch
#SBATCH --account=uwit
#SBATCH --partition=gpu-2080ti
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gpus-per-node=2080ti:1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=00:10:00
#SBATCH --output=logs/%x_%j.out

module load conda
conda activate trainingslurm
export PYTHONNOUSERSITE=1

WORKDIR="$SLURM_SUBMIT_DIR"
cd "$WORKDIR"
export OMP_NUM_THREADS="$SLURM_CPUS_PER_TASK"
python "$WORKDIR/pytorch_demo.py"
