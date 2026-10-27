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
- [4. Run a CPU Array Job](#4-run-a-cpu-array-job)
- [5. Inspect Usage and Release Resources](#5-inspect-usage-and-release-resources)
- [Optional: GPU Jobs with PyTorch](#optional-gpu-jobs-with-pytorch)
  - [Single GPU Batch Job](#single-gpu-batch-job)
  - [GPU Array Job](#gpu-array-job)
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

Klone provides a shared Miniforge (Conda) module with Python preinstalled. Load Conda module on the compute node:

```bash
module load conda
```

You can explore available softwares with `module avail` or `module spider`. See [Python and Conda](https://hyak.uw.edu/docs/guides/software/conda-python/) and [Software Environment on Klone](https://hyak.uw.edu/docs/guides/software/modules) for more details on how softwares are managed on Klone.

Activate Conda base environment and onfirm that Python is available:

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

## 4. Run a CPU Array Job

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

## 5. Inspect Usage and Release Resources

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

You need a **Conda environment with CUDA-enabled PyTorch installed on Klone**.

On the login node, set the path before submission:

```bash
# Replace this example path with the actual readable SIF supplied for the workshop.
export PYTORCH=/gscratch/your-group/containers/pytorch.sif
test -r "$PYTORCH" && echo "Container is readable"
```

Do not proceed unless it is readable. The batch scripts receive the exported variable through Slurm's default environment export. The supplied scripts select one `2080ti` GPU from `ckpt-all`; use the current resource listing and instructor guidance if choosing another model:

```bash
sinfo -p ckpt-all -O nodehost,cpusstate,freemem,gres,gresused -S nodehost | grep -v null
```

For an interactive GPU check:

```bash
salloc -A uwit -p gpu-2080ti -N 1 -c 1 -G 1 --mem=8G --time=00:30:00
hostname
nvidia-smi
exit
```

`nvidia-smi` should report the selected GPU. `--mem=8G` requests host RAM; device memory is fixed by the GPU model. See [GPUs on Klone](https://hyak.uw.edu/docs/systems/klone/gpus/).

### Single GPU Batch Job

Back on the login node, inspect the Python script and batch wrapper:

```bash
cat pytorch_demo.py
cat pytorch_demo.slurm
```

```bash
#!/bin/bash

#SBATCH --job-name=pytorch
#SBATCH --partition=ckpt-all
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gpus-per-node=2080ti:1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=00:10:00
#SBATCH --output=logs/%x_%j.out

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
```

The script loads the Apptainer module on the compute node. `--nv` exposes NVIDIA GPUs inside the container, and `--bind /gscratch` exposes Klone's scratch filesystem. Keep the repository and SIF under `/gscratch` for this example. Commands use the submission directory rather than a hard-coded user path.

Submit from the repository directory after setting `PYTORCH`:

```bash
mkdir -p logs
sbatch --account="$MY_ACCOUNT" pytorch_demo.slurm
squeue -u "$USER"
```

After completion (replace `<job_id>`):

```bash
cat logs/pytorch_<job_id>.out
cat logs/results_<job_id>_task_0.txt
```

The program reports the detected GPU, performs a small matrix multiplication, and writes a checksum and runtime. It fails if CUDA is unavailable, so an incompatible container or missing GPU is visible as a failed job. Runtime and checksum vary.

### GPU Array Job

```bash
cat pytorch_array.slurm
sbatch --account="$MY_ACCOUNT" pytorch_array.slurm
```

`--array=0-4%2` creates five tasks and permits up to two concurrent tasks. Each requests one GPU and 8 GB of host RAM. Each array index selects a different learning-rate label; the matrix operation is a demonstration, not model training, and does not use that learning rate.

After the array finishes, substitute its job ID:

```bash
ls logs/pytorch_array_<array_job_id>_*.out
cat logs/results_<array_job_id>_task_*.txt
sacct -j <array_job_id> -o JobID,State,Elapsed,ExitCode
```

Result filenames include the job/array ID and task ID so separate submissions do not overwrite each other's results. These GPU examples restart from scratch if preempted; production training must implement checkpoint saving and resuming.

## Optional: Cleanup

After all tutorial jobs have finished or been cancelled and you have saved any results you need, remove the tutorial log directory from your repository clone:

```bash
rm -r logs
```

Recreate it with `mkdir -p logs` before submitting further jobs.
