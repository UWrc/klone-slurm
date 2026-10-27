# Scheduling Jobs on Klone

When you first log in to Klone, you land on a shared login node (klone-login01). Login nodes are shared and are for light work: navigating files, transferring data, setting up your software environment, and preparing or submitting jobs.

> ⚠️ **WARNING: Do not run compute-heavy work on login nodes.** All compute work must be run through the job scheduler, Slurm.

[Slurm](https://slurm.schedmd.com/documentation.html) (Simple Linux Utility for Resource Management) is the workload manager used on Hyak clusters. It allocates compute resources (CPUs, GPUs, and memory) on the cluster, determines when jobs start, and decides where they run. Slurm ensures efficient sharing of the cluster among all users.

## Accounts and Partitions

Start with:

```bash
hyakalloc
```

`hyakalloc` shows your accounts, available resources, and utilization.

Your **account** identifies your lab/group allocation. A **partition** selects a pool of hardware. Klone's condo model gives groups priority access to contributed resources, with group-wide limits based on their contributions.

Examples of hardware partitions include `compute`, memory-oriented partitions such as `compute-bigmem`, `cpu-g2`, `cpu-g2-mem2x`, and GPU partitions such as `gpu-2080ti`, `gpu-a40`, `gpu-a100`, `gpu-l40`, and `gpu-l40s`. Use current `hyakalloc` and `sinfo -s` output to choose. Access and available hardware vary.

For this tutorial, CPU jobs use `--account=uwit` and `--partition=compute`; GPU jobs use `--account=uwit` and `--partition=gpu-2080ti`. If you are following this tutorial outside the workshop, replace these with an account and partition you can access, as shown by `hyakalloc`. Always submit from the `klone-slurm` directory so relative script and log paths resolve correctly.

## Checkpoint Partitions and Preemption

| Partition | Idle resources eligible for scheduling |
| :- | :- |
| `ckpt` | First-generation (g1) nodes |
| `ckpt-g2` | Second-generation (g2) nodes |
| `ckpt-all` | Either generation |

> **Limits:**
> - Checkpoint jobs can be stopped and requeued without notice when resource contributors need them.
> - They are also stopped and requeued periodically: approximately every 4–5 hours for CPU-only jobs and 8–9 hours for GPU jobs.
> - Idle nodes do not guarantee an immediate start, and checkpoint jobs may also be throttled during heavy filesystem load; check `hyakalloc` for current limits.
>
> 📝 **NOTE: Requeueing does not save your application's in-memory state.** Production workflows must save checkpoints and reload them when restarted. Request the maximum expected runtime using `--time`; checkpoint preemption can happen sooner.

See [Klone scheduler documentation](https://hyak.uw.edu/docs/systems/klone/scheduling-jobs/) for policies and details.

## Common Slurm Arguments

| Argument | Command Flags | Notes |
| :- | :- | :- |
| Account | `-A`, `--account` | Your lab/group account from `hyakalloc` |
| Partition | `-p`, `--partition` | Hardware pool or checkpoint partition |
| Nodes | `-N`, `--nodes` | Nodes to request. Most jobs use 1; multi-node jobs are possible if supported by your code. |
| Tasks | `-n`, `--ntasks` | Processes to launch, e.g. MPI ranks |
| CPUs per task | `-c`, `--cpus-per-task` | Cores allocated to each task |
| Memory | `--mem` | System RAM per node in the format `size[units]`, e.g. `8G`; not GPU memory |
| GPUs | `--gpus` | Optional GPU type/count, e.g. `2080ti:1` |
| Time | `-t`, `--time` | Maximum runtime in `D-HH:MM:SS` |

> 📝 **NOTE:** Requesting extra CPUs or GPUs does not parallelize serial code. Match resource requests to your program's process/thread layout.

See the [salloc](https://slurm.schedmd.com/salloc.html) and [sbatch](https://slurm.schedmd.com/sbatch.html) manuals for other options.

## Understanding Job Types

There are two main ways to run work on Klone:

| Job Type | Command | Best For | Runs On |
| :- | :- | :- | :- |
| **Interactive Job** | `salloc` | Exploratory or hands-on work | A compute node you connect to directly |
| **Batch Job** | `sbatch` | Long or unattended jobs | Scheduled automatically when resources are available |

## Interactive CPU Jobs with `salloc`

An interactive allocation gives you a shell on a compute node — great for testing or exploring.

```bash
salloc --account=uwit --partition=compute --nodes=1 --ntasks=1 --cpus-per-task=1 --mem=1G --time=00:10:00
```

The job will wait in the queue. When the job starts, you’ll see messages similar to:

```bash
salloc: Pending job allocation 42426053
salloc: job 42426053 queued and waiting for resources
salloc: job 42426053 has been allocated resources
salloc: Granted job allocation 42426053
salloc: Nodes n3013 are ready for job
```

> 💡 **TIP:** Keep track of your jobID (e.g., 42426053) — it helps us troubleshoot issues if your job fails.

On Klone the shell moves to an allocated compute node:

```bash
hostname
```

Confirm the hostname changes from the login node (klone-login0*) to another Klone compute node (e.g., n3013).

Release the allocation when finished:

```bash
exit
```

## Interactive GPU Jobs (Optional)

Request a GPU from a specific GPU partition, or select a GPU type and count from checkpoint resources:

```bash
salloc --account=uwit --partition=gpu-2080ti --nodes=1 --ntasks=1 --cpus-per-task=1 --gpus=1 --mem=8G --time=00:10:00
# Or request a GPU job in the checkpoint partition:
salloc --account=uwit --partition=ckpt-all --nodes=1 --ntasks=1 --cpus-per-task=1 --gpus=2080ti:1 --mem=8G --time=00:10:00
```

`2080ti:1` selects one 2080 Ti GPU. Device memory varies by model; `--mem=8G` requests host RAM and does not change device memory.

Check GPU availability:

```bash
nvidia-smi
```

If you see GPU details (e.g., NVIDIA GeForce RTX 2080 Ti with driver and CUDA versions), you're ready to compute.

See [GPUs on Klone](https://hyak.uw.edu/docs/systems/klone/gpus/) for model details and requests. Run `exit` to release your GPU allocation when done.

## Batch Jobs with `sbatch`

Batch jobs run automatically without supervision. A **batch script** declares resources and commands.

View the example job script for scheduling a CPU job on Klone:

```bash
cat job.slurm
```

```bash
#!/bin/bash

#SBATCH --job-name=myjob
#SBATCH --account=uwit
#SBATCH --partition=compute
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:10:00
#SBATCH --output=slurm-%j.out

hostname
echo "Job $SLURM_JOB_ID running on $(hostname)"
sleep 60
```

Submit from the repository directory on the login node:

```bash
sbatch job.slurm
```

Slurm will return a job ID and queue it for execution. When resources become available, the job will start automatically. Output goes to `slurm-<job_id>.out` in the submission directory.

To cancel a pending or running job:

```bash
# Replace <job_id> with the real jobID returned by Slurm.
scancel <job_id>
```

## Monitoring Jobs with `squeue`

To check your running and pending jobs:

```bash
squeue -u "$USER"
```

Watch your queue refresh every 10 seconds:

```bash
watch -n 10 squeue -u "$USER"
```

The `watch` command can be terminated with a keyboard interrupt `Ctrl+C`; this does not cancel your jobs.

To understand `squeue` output:

| Column | Description |
| :- | :- |
| `JOBID` | Job identifier: use this to reference it in other commands |
| `PARTITION` | Resource partition, e.g. `compute` or `ckpt-all` |
| `NAME` | Job name specified with `--job-name` |
| `ST` | Job state: `PD` pending, `R` running, `CG` completing, `CD` completed |
| `TIME` | Elapsed runtime |
| `NODELIST(REASON)` | Allocated node(s) or reason for pending (e.g., `Resources` or `Priority`) |

For more details or to customize the output format of `squeue`, refer to the [squeue manual](https://slurm.schedmd.com/squeue.html).

Completed jobs usually disappear from `squeue`; use `sacct` to inspect their history.

Use `sinfo -s` for a current partition summary. The output describes cluster resources, not a guarantee that your account can immediately allocate them.
