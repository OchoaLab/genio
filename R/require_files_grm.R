# a constant
exts_grm <- paste0('grm.', c('bin', 'N.bin', 'id') )

#' Require that GCTA binary GRM files are present
#'
#' This function checks that each of the GCTA binary GRM files (`grm.bin`, `grm.N.bin`, and `grm.id` extensions) are present, given the shared base file path, stopping with an informative message if any of the files is missing.
#' This function aids troubleshooting, as various downstream external software report missing files differently and sometimes using confusing or obscure messages.
#'
#' @param file The shared file path (excluding extensions: `grm.bin`, `grm.N.bin`, or `grm.id`).
#'
#' @return Nothing
#'
#' @examples
#' # to require all of "data.grm.bin", "data.grm.N.bin", and "data.grm.id", run like this:
#' # (stops if any of the three files is missing)
#' # require_files_grm("data")
#' 
#' # The following example is more awkward
#' # because package sample data has to be specified in this weird way:
#' 
#' # check that the samples we want exist
#' # start with bed file
#' file <- system.file("extdata", 'sample.grm.bin', package = "genio", mustWork = TRUE)
#' # remove extension
#' file <- sub('\\.grm\\.bin$', '', file)
#' # since all sample.grm.{bin,N.bin,id} files exist, this will not stop with error messages:
#' require_files_grm(file)
#' 
#' @export
require_files_grm <- function(file) {
    # apply more generic function
    require_files_generic(file, exts_grm)
}
