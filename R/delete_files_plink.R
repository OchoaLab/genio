#' Delete all Plink binary files
#'
#' This function deletes each of the Plink binary files (`bed`, `bim`, `fam` extensions) given the shared base file path, warning if any of the files did not exist or if any were not successfully deleted.
#'
#' @param file The shared file path (excluding extensions: `bed`, `bim`, `fam`).
#'
#' @return Nothing
#'
#' @examples
#' # if you want to delete "data.bed", "data.bim" and "data.fam", run like this:
#' # delete_files_plink("data")
#' 
#' # The following example is more awkward
#' # because (only for these examples) the package must create *temporary* files to actually delete
#' 
#' # create dummy BED/BIM/FAM files
#' file <- tempfile('delete-me-test') # no extension
#' # add each extension and create empty files
#' file.create( paste0(file, '.bed') )
#' file.create( paste0(file, '.bim') )
#' file.create( paste0(file, '.fam') )
#' 
#' # delete the BED/BIM/FAM files we just created
#' delete_files_plink(file)
#' 
#' @export
delete_files_plink <- function(file) {
    # use generic code
    delete_files_generic(file, exts_plink)
}
