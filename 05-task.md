<!-- omit in toc -->
# Hands-on Exercise: Running Jobs on Klone

This hands-on exercise walks you through the essential steps of submitting and monitoring jobs on Klone.

You'll practice an interactive CPU session, a Python batch job, and a CPU job array. Then optionally run GPU jobs with PyTorch.

> 🎯 **GOAL:** Learn how to load your computing environment and run jobs efficiently on Klone.

**Overview**

- [0. Preparation](#0-preparation)
- [1. Start an Interactive CPU Job](#1-start-an-interactive-cpu-job)
- [2. Load the Conda Module](#2-load-the-conda-module)
- [3. Run a Simple Python Script](#3-run-a-simple-python-script)
- [4. Run a CPU Batch Job](#4-run-a-cpu-batch-job)
- [5. Run a CPU Array Job](#5-run-a-cpu-array-job)
- [6. Inspect Usage and Release Resources](#6-inspect-usage-and-release-resources)
- [Optional: GPU Jobs with PyTorch](#optional-gpu-jobs-with-pytorch)
- [Optional: Cleanup](#optional-cleanup)

## 0. Preparation

If you haven't already, follow the instructions in [00-preparation](./00-preparation.md) to log in to Klone and set up your working directory for the following exercise.

## 1. Start an Interactive CPU Job

> ⚠️ **WARNING: All compute work must be done on compute nodes.**

From the login node, request one CPU for 30 minutes:

```bash
salloc -A uwit -p compute -N 1 -c 1 --mem=1G --time=00:30:00
```

Once resources are allocated, confirm you’re on a compute node:

```bash
hostname
```

## 2. Load the Conda Module

Klone provides a shared Miniforge (Conda) module with Python preinstalled. Load the Conda module on the compute node:

```bash
module load conda
```

You can explore available software with `module avail` or `module spider`. See [Python and Conda](https://hyak.uw.edu/docs/guides/software/conda-python/) and [Software Environment on Klone](https://hyak.uw.edu/docs/guides/software/modules) for more details on how software is managed on Klone.

Activate the Conda base environment and confirm that Python is available:

```bash
conda activate
which python
python --version
```

You’ll see the system Miniforge Python path under `/mmfs1/sw/miniforge3/25.9.1-0/bin/python`.

## 3. Run a Simple Python Script

Run the provided example Python script:

```bash
python python_demo.py
```

The script prints a greeting, Python version, and optional CUDA information before exiting. For example:

```text
Starting Klone Python demo job...
Python version: 3.12.12
Checking CUDA availability...
PyTorch not installed; skipping GPU check.
Job completed successfully.
```

> 📝 **NOTE:** The exact Python version and CUDA message depend on the environment. In the base Conda environment, CUDA may appear unavailable because GPU-enabled libraries (e.g., PyTorch or TensorFlow) are not installed. That’s expected for this exercise.

Release your allocation:

```bash
exit
```

## 4. Run a CPU Batch Job

Back on the login node, view the script:

```bash
cat python_demo.slurm
```

```bash
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
python "$SLURM_SUBMIT_DIR/python_demo.py"
```

The batch job loads its own environment. Submit the job from the repository directory:

```bash
sbatch python_demo.slurm
```

Check the status of the job:

```bash
squeue -u $USER
```

Record the returned job ID. After it finishes, view the standard output of the job (replace `<job_id>`):

```bash
cat logs/python_demo_<job_id>.out
sacct -j <job_id> -o JobID,State,Elapsed,ExitCode
```

A successful job should have state `COMPLETED` and exit code `0:0`.

## 5. Run a CPU Array Job

Job arrays are an efficient way to submit and manage multiple similar jobs in parallel.

Review [job arrays](./04-job-arrays.md) and the supplied script:

```bash
cat loop_array.slurm
sbatch loop_array.slurm
watch -n 10 squeue -u "$USER"
```

Stop watching with `Ctrl+C`. The directive `--array=0-9` creates ten independent tasks. Each task requests one CPU and 1 GB host RAM, with no GPU.

After completion:

```bash
ls logs/loop_array_*.out
```

Each log should report a distinct, non-overlapping range of numbers. Use `sacct -j <array_job_id>` to inspect the states of individual tasks.

## 6. Inspect Usage and Release Resources

```bash
hyakalloc
sacct -j <job_id> -o JobID,State,Elapsed,TotalCPU,MaxRSS,ReqMem,ExitCode
```

`seff <job_id>` also summarizes CPU/memory efficiency. Use [monitoring resource usage](./02-monitoring-resource.md) to interpret these statistics. Small demonstration jobs may show very low usage or sparse accounting samples.

Cancel any pending or running tutorial jobs you no longer need:

```bash
scancel <job_id>
```

## Optional: GPU Jobs with PyTorch

The workshop uses the `trainingslurm` Conda environment with CUDA-enabled PyTorch installed on Klone. Load and activate it on the allocated compute node before running Python commands. `PYTHONNOUSERSITE=1` prevents Python from importing packages from your user site-packages directory, helping avoid conflicts with the training environment.

For an interactive GPU check:

```bash
salloc -A uwit -p gpu-2080ti -N 1 -c 1 -G 1 --mem=8G --time=00:30:00
hostname
nvidia-smi
module load conda
conda activate trainingslurm
export PYTHONNOUSERSITE=1
python -c 'import torch; print("PyTorch:", torch.__version__); print("CUDA available:", torch.cuda.is_available())'
exit
```

`nvidia-smi` should report the selected GPU, and PyTorch should report `CUDA available: True`. `--mem=8G` requests host RAM; device memory is fixed by the GPU model. See [GPUs on Klone](https://hyak.uw.edu/docs/systems/klone/gpus/).

**Single GPU Batch Job**

Back on the login node, inspect the Python script and batch wrapper:

```bash
cat pytorch_demo.py
cat pytorch_demo.slurm
```

```bash
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

# Load the training environment on the allocated compute node.
module load conda
conda activate trainingslurm
export PYTHONNOUSERSITE=1

WORKDIR="$SLURM_SUBMIT_DIR"
cd "$WORKDIR"
export OMP_NUM_THREADS="$SLURM_CPUS_PER_TASK"
python "$WORKDIR/pytorch_demo.py"
```

The script loads Conda, activates `trainingslurm`, and sets `PYTHONNOUSERSITE=1` on the compute node. It runs the Python script directly from the submission directory. Each batch job configures its own environment.

Submit from the repository directory:

```bash
sbatch pytorch_demo.slurm
squeue -u "$USER"
```

After completion (replace `<job_id>`):

```bash
cat logs/pytorch_<job_id>.out
cat logs/results_<job_id>.txt
```

The program reports the detected GPU, performs a small matrix multiplication, and writes a checksum and runtime. It fails if CUDA is unavailable, so an incorrect Python environment or missing GPU is visible as a failed job. Runtime and checksum vary.

## Optional: Cleanup

After all tutorial jobs have finished or been cancelled and you have saved any results you need, remove the tutorial log directory from your repository clone:

```bash
rm -r logs
```
