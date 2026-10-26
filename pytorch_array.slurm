#!/bin/bash

#SBATCH --job-name=pytorch_array
#SBATCH --partition=ckpt-all
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gpus-per-node=2080ti:1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=00:10:00
#SBATCH --array=0-4%2
#SBATCH --output=logs/%x_%A_%a.out

# Submit from the repository directory with --account=<your_account>.
# Set PYTORCH to an existing, readable CUDA-enabled PyTorch SIF on Klone.
set -euo pipefail
: "${PYTORCH:?Set PYTORCH to the absolute path of your PyTorch SIF before sbatch}"
if [[ "$PYTORCH" != /* || ! -r "$PYTORCH" ]]; then
    echo "PYTORCH must be an absolute path to a readable SIF: $PYTORCH" >&2
    exit 1
fi
module load apptainer
WORKDIR="$SLURM_SUBMIT_DIR"
cd "$WORKDIR"
export OMP_NUM_THREADS="$SLURM_CPUS_PER_TASK"
apptainer exec --nv --bind /gscratch "$PYTORCH" python "$WORKDIR/pytorch_demo.py"
