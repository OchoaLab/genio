# a constant
exts_plink <- c('bed', 'bim', 'fam')

#' Require that Plink binary files are present
#'
#' This function checks that each of the Plink binary files (BED/BIM/FAM extensions) are present, given the shared base file path, stopping with an informative message if any of the files is missing.
#' This function aids troubleshooting, as various downstream external software report missing files differently and sometimes using confusing or obscure messages.
#'
#' @param file The shared file path (excluding extensions `bed`, `bim`, `fam`).
#'
#' @return Nothing
#'
#' @examples
#' # to require all of "data.bed", "data.bim", and "data.fam", run like this:
#' # (stops if any of the three files is missing)
#' # require_files_plink("data")
#' 
#' # The following example is more awkward
#' # because package sample data has to be specified in this weird way:
#' 
#' # check that the samples we want exist
#' # start with bed file
#' file <- system.file("extdata", 'sample.bed', package = "genio", mustWork = TRUE)
#' # remove extension
#' file <- sub('\\.bed$', '', file)
#' # since all sample.{bed,bim,fam} files exist, this will not stop with error messages:
#' require_files_plink(file)
#' 
#' @export
require_files_plink <- function(file) {
    # apply more generic function
    require_files_generic(file, exts_plink)
}
