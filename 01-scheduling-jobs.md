# Scheduling Jobs on Klone

Login nodes are shared and are for light work: navigating files, transferring data, and preparing or submitting jobs. **Run computations through Slurm on compute nodes.**

## Accounts and Partitions

Start with:

```bash
hyakalloc
sinfo -s
```

Your **account** identifies your lab/group allocation. A **partition** selects a pool of nodes. Klone's condo model gives groups priority access to contributed resources, with group-wide limits based on their contributions. CPU-only jobs are supported. GPUs are optional and must be explicitly requested when needed.

Examples of hardware partitions include `compute`, memory-oriented partitions such as `compute-bigmem`, `cpu-g2`, `cpu-g2-mem2x`, and GPU partitions such as `gpu-2080ti`, `gpu-a40`, `gpu-a100`, `gpu-l40`, and `gpu-l40s`. Use current `hyakalloc` and `sinfo -s` output to choose; access and available hardware vary.

For this tutorial, set `MY_ACCOUNT` as described in [preparation](./00-preparation.md). Commands use `ckpt-all` so they do not assume your group owns a particular CPU or GPU node. Prefer your group's appropriate priority partition for live interactive work when available.

## Checkpoint Partitions and Preemption

| Partition | Idle resources eligible for scheduling |
| :- | :- |
| `ckpt` | First-generation (g1) nodes |
| `ckpt-g2` | Second-generation (g2) nodes |
| `ckpt-all` | Either generation |

Checkpoint jobs can lose resources without notice when contributors need them. They are also stopped and requeued periodically: approximately every 4–5 hours for CPU-only jobs and 8–9 hours for GPU jobs. Interactive checkpoint jobs are subject to the same interruptions. Idle nodes do not guarantee an immediate start, and checkpoint jobs may also be throttled during heavy filesystem load; check `hyakalloc` for current limits.

**Requeueing does not save your application's in-memory state.** Production workflows must save checkpoints and reload them when restarted. The short examples here restart their work from the beginning and are not application-checkpointing demonstrations. Request the maximum expected runtime with some margin using `--time`; checkpoint preemption can happen sooner.

The g1 and g2 CPUs differ. Software compiled for one architecture may need rebuilding for the other; choose a generation-specific partition when necessary. See the authoritative [Klone scheduler documentation](https://hyak.uw.edu/docs/systems/klone/scheduling-jobs/) for policies and details.

## Common Slurm Arguments

| Argument | Flags | Meaning |
| :- | :- | :- |
| Account | `-A`, `--account` | Your lab/group account from `hyakalloc` |
| Partition | `-p`, `--partition` | Hardware pool or checkpoint partition |
| Nodes | `-N`, `--nodes` | Machines requested; these examples use one |
| Tasks | `-n`, `--ntasks` | Processes to launch, e.g. MPI ranks; examples use one |
| CPUs per task | `-c`, `--cpus-per-task` | Cores allocated to each task; code must use threads to benefit |
| Memory | `--mem` | System RAM per node, e.g. `1G` or `8G`; not GPU memory |
| GPUs per node | `--gpus-per-node` | Optional GPU type/count, e.g. `2080ti:1` |
| Time | `-t`, `--time` | Maximum runtime, e.g. `00:30:00` or `1-00:00:00` |

Requesting extra CPUs or GPUs does not parallelize serial code. Match resource requests to your program's process/thread layout. See the [salloc](https://slurm.schedmd.com/salloc.html) and [sbatch](https://slurm.schedmd.com/sbatch.html) manuals for other options.

## Interactive CPU Jobs

An interactive allocation gives you a shell on a compute node:

```bash
salloc --account="$MY_ACCOUNT" --partition=ckpt-all --nodes=1 --ntasks=1 --cpus-per-task=1 --mem=1G --time=00:30:00
hostname
```

The request waits until Slurm grants resources. Record the job ID printed by `salloc`. On Klone the shell moves to an allocated node; confirm the hostname differs from the login node before doing compute work. Module commands are available on compute nodes.

Release the allocation when finished:

```bash
exit
```

## Interactive GPU Jobs (Optional)

Inspect GPU resources, then request a specific type and count:

```bash
sinfo -p ckpt-all -O nodehost,cpusstate,freemem,gres,gresused -S nodehost | grep -v null
salloc --account="$MY_ACCOUNT" --partition=ckpt-all --nodes=1 --ntasks=1 --cpus-per-task=1 --gpus-per-node=2080ti:1 --mem=8G --time=00:30:00
hostname
nvidia-smi
```

`2080ti:1` selects one 2080 Ti GPU. Other Klone models include A40, A100, RTX6k, L40, L40S, P100, and Titan. Select a type reported in the current resource listing and compatible with your software. Device memory varies by model; `--mem=8G` requests host RAM and does not change device memory. If your group owns GPUs, you can instead use its GPU partition with a matching GPU request.

See [GPUs on Klone](https://hyak.uw.edu/docs/systems/klone/gpus/) for model details and requests. Run `exit` to release your GPU allocation when done.

## Batch Jobs

A batch script declares resources and commands. View the CPU example:

```bash
cat job.slurm
```

```bash
#!/bin/bash

#SBATCH --job-name=myjob
#SBATCH --partition=ckpt-all
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:05:00
#SBATCH --output=slurm-%j.out

# Submit from the repository directory with --account=<your_account>.
set -euo pipefail

hostname
echo "Job $SLURM_JOB_ID running on $(hostname)"
sleep 30
```

Submit from the repository directory on the login node:

```bash
sbatch --account="$MY_ACCOUNT" job.slurm
```

Slurm returns a job ID. Output goes to `slurm-<job_id>.out` in the submission directory. `sbatch` returns immediately; the job may remain pending until resources become available. Command-line options override directives, for example `--partition=compute` if your account has that allocation.

## Monitor and Cancel Jobs

```bash
squeue -u "$USER"
watch -n 10 squeue -u "$USER"
```

Use `Ctrl+C` to stop watching; this does not cancel your jobs.

| Column | Meaning |
| :- | :- |
| `JOBID` | Job identifier |
| `PARTITION` | Resource partition, e.g. `ckpt-all` or `compute` |
| `NAME` | Job name |
| `ST` | State: `PD` pending, `R` running, `CG` completing |
| `TIME` | Elapsed runtime |
| `NODELIST(REASON)` | Allocated nodes or reason for waiting |

Completed jobs usually disappear from `squeue`; use `sacct` to inspect their history. To cancel a pending or running job:

```bash
# Replace <job_id> with the ID returned by Slurm.
scancel <job_id>
```

Use `sinfo -s` for a current partition summary. The output describes cluster resources, not a guarantee that your account can immediately allocate them.
