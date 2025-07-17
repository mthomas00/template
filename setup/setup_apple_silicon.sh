#!/bin/bash

# Apple Silicon Setup Script for template repository
# This script sets up the environment for native Apple Silicon (ARM64) execution

set -e  # Exit on any error

echo "=== Apple Silicon Setup for template repository ==="
echo "Detected architecture: $(uname -m)"
echo "Detected OS: $(uname -s)"

# Check if running on Apple Silicon
if [[ $(uname -m) == "arm64" && $(uname -s) == "Darwin" ]]; then
    echo "✓ Confirmed Apple Silicon (ARM64) Mac"
else
    echo "⚠️  This script is designed for Apple Silicon Macs"
    echo "   Current system: $(uname -m) on $(uname -s)"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if conda is installed
if ! command -v conda &> /dev/null; then
    echo "❌ Conda not found. Please install miniconda first:"
    echo "   brew install --cask miniconda"
    exit 1
fi

echo "✓ Conda found: $(conda --version)"

# Check if conda environment exists
ENV_NAME="template"
if conda env list | grep -q "^$ENV_NAME "; then
    echo "⚠️  Environment '$ENV_NAME' already exists"
    read -p "Remove existing environment and recreate? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing existing environment..."
        conda env remove -n $ENV_NAME
    else
        echo "Using existing environment. You may need to update packages manually."
    fi
fi

# Create conda environment with Apple Silicon optimizations
echo "Creating conda environment for Apple Silicon..."
conda env create -f conda_env.yaml

# Activate environment
echo "Activating conda environment..."
source $(conda info --base)/etc/profile.d/conda.sh
conda activate $ENV_NAME

# Verify Python architecture
echo "Verifying Python architecture..."
python -c "import platform; print(f'Python architecture: {platform.machine()}')"

# Install R packages with Apple Silicon support
echo "Installing R packages for Apple Silicon..."
R CMD BATCH --no-save ./setup_r.R ./setup_r.Rout

# Check for any installation errors
if [ -f setup_r.Rout ]; then
    echo "R installation log:"
    tail -20 setup_r.Rout
fi

# Create platform-specific configuration
echo "Creating Apple Silicon configuration..."
cat > config_apple_silicon.yaml << EOF
# Apple Silicon specific configuration
platform:
  architecture: arm64
  os: darwin
  native: true

# Optimizations for Apple Silicon
optimizations:
  r_compiler_flags: "-O3 -march=native"
  python_optimizations: true
  use_metal: false  # Set to true if using Metal for GPU acceleration

# Package sources optimized for ARM64
package_sources:
  r_cran: "https://cran.rstudio.com/"
  conda_channel: "conda-forge"
EOF

echo "✓ Apple Silicon setup complete!"
echo ""
echo "Next steps:"
echo "1. Activate the environment: conda activate $ENV_NAME"
echo "2. Run the project: python run_all.py"
echo "3. Check performance improvements compared to Rosetta 2"
echo ""
echo "Note: Some R packages may still require compilation from source"
echo "      on Apple Silicon. This is normal and expected." 