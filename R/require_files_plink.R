# a constant
exts_plink <- c('bed', 'bim', 'fam')

#' Require that plink binary files are present
#'
#' This function checks that each of the plink binary files (BED/BIM/FAM extensions) are present, given the shared base file path, stopping with an informative message if any of the files is missing.
#' This function aids troubleshooting, as various downstream external software report missing files differently and sometimes using confusing or obscure messages.
#'
#' @param file The shared file path (excluding BED/BIM/FAM extensions).
#'
#' @return Nothing
#'
#' @examples
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
    # list of files that must exist
    files_plink <- paste0(file, '.', exts_plink)
    
    # check each in order to produce most informative messages
    for (file_plink in files_plink) {
        if (!file.exists(file_plink))
            stop('Required file is missing: ', file_plink)
    }
}
