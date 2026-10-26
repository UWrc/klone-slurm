import sys
import time

print("Starting Klone Python demo job...")
print(f"Python version: {sys.version.split()[0]}")

print("Checking CUDA availability...")
try:
    import torch
    if torch.cuda.is_available():
        print(f"GPU detected: {torch.cuda.get_device_name(0)}")
    else:
        print("No GPU detected (CUDA not available).")
except ImportError:
    print("PyTorch not installed; skipping GPU check.")

time.sleep(2)
print("Job completed successfully.")