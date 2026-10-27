#!/usr/bin/env python3
"""
Example script for running a single GPU computation with PyTorch on Klone.
"""

import os
import time
import torch

def main():
    print("Starting PyTorch GPU demo job...")

    print(f"Hostname: {os.uname().nodename}")
    print(f"PyTorch version: {torch.__version__}")
    print(f"CUDA available: {torch.cuda.is_available()}")
    torch.set_num_threads(int(os.getenv("SLURM_CPUS_PER_TASK", "1")))

    if torch.cuda.is_available():
        device = torch.device("cuda")
        print(f"GPU detected: {torch.cuda.get_device_name(0)}")
    else:
        raise RuntimeError("CUDA is unavailable. Check the GPU allocation and the trainingslurm Conda environment.")

    # Simulated computation
    start = time.time()
    x = torch.rand((4096, 4096), device=device)
    y = torch.mm(x, x)
    torch.cuda.synchronize()
    elapsed = time.time() - start

    checksum = float(y.sum().item())
    print(f"\nComputation complete! Result checksum: {checksum:.3e}")
    print(f"Elapsed time: {elapsed:.2f} seconds\n")

    # Save results
    os.makedirs("logs", exist_ok=True)
    job_id = os.getenv("SLURM_JOB_ID", "local")
    result_path = f"logs/results_{job_id}.txt"
    with open(result_path, "w") as f:
        f.write(f"Job {job_id}\nTime: {elapsed:.2f}s\nChecksum: {checksum:.3e}\n")

    print(f"Results saved to {result_path}")

if __name__ == "__main__":
    main()
