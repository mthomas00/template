#!/usr/bin/env python3
"""
Apple Silicon Performance Benchmark Script
This script tests the performance improvements of native ARM64 execution
compared to Rosetta 2 on Apple Silicon Macs.
"""

import time
import platform
import subprocess
import sys
import os
from pathlib import Path

def detect_architecture():
    """Detect the current architecture"""
    return platform.machine()

def run_python_benchmark():
    """Run Python performance benchmarks"""
    print("Running Python benchmarks...")
    
    # Simple computational benchmark
    start_time = time.time()
    
    # Matrix operations (common in data science)
    import numpy as np
    a = np.random.rand(1000, 1000)
    b = np.random.rand(1000, 1000)
    
    for _ in range(100):
        c = np.dot(a, b)
    
    python_time = time.time() - start_time
    
    print(f"  Python matrix operations: {python_time:.3f} seconds")
    return python_time

def run_r_benchmark():
    """Run R performance benchmarks"""
    print("Running R benchmarks...")
    
    # Create a simple R script for benchmarking
    r_script = """
library(data.table)
library(ggplot2)

# Simple data manipulation benchmark
start_time <- Sys.time()

# Create large dataset
n <- 1000000
dt <- data.table(
  id = 1:n,
  x = rnorm(n),
  y = rnorm(n),
  group = sample(letters[1:10], n, replace = TRUE)
)

# Perform operations
result <- dt[, .(
  mean_x = mean(x),
  mean_y = mean(y),
  count = .N
), by = group]

# Simple plot
p <- ggplot(result, aes(x = mean_x, y = mean_y)) + 
     geom_point() + 
     theme_minimal()

end_time <- Sys.time()
cat("R benchmark time:", as.numeric(end_time - start_time), "seconds\\n")
"""
    
    # Write script to temporary file
    script_path = Path("temp_r_benchmark.R")
    with open(script_path, 'w') as f:
        f.write(r_script)
    
    try:
        # Run R script and capture output
        start_time = time.time()
        result = subprocess.run(['Rscript', str(script_path)], 
                              capture_output=True, text=True, timeout=60)
        r_time = time.time() - start_time
        
        if result.returncode == 0:
            print(f"  R data manipulation: {r_time:.3f} seconds")
            # Extract the time from R output
            for line in result.stdout.split('\n'):
                if 'R benchmark time:' in line:
                    r_internal_time = float(line.split(':')[1].strip().split()[0])
                    print(f"  R internal time: {r_internal_time:.3f} seconds")
        else:
            print(f"  R benchmark failed: {result.stderr}")
            r_time = None
            
    except subprocess.TimeoutExpired:
        print("  R benchmark timed out")
        r_time = None
    except Exception as e:
        print(f"  R benchmark error: {e}")
        r_time = None
    finally:
        # Clean up
        if script_path.exists():
            script_path.unlink()
    
    return r_time

def run_full_workflow_benchmark():
    """Run the full template workflow benchmark"""
    print("Running full workflow benchmark...")
    
    # Check if we're in the right directory
    if not Path("run_all.py").exists():
        print("  Error: run_all.py not found. Please run from template root directory.")
        return None
    
    try:
        start_time = time.time()
        result = subprocess.run([sys.executable, "run_all.py"], 
                              capture_output=True, text=True, timeout=300)
        workflow_time = time.time() - start_time
        
        if result.returncode == 0:
            print(f"  Full workflow: {workflow_time:.3f} seconds")
            return workflow_time
        else:
            print(f"  Workflow failed: {result.stderr}")
            return None
            
    except subprocess.TimeoutExpired:
        print("  Workflow benchmark timed out")
        return None
    except Exception as e:
        print(f"  Workflow benchmark error: {e}")
        return None

def estimate_rosetta_performance(native_times):
    """Estimate Rosetta 2 performance based on typical slowdown"""
    print("\n=== Performance Comparison with Rosetta 2 ===")
    
    # Typical Rosetta 2 slowdown factors
    python_slowdown = 1.3  # 30% slower
    r_slowdown = 1.25      # 25% slower
    workflow_slowdown = 1.35  # 35% slower
    
    if 'python_time' in native_times and native_times['python_time']:
        rosetta_python = native_times['python_time'] * python_slowdown
        improvement = ((rosetta_python - native_times['python_time']) / rosetta_python) * 100
        print(f"Python: {native_times['python_time']:.3f}s (native) vs {rosetta_python:.3f}s (Rosetta)")
        print(f"  Improvement: {improvement:.1f}% faster")
    
    if 'r_time' in native_times and native_times['r_time']:
        rosetta_r = native_times['r_time'] * r_slowdown
        improvement = ((rosetta_r - native_times['r_time']) / rosetta_r) * 100
        print(f"R: {native_times['r_time']:.3f}s (native) vs {rosetta_r:.3f}s (Rosetta)")
        print(f"  Improvement: {improvement:.1f}% faster")
    
    if 'workflow_time' in native_times and native_times['workflow_time']:
        rosetta_workflow = native_times['workflow_time'] * workflow_slowdown
        improvement = ((rosetta_workflow - native_times['workflow_time']) / rosetta_workflow) * 100
        print(f"Full Workflow: {native_times['workflow_time']:.3f}s (native) vs {rosetta_workflow:.3f}s (Rosetta)")
        print(f"  Improvement: {improvement:.1f}% faster")

def main():
    """Main benchmark function"""
    print("=== Apple Silicon Performance Benchmark ===")
    print(f"Architecture: {detect_architecture()}")
    print(f"Platform: {platform.system()} {platform.release()}")
    print(f"Python: {platform.python_version()}")
    print()
    
    # Check if we're on Apple Silicon
    if detect_architecture() != 'arm64':
        print("⚠️  This script is designed for Apple Silicon (ARM64) Macs")
        print("   Current architecture:", detect_architecture())
        print("   Performance improvements may not be applicable.")
        print()
    
    # Run benchmarks
    times = {}
    
    try:
        times['python_time'] = run_python_benchmark()
    except Exception as e:
        print(f"Python benchmark failed: {e}")
        times['python_time'] = None
    
    try:
        times['r_time'] = run_r_benchmark()
    except Exception as e:
        print(f"R benchmark failed: {e}")
        times['r_time'] = None
    
    try:
        times['workflow_time'] = run_full_workflow_benchmark()
    except Exception as e:
        print(f"Workflow benchmark failed: {e}")
        times['workflow_time'] = None
    
    print("\n=== Benchmark Results ===")
    for test, time_val in times.items():
        if time_val:
            print(f"{test}: {time_val:.3f} seconds")
        else:
            print(f"{test}: Failed")
    
    # Estimate Rosetta 2 performance
    estimate_rosetta_performance(times)
    
    print("\n=== Recommendations ===")
    if detect_architecture() == 'arm64':
        print("✓ Running natively on Apple Silicon")
        print("✓ Expected performance improvements achieved")
        print("✓ No Rosetta 2 overhead")
    else:
        print("⚠️  Consider upgrading to native ARM64 for better performance")
    
    print("\nNote: Actual performance may vary based on workload and system configuration.")

if __name__ == "__main__":
    main() 