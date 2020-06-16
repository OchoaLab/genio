#' Delete all GCTA binary GRM files
#'
#' This function deletes each of the GCTA binary BRM files (grm.bin, grm.N.bin, and grm.id extensions) given the shared base file path, warning with an informative message if any of the files did not exist.
#'
#' @param file The shared file path (excluding extensions: grm.bin, grm.N.bin, or grm.id).
#'
#' @return Nothing
#'
#' @examples
#' # create dummy GRM files
#' file <- tempfile('delete-me-test') # no extension
#' # add each extension and create empty files
#' file.create( paste0(file, '.grm.bin') )
#' file.create( paste0(file, '.grm.N.bin') )
#' file.create( paste0(file, '.grm.id') )
#' 
#' # delete the GRM files we just created
#' delete_files_grm(file)
#' 
#' @export
delete_files_grm <- function(file) {
    # use generic code
    delete_files_generic(file, exts_grm)
}
