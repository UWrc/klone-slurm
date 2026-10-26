#!/usr/bin/env python3
"""
Example script for running multiple PyTorch tasks in parallel using Slurm array jobs on Klone.
"""

import os
import time
import torch

def main():
    # Get SLURM array task ID
    task_id = int(os.getenv("SLURM_ARRAY_TASK_ID", 0))

    # Learning rates are labels for a parameter-sweep pattern; no model is trained.
    learning_rates = [1e-4, 3e-4, 1e-3, 3e-3, 1e-2]
    lr = learning_rates[task_id % len(learning_rates)]

    print(f"Starting PyTorch Array Task {task_id}")
    print(f"Learning rate: {lr}")

    print(f"Hostname: {os.uname().nodename}")
    print(f"PyTorch version: {torch.__version__}")
    print(f"CUDA available: {torch.cuda.is_available()}")
    torch.set_num_threads(int(os.getenv("SLURM_CPUS_PER_TASK", "1")))

    if torch.cuda.is_available():
        device = torch.device("cuda")
        print(f"GPU detected: {torch.cuda.get_device_name(0)}")
    else:
        raise RuntimeError("CUDA is unavailable. Check the GPU allocation, --nv, and container compatibility.")

    # Simulated computation
    start = time.time()
    x = torch.rand((4096, 4096), device=device)
    y = torch.mm(x, x)
    torch.cuda.synchronize() if torch.cuda.is_available() else None
    elapsed = time.time() - start

    checksum = float(y.sum().item())
    print(f"\nComputation complete! Result checksum: {checksum:.3e}")
    print(f"Elapsed time: {elapsed:.2f} seconds\n")

    # Save results
    os.makedirs("logs", exist_ok=True)
    job_id = os.getenv("SLURM_ARRAY_JOB_ID", os.getenv("SLURM_JOB_ID", "local"))
    result_path = f"logs/results_{job_id}_task_{task_id}.txt"
    with open(result_path, "w") as f:
        f.write(f"Task {task_id}\nLearning rate: {lr}\nTime: {elapsed:.2f}s\nChecksum: {checksum:.3e}\n")

    print(f"Results saved to {result_path}")

if __name__ == "__main__":
    main()