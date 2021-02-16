#' Require that PHEN file is present
#'
#' This function checks that the PHEN file is present, given the base file path, stopping with an informative message if the file is missing.
#' This function aids troubleshooting, as various downstream external software report missing files differently and sometimes using confusing or obscure messages.
#'
#' @param file The base file path (excluding `phen` extensions).
#'
#' @return Nothing
#'
#' @examples
#' # to require "data.phen", run like this:
#' # (stops if file is missing)
#' # require_files_phen("data")
#' 
#' # The following example is more awkward
#' # because package sample data has to be specified in this weird way:
#' 
#' # check that the samples we want exist
#' # get path to an existing phen file
#' file <- system.file("extdata", 'sample.phen', package = "genio", mustWork = TRUE)
#' # remove extension
#' file <- sub('\\.phen$', '', file)
#' # since sample.phen file exist, this will not stop with error messages:
#' require_files_phen(file)
#' 
#' @export
require_files_phen <- function(file) {
    # apply more generic function
    require_files_generic(file, 'phen')
}
