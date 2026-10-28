# Klone Slurm Training 2026

High-performance computing (HPC) clusters like **Klone** use a **job scheduler** to manage and optimize the allocation of compute resources. A scheduler coordinates how and when jobs are executed across available CPUs, GPUs, memory, and nodes, ensuring efficient and fair use of the system.

**Slurm** (Simple Linux Utility for Resource Management): the job scheduler used across Hyak clusters. It handles job submission, resource allocation, and queueing, enabling thousands of users to share the cluster efficiently. For detailed reference, visit the [Slurm documentation](https://slurm.schedmd.com/documentation.html).

Klone is Hyak's general-purpose HPC cluster, with CPU and GPU partitions and multiple hardware generations. Groups have priority access to the resources they contribute through a condo model. Checkpoint partitions also let users run on idle resources, subject to preemption. See [Scheduling Jobs on Klone](https://hyak.uw.edu/docs/systems/klone/scheduling-jobs/).

🎯 By completing this tutorial, you will learn to:

- Discover your accounts and partitions with `hyakalloc`.
- Request interactive CPU and GPU sessions and submit batch jobs.
- Inspect job status, resource requests, and completed-job accounting.
- Write Bash workflows and run independent tasks with Slurm arrays.
- Choose resource sizes and understand checkpoint/preemption behavior.

The core exercises use one CPU and require no GPU software. An optional PyTorch exercise introduces GPU requests using the `trainingslurm` Conda environment.

## Repository Structure

| Section | Description |
| :- | :- |
| [00-preparation.md](./00-preparation.md) | Logging in via SSH and setting up your working directory |
| [01-scheduling-jobs.md](./01-scheduling-jobs.md) | Scheduling interactive and batch jobs |
| [02-monitoring-resource.md](./02-monitoring-resource.md) | Understanding usage accounting and job monitoring tools |
| [03-bash-scripts.md](./03-bash-scripts.md) | Using Bash scripts to manage your workflows |
| [04-job-arrays.md](./04-job-arrays.md) | Leveraging job arrays for large-scale or parameter-sweep tasks |
| [05-task.md](./05-task.md) | Hands-on exercise: running your own jobs on Klone |

## Recording

The 2026 recording link will be added after the workshop.

[Slide Deck](./slide_klone_slurm.pdf) from live tutorial on Oct 27, 2026

## Feedback

We’d love your feedback to help improve this tutorial and future training sessions. After completing the tutorial or attending the workshop, please take a moment to fill out our [feedback survey](https://forms.cloud.microsoft/r/pvcRwSb2th).

## Additional Resources

- [Hyak Klone Documentation](https://hyak.uw.edu/docs/systems/klone/get-started/)
- [Slurm Documentation](https://slurm.schedmd.com/documentation.html)
- Previous Hyak Klone Slurm tutorials:
  - [Basic Slurm](https://hyak.uw.edu/docs/hyak101/basics/syllabus_slurm)
  - [Advanced Slurm](https://hyak.uw.edu/docs/hyak101/basics/syllabus_advanced)
