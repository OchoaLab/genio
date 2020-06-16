#' Delete all plink binary files
#'
#' This function deletes each of the plink binary files (BED/BIM/FAM extensions) given the shared base file path, warning with an informative message if any of the files did not exist.
#'
#' @param file The shared file path (excluding BED/BIM/FAM extensions).
#'
#' @return Nothing
#'
#' @examples
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
