# internal constant
fam_names <- c('fam', 'id', 'pat', 'mat', 'sex', 'pheno')

#' Read plink *.fam files
#'
#' This function reads a standard plink *.fam file into a tibble.
#' It uses readr::read_table2 to do it efficiently.
#'
#' @param fi File in (whatever is accepted by readr::read_table2).
#' If file as given does not exist and is missing the expected *.fam extension, the function adds the .fam extension and uses that path if that file exists.
#' Additionally, the .gz extension is added automatically if the file (after *.fam extension is added as needed) is still not found and did not already contained the .gz extension and adding it points to an existing file.
#' @param verbose If TRUE (default) function reports the path of the file being loaded (after autocompleting the extensions).
#'
#' @return A tibble with columns: fam, id, pat, mat, sex, pheno.
#'
#' @examples
#' # read an existing plink *.fam file
#' fi <- system.file("extdata", 'sample.fam', package = "genio", mustWork = TRUE)
#' fam <- read_fam(fi)
#' fam
#'
#' # can specify without extension
#' fi <- sub('\\.fam$', '', fi) # remove extension from this path on purpose
#' fi # verify .fam is missing
#' fam <- read_fam(fi) # load it anyway!
#' fam
#' 
#' @export
read_fam <- function(fi, verbose=TRUE) {
    # add .fam and/or .gz if missing and needed
    fi <- real_path(fi, 'fam')
    # announce what we ended up loading, nice to know
    if(verbose) message('Reading: ', fi)
    # read input
    ind <- readr::read_table2(
                      fi,
                      col_names = fam_names,
                      col_types = 'ccccii'
                  )
}
