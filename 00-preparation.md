# Preparation

You need an active Klone account and an SSH client (Terminal on macOS/Linux or PowerShell on Windows).

## Log in to Klone

Connect to Klone via SSH from your SSH client:

```bash
ssh UWNetID@klone.hyak.uw.edu
```

Replace `UWNetID` with your UW NetID.

You will land on a shared login node, such as:

```
[UWNetID@klone-login01 ~]$ 
```

Use login nodes to navigate files, transfer data, and prepare or submit jobs. Run computations and load software modules only after obtaining a compute node.

## Create Your Working Directory

The filesystem on Klone uses `/gscratch` (also accessible as `/mmfs1/gscratch`). For this tutorial, use Klone's free community storage **`/gscratch/scrubbed`**, rather than your Home directory which only has a 10 GB quota. Scrubbed files are automatically deleted after 21 days of inactivity. See [Storage on Klone](https://hyak.uw.edu/docs/systems/klone/storage/) to learn more about storage on Klone.

**1. Create your own directory under `/gscratch/scrubbed`**

```bash
mkdir -p /gscratch/scrubbed/$USER
```

**2. Navigate to your scrubbed directory**

```bash
cd /gscratch/scrubbed/$USER
```

> 📝 **NOTE:** The `$USER` variable automatically expands to your username.

**3. Clone the training repository**

```bash
git clone https://github.com/UWrc/klone-slurm.git
```

Once cloned, you’ll have a directory named klone-slurm containing all tutorial scripts and examples.

**4. Navigate into it and create `logs/` for output files**

```bash
cd klone-slurm
mkdir -p logs
```

List the contents in the directory:

```bash
ls
```
