#' Delete PHEN files
#'
#' This function deletes a PHEN files given the base file path (without extension), warning if the file did not exist or if it was not successfully deleted.
#'
#' @param file The base file path (excluding `phen` extension).
#'
#' @return Nothing
#'
#' @examples
#' # if you want to delete "data.phen", run like this:
#' # delete_files_phen("data")
#' 
#' # The following example is more awkward
#' # because (only for these examples) the package must create a *temporary* file to actually delete
#' 
#' # create dummy PHEN files
#' file <- tempfile('delete-me-test') # no extension
#' # add extension and create an empty file
#' file.create( paste0(file, '.phen') )
#' 
#' # delete the PHEN file we just created
#' delete_files_phen(file)
#' 
#' @export
delete_files_phen <- function(file) {
    # use generic code
    delete_files_generic(file, 'phen')
}
