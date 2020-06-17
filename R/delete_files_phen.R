#' Delete PHEN files
#'
#' This function deletes a PHEN files given the base file path (without extension), warning with an informative message if the file did not exist.
#'
#' @param file The base file path (excluding PHEN extensions).
#'
#' @return Nothing
#'
#' @examples
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
