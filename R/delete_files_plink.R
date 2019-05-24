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
    # list of files that must exist
    files_plink <- paste0(file, '.', exts_plink)
    
    # check each in order to produce most informative messages
    for (file_plink in files_plink) {
        # test that it's actually there!
        if( file.exists(file_plink) ) {
            # remove if it was there
            invisible( file.remove(file_plink) )
        } else {
            warning('File to remove did not exist: ', file_plink)
        }
    }
}
