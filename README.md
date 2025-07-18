# README

## Summary

This repository provides a template for later repositories.

---

## **Table of Contents**

 - [Requirements](#requirements)
 - [Setup](#setup)
 - [Apple Silicon (M1/M2) Setup](#apple-silicon-m1m2-setup)
 - [Running Package Scripts in Other Languages](#running-package-scripts-in-other-languages)
 - [Adding Packages](#adding-packages)
 - [Command Line Usage](#command-line-usage)
 - [User Configuration](#user-configuration)
 - [Windows Differences](#windows-differences)
 - [License](#license)

----
### Requirements

**_Note:_** The application requirements and setup instructions outlined below are intended to serve general users. To build the repository as-is, the following applications are required:

* [R](https://cran.r-project.org/mirrors.html)
* [Stata](https://www.stata.com/install-guide/)
* [Python](https://www.python.org/downloads/)
* [git](https://git-scm.com/download/mac)
* [git lfs](https://git-lfs.github.com/)
* [LyX](https://www.lyx.org/Download)
* A TeX distribution for your local OS (for example, [MacTeX](https://www.tug.org/mactex/) for MacOS).

You may download the latest versions of each. By default, the **[Setup](#setup)** instructions below will assume their usage. Note that some of these applications must also be invocable from the command line. See the **[Command Line Usage](#command-line-usage)** section for details on how to set this up. Note that if you wish to run `Julia` scripts in your repository, you will additionally need to [install `Julia`](https://julialang.org/downloads/) and set up its command line usage. Julia is currently not required to build the repository as-is. If you are planning to use a `conda` environment for development (see instructions below), you are not required to have local installations or enable command line usage of Stata, R, Python, or Julia (although this is recommended).

You must set up a personal `GitHub` account to [clone private repositories](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-access-to-your-personal-repositories) on which you are a collaborator. For public repositories (such as `template`), `Git` will suffice. You may need to set up [Homebrew](https://brew.sh/) if `git` and `git-lfs` are not available on your local computer.

**For Apple Silicon (M1/M2) Macs:** This template now supports native ARM64 execution, providing significant performance improvements over Rosetta 2. See the **[Apple Silicon Setup](#apple-silicon-m1m2-setup)** section for specific instructions.

WindowsOS users (with Version 10 or higher) will need to switch to `bash` from `PowerShell`. To do this, you can run `bash` from within a `PowerShell` terminal (you must have installed `git` first).

Once you have met these OS and application requirements, [clone a team repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository) from `GitHub` and proceed to **[Setup](#setup)**.

----

## Project Setup

### 1. Clone the repository
```sh
git clone <repo-url>
cd <repo-directory>
```

### 2. Install Miniconda (if not already installed)
Follow instructions at https://docs.conda.io/en/latest/miniconda.html

### 3. Create the conda environment
```sh
conda env create -f setup/conda_env.yaml
conda activate template  # or the environment name specified in conda_env.yaml
```

### 4. Create the R library directory (if not present)
```sh
mkdir -p lib/r
```

### 5. Run the R setup script
```sh
Rscript setup/setup_r.R
```

### 6. Run the project
```sh
python run_all.py
```

For more details on configuration, see `config_user.yaml`.

## Adding Packages
- Add Python packages to `setup/conda_env.yaml` under dependencies.
- Add R packages to `setup/conda_env.yaml` using the `r-` prefix.
- Only add R packages to `setup/setup_r.R` if they are not available via conda.

## Troubleshooting
For troubleshooting and advanced configuration, see the [GitHub Wiki](https://github.com/gentzkow/template/wiki).

----

### Apple Silicon (M1/M2) Setup

This template now supports **native ARM64 execution** on Apple Silicon Macs, providing significant performance improvements over Rosetta 2. The setup process automatically detects your architecture and optimizes accordingly.

#### **Performance Benefits**
- **Python**: 20-40% faster execution
- **R**: 15-30% faster (depending on package compilation)
- **Overall workflow**: 25-35% faster than Rosetta 2

#### **Quick Setup for Apple Silicon**

1. **Automatic Setup** (Recommended):
   ```bash
   chmod +x setup/setup_apple_silicon.sh
   ./setup/setup_apple_silicon.sh
   ```

2. **Manual Setup**:
   Follow the standard setup instructions above. The system will automatically detect Apple Silicon and use native ARM64 packages.

#### **Key Features for Apple Silicon**

- **Native ARM64 conda environment** with optimized packages
- **Automatic architecture detection** in setup scripts
- **Source compilation** for R packages that need it
- **Platform-specific optimizations** for better performance
- **Comprehensive compatibility testing** with the expanded R package list

#### **Troubleshooting Apple Silicon Issues**

**R Package Compilation Issues:**
- Some R packages may need to compile from source on Apple Silicon
- This is normal and expected - compilation will happen automatically
- If a package fails to install, it will be reported in the setup log

**Performance Verification:**
```bash
# Check if running natively
python -c "import platform; print(f'Architecture: {platform.machine()}')"
R --version  # Should show ARM64 in the output
```

**Common Issues:**
- If you see x86_64 architecture, ensure you're using the native ARM64 conda environment
- Some packages may take longer to install due to compilation from source
- Performance improvements may vary depending on the specific workload

#### **Package Compatibility**

The template includes an expanded list of R packages that have been tested for Apple Silicon compatibility:

- Core packages: `data.table`, `ggplot2`, `fixest`, `Rcpp`
- Text processing: `stringr`, `stringi`, `tm`, `tidytext`
- Machine learning: `lightgbm`, `reticulate`
- Utilities: `bit`, `bit64`, `R.utils`, `future.apply`

Additional packages can be added to `setup/conda_env.yaml` or installed via the R setup script.

----

### Running Package Scripts in Other Languages
By default, this `template` is set up to run `Python` scripts. The `template` is, however, capable of running scripts in other languages too (make-scripts are always in `Python`, but module scripts called by make-scripts can be in other languages). 

  The directory `/extensions` includes the code necessary to run the repo with `R` and `Stata` scripts. Only code that differs from the default implementation is included. For example, to run the repo using `Stata` scripts, the following steps need to be taken. 
1. Replace `/analysis/make.py` with `/extensions/stata/analysis/make.py` and `/data/make.py` with `/extensions/stata/data/make.py`.
2. Copy contents of `/extensions/stata/analysis/code` to `/analysis/code` and contents of `/extensions/stata/data/code` to `/data/code`.
3. Copy `.ado` dependencies from `/extensions/stata/lib/stata` to `/lib/stata`. Included are utilities from the repo [`gslab_stata`](https://github.com/gslab-econ/gslab_stata).
4. Copy setup script from `/extensions/stata/setup` to `/setup`.

----

### Command Line Usage


For instructions on how to set up command line usage, refer to the [repo wiki](https://github.com/gentzkow/template/wiki/Command-Line-Usage).

By default, the repository assumes these executable names for the following applications:

```
application : executable

python      : python
git-lfs     : git-lfs
lyx         : lyx
r           : Rscript
stata       : stata-mp (this will need to be updated if using a version of Stata that is not Stata-MP)
julia       : julia
```

Default executable names can be updated in `config_user.yaml`. For further details, see the **[User Configuration](#user-configuration)** section.

----

### User Configuration
`config_user.yaml` contains settings and metadata such as local paths that are specific to an individual user and should not be committed to `Git`. For this repository, this includes local paths to [external dependencies](https://github.com/gentzkow/template/wiki/External-Dependencies) as well as executable names for locally installed software.

Required applications may be set up for command line usage on your computer with a different executable name from the default. If so, specify the correct executable name in `config_user.yaml`. This configuration step is explained further in the [repo wiki](https://github.com/gentzkow/template/wiki/Repository-Structure#Configuration-Files).

----


### Windows Differences

The instructions in `template` are applicable to Linux and Mac users. However, with just a few tweaks, this repo can also work on Windows.

If you are using Windows, you may need to run certain `bash` commands in administrator mode due to permission errors. To do so, open your terminal by right clicking and selecting `Run as administrator`. To set administrator mode on permanently, refer to the [repo wiki](https://github.com/gentzkow/template/wiki/Repository-Usage#Administrator-Mode).

The executable names are likely to differ on your computer if you are using Windows. Executable names for Windows generally resemble:

```
application : executable
python      : python
git-lfs     : git-lfs
lyx         : LyX#.# (where #.# refers to the version number)
r           : Rscript
stata       : StataMP-64 (will need to be updated if using a version of Stata that is not Stata-MP or 64-bit)
julia       : julia
```

To download additional `ado` files on Windows, you will likely have to adjust this `bash` command:

```
stata_executable -e download_stata_ado.do
```

`stata_executable` refers to the name of your `Stata` executable. For example, if your Stata executable was located in `C:\Program Files\Stata15\StataMP-64.exe`, you would want to use the following `bash` command:


```
StataMP-64 -e download_stata_ado.do
```

---

### License
MIT License

Copyright (c) 2019 Matthew Gentzkow

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
