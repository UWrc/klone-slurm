# Klone Slurm Training 2026

High-performance computing (HPC) clusters use a job scheduler to share CPUs, GPUs, memory, and nodes among users. Klone uses [Slurm](https://slurm.schedmd.com/documentation.html) for resource allocation, job submission, and queueing.

Klone is Hyak's general-purpose HPC cluster, with CPU and GPU partitions and multiple hardware generations. Groups have priority access to the resources they contribute through a condo model. Checkpoint partitions also let users run on idle resources, subject to preemption. See [Scheduling Jobs on Klone](https://hyak.uw.edu/docs/systems/klone/scheduling-jobs/).

By completing this tutorial, you will learn to:

- Discover your accounts and partitions with `hyakalloc`.
- Request interactive CPU and GPU sessions and submit batch jobs.
- Inspect job status, resource requests, and completed-job accounting.
- Write Bash workflows and run independent tasks with Slurm arrays.
- Choose resource sizes and understand checkpoint/preemption behavior.

The core exercises use one CPU and require no GPU software. An optional PyTorch exercise introduces GPU requests and containers.

## Repository Structure

| Section | Description |
| :- | :- |
| [00-preparation.md](./00-preparation.md) | SSH login, Klone storage, repository setup, and account selection |
| [01-scheduling-jobs.md](./01-scheduling-jobs.md) | Accounts, partitions, checkpoint jobs, and interactive/batch scheduling |
| [02-monitoring-resource.md](./02-monitoring-resource.md) | Job status, accounting, and resource efficiency |
| [03-bash-scripts.md](./03-bash-scripts.md) | Bash workflows, variables, modules, and logs |
| [04-job-arrays.md](./04-job-arrays.md) | Independent CPU tasks using job arrays |
| [05-task.md](./05-task.md) | Hands-on CPU exercises and optional GPU/PyTorch jobs |

## Before Submitting Examples

Follow [preparation](./00-preparation.md) first. Run all `sbatch` commands from the repository directory, create `logs/` before submission, and pass your account with `--account="$MY_ACCOUNT"`. The scripts default to `ckpt-all`; use a partition listed for your account by `hyakalloc` for priority access.

For the optional GPU exercise, you need a CUDA-enabled PyTorch SIF accessible on Klone. [The exercise](./05-task.md#optional-gpu-jobs-with-pytorch) explains how to supply its path; no shared workshop image is assumed.

## Instructor Preparation

Before the workshop, verify the account/partition available to attendees and test the examples on Klone. Prefer a suitable priority partition for live interactive work when available. For the optional exercise, provide and test a PyTorch SIF compatible with the selected GPU type and driver, and share its absolute path. This repository does not provision accounts or download a container automatically.

## Recording and Feedback

The 2026 recording link will be added after the workshop. Please share feedback through our [feedback survey](https://forms.cloud.microsoft/r/pvcRwSb2th).

## Additional Resources

- [Klone Documentation](https://hyak.uw.edu/docs/systems/klone/)
- [Scheduling Jobs](https://hyak.uw.edu/docs/systems/klone/scheduling-jobs/)
- [GPUs on Klone](https://hyak.uw.edu/docs/systems/klone/gpus/)
- [Storage on Klone](https://hyak.uw.edu/docs/systems/klone/storage/)
- [Software Modules](https://hyak.uw.edu/docs/guides/software/modules/)
- [Python and Conda](https://hyak.uw.edu/docs/guides/software/conda-python/)
- [Slurm Documentation](https://slurm.schedmd.com/documentation.html)
