#!/bin/bash

#SBATCH --job-name=loop_array
#SBATCH --account=uwit
#SBATCH --partition=compute
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:05:00
#SBATCH --array=0-9%2
#SBATCH --output=logs/%x_%A_%a.out

# Each array task runs the same code with different ranges of numbers.
# COUNT sets the number of iterations per task.
# Runtime varies with the CPU type and system load.
COUNT=5000000

# Use the array index SLURM_ARRAY_TASK_ID to set up the starting and ending point for each task.
START=$((${SLURM_ARRAY_TASK_ID} * ${COUNT}))
END=$((${START} + ${COUNT} - 1))

# Command
echo "Starting task $SLURM_ARRAY_TASK_ID on $(hostname)"
echo "Job array ID: $SLURM_ARRAY_JOB_ID"
time ./loop_script.sh ${START} ${END}
echo "Task $SLURM_ARRAY_TASK_ID completed at $(date)"
