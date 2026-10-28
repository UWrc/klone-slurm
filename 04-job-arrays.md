# Parallel Computing with Array Jobs

Running multiple independent tasks in parallel is a core strength of HPC systems like Klone. Slurm provides built-in mechanisms for parallel execution, from **job arrays** for parameter sweeps to **distributed jobs** using MPI.

In this section, we’ll work through a complete example using Slurm job arrays. Harnessing the power of parallel computing allows you to efficiently launch and manage many similar jobs - such as processing multiple input files, training several models, or running parameter scans - in a single submission. The script presented can be used as a template and adapted for your purposes.

## Array Job

An array job is a convenient way to run the same command multiple times with different parameters or inputs.
This is common when testing different configurations in simulations, running analyses across datasets, or performing parameter sweeps in ML training.

Let's run an array job with `loop_array.slurm` in your working directory.

Submit from the repository directory on the login node. This is CPU-only work, so each task requests one CPU and no GPUs. Runtime varies by node.

## Example Slurm Script for Array Job

Open the example script `loop_array.slurm`:

```bash
nano loop_array.slurm
```

```bash
#!/bin/bash

#SBATCH --job-name=loop_array
#SBATCH --account=uwit
#SBATCH --partition=compute
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:05:00
#SBATCH --array=0-9
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
```

**Explanation:**
- `#SBATCH --array=0-9`: Creates an array of 10 tasks (IDs 0 through 9). Each runs the same script with different input values determined by the variables independently.
- `#SBATCH --output=logs/%x_%A_%a.out`: Saves output to the `logs` directory. `%x`, `%A`, and `%a` expand to the job name, job ID, and Slurm Array Task ID. <br> The directory will be created automatically if it does not exist already.
- `COUNT`, `START`, and `END`: Define the number of iterations and the range for each task.
- `SLURM_ARRAY_TASK_ID`: Slurm environment variable that uniquely identifies each array task (0-9 here).
- `time ./loop_script.sh ${START} ${END}`: Runs the counting script `loop_script.sh`. The two arguments accepted (starting and ending value to count) are now two variables `START` and `END`.

**How the variables work**

Each job in the array will have a different `SLURM_ARRAY_TASK_ID` set by `#SBATCH --array=0-9`.
Using this value, the script calculates distinct numeric ranges so each job processes a separate portion of the total task.
For the first job, `SLURM_ARRAY_TASK_ID` equals 0 and `COUNT` equals 5,000,000 so `START` equals 0 (i.e., 0 * 5000000). `END` for the first job equals 4,999,999 or (0 + 5000000 - 1).
For the second job, `SLURM_ARRAY_TASK_ID` equals 1 so `START` equals 5,000,000 and `END` equals 9,999,999. And so on.
The table below shows the variables `SLURM_ARRAY_TASK_ID`, `START`, and `END` for each job in the array.

| SLURM_ARRAY_TASK_ID | START | END |
| :- | -: | -: |
| 0 | 0 | 4,999,999 |
| 1 |  5,000,000 |  9,999,999 |
| 2 | 10,000,000 | 14,999,999 |
| 3 | 15,000,000 | 19,999,999 |
| 4 | 20,000,000 | 24,999,999 |
| 5 | 25,000,000 | 29,999,999 |
| 6 | 30,000,000 | 34,999,999 |
| 7 | 35,000,000 | 39,999,999 |
| 8 | 40,000,000 | 44,999,999 |
| 9 | 45,000,000 | 49,999,999 |

Thus, each job in `loop_array.slurm` executes `loop_script.sh` on a different, non-overlapping range of numbers.

> 💡 **TIP:** `$SLURM_ARRAY_TASK_ID` can also be used to select different input files or parameters, and to perform parameter sweeps. Always confirm your array indices (0-based vs 1-based) match your input list size.

## Submitting and Monitoring the Array Job

Exit the text editor with `Ctrl+X` and submit your array job:

```bash
sbatch loop_array.slurm
```

Monitor progress:

```bash
watch -n 10 squeue -u $USER
```

Once complete, you'll have 10 output files in the `logs` directory. Check the output files:

```bash
ls logs/
```

You should see 10 output files similar to (but with 123456789 replaced by the JobID assigned to your array job when it was submitted):

```bash
loop_array_123456789_0.out  loop_array_123456789_1.out  loop_array_123456789_2.out
loop_array_123456789_3.out  loop_array_123456789_4.out  loop_array_123456789_5.out
loop_array_123456789_6.out  loop_array_123456789_7.out  loop_array_123456789_8.out
loop_array_123456789_9.out
```

Each file contains the output for one array task.

## Controlling Parallelism

If you have a large array, you may not want all tasks running at once. You can use the % separator to cap how many array tasks run concurrently:

```bash
#SBATCH --array=0-9%5
```

This runs 10 tasks total but limits to 5 simultaneous jobs. As each task finishes, a new one starts automatically.

## Summary

This exercise demonstrates how to:

* Submit and manage array jobs in Slurm.
* Use Bash variables to define dynamic arguments for commands.
* Use Slurm environment variable `SLURM_ARRAY_TASK_ID` to uniquely identify and configure each task.

Leveraging these techniques helps automate large-scale testing, parameter sweeps, and dataset processing for research computing projects. To learn more about Slurm’s environment variables, see the [**Slurm output environment variables documentation**](https://slurm.schedmd.com/sbatch.html#SECTION_OUTPUT-ENVIRONMENT-VARIABLES).

> 💬 **Feedback Welcome:**
> We hope this tutorial helps you design more efficient and scalable workflows on Klone. If you have any questions or suggestions for how to improve this tutorial, please email **\<help@uw.edu\>** with "Klone Slurm Tutorial" in the subject line, and let us know what you think. Thank you!
