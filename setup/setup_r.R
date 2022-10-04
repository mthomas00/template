.libPaths('') # Cleanup any additional paths the user might have
.libPaths('../lib/R') # Packages will be installed in this location

main <- function() {
  .libPaths('') # Cleanup any additional paths the user might have
  .libPaths('../lib/r') # Packages will be installed in this location
  #List of CRAN packages to install
  CRAN_packages   <- c("data.table", "Rcpp", "fst", "ggplot2", "fixest", "zoo", "stringr", "readxl", 
    "fwildclusterboot", "RcppRoll", "future", "forestplot", "tidyr", "ggplot2", "RcppEigen",
    "future.apply", 
    "rlang", "vctrs", "glue", "magrittr", "cli", "fansi", "utf8", "tibble", "purrr", "dplyr",
    "colorspace", "backports", "lazyeval", "stringi") 
  install.packages(CRAN_packages, repos = "https://cran.csie.ntu.edu.tw/",
                   dependencies=TRUE, lib='../lib/r') #Download packages to {root}/lib/r/*
}

main()

library(remotes)
install_github("NightingaleHealth/ggforestplot", force=TRUE)

# # library(devtools)
# devtools::install_github("NightingaleHealth/ggforestplot")

# renv::snapshot()