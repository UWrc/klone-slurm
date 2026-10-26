# Hands-on Exercise: Running Jobs on Klone

Practice an interactive CPU session, a Python batch job, and a CPU job array. Then optionally run GPU jobs with PyTorch. Complete [preparation](./00-preparation.md) first: log in to Klone, enter your clone of `klone-slurm`, create `logs/`, and set `MY_ACCOUNT` to your real Slurm account.

## 1. Start an Interactive CPU Job

From the login node, request one CPU for 30 minutes:

```bash
salloc --account="$MY_ACCOUNT" --partition=ckpt-all --nodes=1 --ntasks=1 --cpus-per-task=1 --mem=1G --time=00:30:00
hostname
```

Wait for the allocation and confirm you are on a compute node. If your account has a suitable priority partition, use it instead of `ckpt-all` for interactive work. Checkpoint allocations can be interrupted; see [scheduling jobs](./01-scheduling-jobs.md#checkpoint-partitions-and-preemption).

## 2. Load Python and Run a Script

On the compute node:

```bash
module load conda
conda activate base
python --version
which python
python python_demo.py
```

Klone supports the shared Conda module. Modules are available only on compute nodes, including batch jobs. See [Python and Conda](https://hyak.uw.edu/docs/guides/software/conda-python/) and [Modules](https://hyak.uw.edu/docs/guides/software/modules/).

The script prints a greeting, Python version, and optional CUDA information before exiting. For example:

```text
Starting Klone Python demo job...
Python version: <installed version>
Checking CUDA availability...
PyTorch not installed; skipping GPU check.
Job completed successfully.
```

The exact Python version and CUDA message depend on the environment. This CPU exercise needs no PyTorch installation or GPU. If PyTorch is present, CUDA should be unavailable in this CPU-only allocation.

Release your allocation:

```bash
exit
```

## 3. Submit a CPU Batch Job

Back on the login node, view the script:

```bash
cat python_demo.slurm
```

```bash
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
```

The batch job loads its own environment. From the repository directory:

```bash
mkdir -p logs
sbatch --account="$MY_ACCOUNT" python_demo.slurm
squeue -u "$USER"
```

Record the returned job ID. After it finishes, inspect its log (replace `<job_id>`):

```bash
cat logs/python_demo_<job_id>.out
sacct -j <job_id> -o JobID,State,Elapsed,ExitCode
```

A successful job should have state `COMPLETED` and exit code `0:0`.

## 4. Submit a CPU Array

Review [job arrays](./04-job-arrays.md) and the supplied script:

```bash
cat loop_array.slurm
sbatch --account="$MY_ACCOUNT" loop_array.slurm
watch -n 10 squeue -u "$USER"
```

Stop watching with `Ctrl+C`. The directive `--array=0-9%2` creates ten independent tasks with at most two running at once. Each task requests one CPU and 1 GB host RAM, with no GPU.

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

Where installed, `seff <job_id>` also summarizes CPU/memory efficiency. Use [monitoring resource usage](./02-monitoring-resource.md) to interpret these statistics. Small demonstration jobs may show very low usage or sparse accounting samples.

Cancel any pending or running tutorial jobs you no longer need:

```bash
scancel <job_id>
```

## Optional: GPU Jobs with PyTorch

You need a **CUDA-enabled PyTorch Apptainer SIF already accessible on Klone**. Ask the instructor for its tested absolute path, or use your own compatible image. The image and GPU driver must support the selected GPU model. This exercise does not build or download an image.

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
salloc --account="$MY_ACCOUNT" --partition=ckpt-all --nodes=1 --ntasks=1 --cpus-per-task=1 --gpus-per-node=2080ti:1 --mem=8G --time=00:30:00
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
