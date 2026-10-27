# Monitoring Resource Usage on Klone

Use `hyakalloc` for your group's allocations and current utilization, `squeue` for pending/running jobs, and `sacct` for completed-job records. Klone's allocation model is described in [Scheduling Jobs](https://hyak.uw.edu/docs/systems/klone/scheduling-jobs/).

## Allocation and Queue Status

```bash
hyakalloc
squeue -u "$USER"
sinfo -s
```

If a job is pending, inspect `NODELIST(REASON)` in `squeue` and the job details below. Your account's contributed resources may be busy, the requested resource combination may be unavailable, or checkpoint jobs may be limited. `hyakalloc` reports current checkpoint throttling when in effect.

## Job Accounting with `sacct`

`sacct` displays accounting data for all jobs and job steps in the Slurm database. It’s useful for reviewing job history, including elapsed time, resource requests, and job states. See the [sacct manual](https://slurm.schedmd.com/sacct.html) for a full list of format options.

**View all running jobs:**

```bash
sacct -s running -a -X -o user,jobid,elapsed,account,qos,node,reqtres%50
```

- `-a`: show jobs for all users (omit or use -u <net_id> for specific users).
- `-o`: customize output columns (in this case: user, jobid, elapsed time, etc.).

Some fields may be blank until accounting is collected or the job finishes. Use these values to guide resource requests rather than assuming every field is a whole-job total.

> 💡 **TIP:** You can adjust column widths with % (e.g., reqtres%50) to fit long text values.

**View the batch script for a job:**

```bash
sacct -j <job_id> -B
```

## Checking Job Details with `scontrol`

`scontrol` is used to view or modify Slurm configuration including: job, job step, node, partition, time, reservation, and overall system configuration. *While most of the commands can only be executed by the root user or an administrator, users can still use it to inspect their own jobs.* See the [scontrol manual](https://slurm.schedmd.com/scontrol.html) for a full list of format options.

**Check details for a running job (e.g., resources requested, working directory, command, and I/O paths)**

```bash
scontrol show job <job_id>
```

Inspect `Account`, `Partition`, `JobState`, `Reason`, `NumCPUs`, `ReqTRES`, `WorkDir`, and output/error paths. This is useful for finding incorrect resource requests or a wrong submission directory. For finished jobs no longer retained by `scontrol`, use `sacct`.

## Evaluating Job Efficiency with `seff`

Where available, `seff <job_id>` summarizes CPU and memory efficiency for completed jobs. It helps identify jobs that used significantly less CPU time or host memory than requested — an opportunity to optimize future runs.

Alternatively, you can always inspect `TotalCPU`, `Elapsed`, `AllocCPUS`, and step memory statistics with `sacct`:

```bash
sacct -j <job_id> -o JobID,State,Elapsed,TotalCPU,AllocCPUS,MaxRSS,ReqMem,ExitCode
```

Omit `-X` to include job steps, where memory statistics are often recorded.

These CPU and host-memory statistics do not measure GPU utilization. During a GPU allocation, use `nvidia-smi` on the allocated compute node to inspect GPU memory and activity. Request GPUs only for code that uses them, and use application timings/profiling for meaningful performance comparisons.

> 💡 **TIP:** Requesting more resources (memory, number of CPUs/GPUs) than your job actually needs can lead to longer queue times and reduced cluster efficiency.

## Storage Usage

```bash
hyakstorage
```

This reports home and group storage quotas, rather than compute allocation. See [Storage on Klone](https://hyak.uw.edu/docs/systems/klone/storage/) for details. Preserve important results outside scrubbed storage before its automatic deletion policy applies.

For local command help, run `man sacct` or `man scontrol` on Klone; press `q` to exit.
