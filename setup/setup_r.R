.libPaths('') # Cleanup any additional paths the user might have
.libPaths('../lib/R') # Packages will be installed in this location

main <- function() {
  .libPaths('') # Cleanup any additional paths the user might have
  .libPaths('../lib/r') # Packages will be installed in this location
  
  # Detect Apple Silicon
  is_apple_silicon <- Sys.info()["machine"] == "arm64" && Sys.info()["sysname"] == "Darwin"
  
  if (is_apple_silicon) {
    cat("Detected Apple Silicon (ARM64) - using native installation\n")
    # Use CRAN mirror that supports ARM64
    repos <- "https://cran.rstudio.com/"
  } else {
    cat("Detected x86_64 architecture - using standard installation\n")
    repos <- "https://cran.csie.ntu.edu.tw/"
  }
  
  # List of CRAN packages to install
  CRAN_packages <- c(
    "data.table", "Rcpp", "fst", "ggplot2", "fixest", "zoo", "stringr", "readxl", 
    "fwildclusterboot", "RcppRoll", "future", "forestplot", "tidyr", "RcppEigen",
    "future.apply", "rlang", "vctrs", "glue", "magrittr", "cli", "fansi", "utf8", 
    "tibble", "purrr", "dplyr", "colorspace", "backports", "lazyeval", "stringi",
    "bit", "bit64", "R.utils", "readr", "R.methodsS3", "R.oo", "fastcluster",
    "reticulate", "lfe", "lightgbm", "sentimentr", "scales", "plyr", "tm", 
    "SnowballC", "textshape", "snakecase", "tidytext"
  )
  
  # Install packages with platform-specific options
  if (is_apple_silicon) {
    # For Apple Silicon, install with specific options
    install.packages(CRAN_packages, 
                     repos = repos,
                     dependencies = TRUE, 
                     lib = '../lib/r',
                     type = "source") # Use source installation for better ARM64 compatibility
  } else {
    # Standard installation for x86_64
    install.packages(CRAN_packages, 
                     repos = repos,
                     dependencies = TRUE, 
                     lib = '../lib/r')
  }
  
  # Install GitHub packages
  if (!require(remotes, quietly = TRUE)) {
    install.packages("remotes", repos = repos, lib = '../lib/r')
  }
  library(remotes)
  
  # Install GitHub packages with platform detection
  tryCatch({
    install_github("NightingaleHealth/ggforestplot", force = TRUE, lib = '../lib/r')
  }, error = function(e) {
    cat("Warning: Could not install ggforestplot from GitHub. This may be due to platform compatibility.\n")
    cat("Error:", e$message, "\n")
  })
}

main()

# Print session info for debugging
cat("\n=== R Session Info ===\n")
cat("Platform:", R.version$platform, "\n")
cat("Architecture:", Sys.info()["machine"], "\n")
cat("Operating System:", Sys.info()["sysname"], "\n")
cat("R Version:", R.version$version.string, "\n")
cat("Library Paths:", .libPaths(), "\n")

# # library(devtools)
# devtools::install_github("NightingaleHealth/ggforestplot")

# renv::snapshot()