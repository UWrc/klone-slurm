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

Review your jobs since a chosen date (replace the date as needed):

```bash
sacct -u "$USER" -S 2026-10-01 -X -o JobID,JobName,Partition,Account,State,Elapsed,AllocCPUS,ReqMem,ExitCode
```

`-X` shows allocation summaries. Omit it to include job steps, where memory statistics are often recorded. For a completed job:

```bash
sacct -j <job_id> -o JobID,JobName,State,Elapsed,TotalCPU,MaxRSS,ReqMem,ExitCode
```

`MaxRSS` is the maximum resident memory reported for a task in a job step; it is not necessarily the total peak memory across all tasks. Some fields may be blank until accounting is collected or the job finishes. Use these values to guide resource requests rather than assuming every field is a whole-job total. See the [sacct manual](https://slurm.schedmd.com/sacct.html).

## Inspect Job Details with `scontrol`

```bash
scontrol show job <job_id>
```

Inspect `Account`, `Partition`, `JobState`, `Reason`, `NumCPUs`, `ReqTRES`, `WorkDir`, and output/error paths. This is useful for finding incorrect resource requests or a wrong submission directory. For finished jobs no longer retained by `scontrol`, use `sacct`.

## Running-Job Statistics with `sstat`

```bash
sstat -j <job_id>.batch --format=JobID,AveCPU,MaxRSS,AveRSS
```

This examines the batch step. For work launched through `srun`, inspect the corresponding step ID instead. Statistics depend on the cluster's accounting configuration and sampling interval. See the [sstat manual](https://slurm.schedmd.com/sstat.html).

## Efficiency of Completed Jobs

Where available, `seff <job_id>` summarizes CPU and memory efficiency. You can always inspect `TotalCPU`, `Elapsed`, `AllocCPUS`, and step memory statistics with `sacct` as above.

CPU efficiency compares consumed CPU time with allocated cores × elapsed time. A serial program requesting many cores often has low CPU efficiency. A sleeping demonstration job will also have low efficiency by design. Memory statistics help size `--mem` for future jobs with some headroom.

These CPU and host-memory statistics do not measure GPU utilization. During a GPU allocation, use `nvidia-smi` on the allocated compute node to inspect GPU memory and activity:

```bash
watch -n 5 nvidia-smi
```

Stop watching with `Ctrl+C`. Request GPUs only for code that uses them, and use application timings/profiling for meaningful performance comparisons.

## Storage Usage

```bash
hyakstorage
```

This reports home and group storage quotas, rather than compute allocation. See [Storage on Klone](https://hyak.uw.edu/docs/systems/klone/storage/) for details. Preserve important results outside scrubbed storage before its automatic deletion policy applies.

For local command help, run `man sacct`, `man scontrol`, or `man sstat` on Klone; press `q` to exit.
