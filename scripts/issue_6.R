# Code from https://github.com/OchoaLab/genio/issues/6

################################################################################
#
# 1. `write_bed` works as expected, from documentation example code
#
################################################################################
file_out <- tempfile('delete-me-example', fileext = '.bed') # will also work without extension
X <- rbinom(10, 2, 0.5)
X[sample(10, 3)] <- NA
X <- matrix(X, nrow = 5, ncol = 2)
genio::write_bed(file_out, X) # WORKS

################################################################################
#
# 2. `write_bed` works as expected, when saving 
#   * in a normalized path 
#   * in a sub-folder that exists
#
################################################################################
file_out <- file.path(
  rappdirs::user_cache_dir(appname = "my_r_package_name"),
  "sub_folder_2", "my_filename"
)
dir.create(dirname(file_out), recursive = TRUE)
file_out <- normalizePath(file_out, mustWork = FALSE)
#
# On my computer: 
# file_out == "/home/richel/.cache/my_r_package_name/sub_folder/my_filename"
#
X <- rbinom(10, 2, 0.5)
X[sample(10, 3)] <- NA
X <- matrix(X, nrow = 5, ncol = 2)
genio::write_bed(file_out, X) # WORKS

################################################################################
#
# 3. `write_bed` crashes ruthlessly, when saving 
#   * in a normalized path 
#   * in a sub-folder that does not exist
#
################################################################################
file_out <- file.path(
  rappdirs::user_cache_dir(appname = "my_r_package_name"),
  "sub_folder_3", "my_filename"
)
file_out <- normalizePath(file_out, mustWork = FALSE)
#
# On my computer: 
# file_out == "/home/richel/.cache/my_r_package_name/sub_folder/my_filename"
#
X <- rbinom(10, 2, 0.5)
X[sample(10, 3)] <- NA
X <- matrix(X, nrow = 5, ncol = 2)
genio::write_bed(file_out, X) # CAUSES ABORT

################################################################################
#
# 4. `write_bed` crashes ruthlessly, when saving 
#   * in an un-normalized path 
#   * in a sub-folder that does exist
#
################################################################################
file_out <- file.path(
  rappdirs::user_cache_dir(appname = "my_r_package_name"),
  "sub_folder_4", "my_filename"
)
dir.create(dirname(file_out), recursive = TRUE)
testthat::expect_equal(file_out, "~/.cache/my_r_package_name/sub_folder_4/my_filename")
X <- rbinom(10, 2, 0.5)
X[sample(10, 3)] <- NA
X <- matrix(X, nrow = 5, ncol = 2)
genio::write_bed(file_out, X) # CAUSES ABORT
