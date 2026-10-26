# Preparation

You need an active Klone account and an SSH client (Terminal on macOS/Linux or PowerShell on Windows).

## Log in to Klone

Replace `UWNetID` with your UW NetID:

```bash
ssh UWNetID@klone.hyak.uw.edu
```

You will land on a shared login node, such as `klone-login01`. Use login nodes to navigate files, transfer data, and prepare or submit jobs. Run computations and load software modules only after obtaining a compute node.

## Create Your Working Directory

Klone uses `/gscratch` (also accessible as `/mmfs1/gscratch`). For this tutorial, use the temporary community space `/gscratch/scrubbed`, or a directory in your group's project space.

Home directories have a 10 GB quota. Scrubbed files are automatically deleted after 21 days of inactivity, and Klone storage is not backed up. Copy results you need to keep to an appropriate external location. See [Storage on Klone](https://hyak.uw.edu/docs/systems/klone/storage/).

```bash
mkdir -p "/gscratch/scrubbed/$USER"
cd "/gscratch/scrubbed/$USER"
git clone https://github.com/UWrc/klone-slurm.git
cd klone-slurm
mkdir -p logs
ls
```

`$USER` expands to your username. **Create `logs/` before submitting any job that writes there.** Slurm opens output files before the script runs; it does not create missing parent directories.

## Identify Your Account and Partitions

```bash
hyakalloc
sinfo -s
```

`hyakalloc` shows your accounts, contributed resources, and utilization. An account is your lab/group allocation; a partition is a pool of hardware. Seeing a partition in `sinfo` does not mean your account has priority access to it.

Set the following to an actual account from `hyakalloc`, or the account provided by your instructor:

```bash
# Replace mylab with your actual account name.
export MY_ACCOUNT=mylab
```

Use `--account="$MY_ACCOUNT"` in the tutorial commands. Set it again if you open a new login shell. The example scripts use `ckpt-all` for idle resources; these jobs may wait or be preempted. If your account has a suitable priority partition, override the script default at submission:

```bash
# Example only: use compute only if hyakalloc lists it for your account.
sbatch --account="$MY_ACCOUNT" --partition=compute job.slurm
```

Always submit from the `klone-slurm` directory so relative script and log paths resolve correctly.
