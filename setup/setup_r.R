main <- function() {
  .libPaths('lib/r/external_packages') # Packages will be installed in this location
  
  # Detect Apple Silicon
  is_apple_silicon <- Sys.info()["machine"] == "arm64" && Sys.info()["sysname"] == "Darwin"
  
  if (is_apple_silicon) {
    cat("Detected Apple Silicon (ARM64) - using native installation\n")
    # Use CRAN mirror that supports ARM64
    repos <- "https://cran.rstudio.com/"
  } else {
    cat("Detected x86_64 architecture - using standard installation\n")
    repos <- "https://mirror.its.umich.edu/cran/"
  }
  
  # List of CRAN packages to install
  CRAN_packages <- NULL
  
  # Install packages with platform-specific options
  if (!is.null(CRAN_packages) && length(CRAN_packages) > 0) {
    if (is_apple_silicon) {
      # For Apple Silicon, install with specific options
      install.packages(CRAN_packages, 
                       repos = repos,
                       dependencies = TRUE, 
                       lib = 'lib/r/external_packages/',
                       type = "source") # Use source installation for better ARM64 compatibility
    } else {
      # Standard installation for x86_64
      install.packages(CRAN_packages, 
                       repos = repos,
                       dependencies = TRUE, 
                       lib = 'lib/r/external_packages/')
    }
  }
  
  # Install GitHub packages
  if (!require(remotes, quietly = TRUE)) {
    install.packages("remotes", repos = repos, lib = 'lib/r/external_packages')
  }
  library(remotes)
  
  # Install GitHub packages with platform detection
  tryCatch({
    install_github("NightingaleHealth/ggforestplot", force = TRUE, lib = 'lib/r/external_packages')
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
