#' Delete all GCTA binary GRM files
#'
#' This function deletes each of the GCTA binary GRM files (`grm.bin`, `grm.N.bin`, and `grm.id` extensions) given the shared base file path, warning if any of the files did not exist or if any were not successfully deleted.
#'
#' @param file The shared file path (excluding extensions: `grm.bin`, `grm.N.bin`, or `grm.id`).
#'
#' @return Nothing
#'
#' @examples
#' # if you want to delete "data.grm.bin", "data.grm.N.bin" and "data.grm.id", run like this:
#' # delete_files_grm("data")
#' 
#' # The following example is more awkward
#' # because (only for these examples) the package must create *temporary* files to actually delete
#' 
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
