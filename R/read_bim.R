# internal constant
bim_names <- c('chr', 'id', 'posg', 'pos', 'ref', 'alt')

#' Read plink *.bim files
#'
#' This function reads a standard plink *.bim file into a tibble.
#' It uses readr::read_table2 to do it efficiently.
#'
#' @param fi File in (whatever is accepted by readr::read_table2).
#' If file as given does not exist and is missing the expected *.bim extension, the function adds the .bim extension and uses that path if that file exists.
#' Additionally, the .gz extension is added automatically if the file (after *.bim extension is added as needed) is still not found and did not already contained the .gz extension and adding it points to an existing file.
#' @param verbose If TRUE (default) function reports the path of the file being loaded (after autocompleting the extensions).
#'
#' @return A tibble with columns: chr, id, posg, pos, ref, alt
#'
#' @examples
#' # read an existing plink *.bim file
#' fi <- system.file("extdata", 'sample.bim', package = "genio", mustWork = TRUE)
#' bim <- read_bim(fi)
#' bim
#'
#' # can specify without extension
#' fi <- sub('\\.bim$', '', fi) # remove extension from this path on purpose
#' fi # verify .bim is missing
#' bim <- read_bim(fi) # load it anyway!
#' bim
#' 
#' @export
read_bim <- function(fi, verbose=TRUE) {
    # add .bim and/or .gz if missing and needed
    fi <- real_path(fi, 'bim')
    # announce what we ended up loading, nice to know
    if(verbose) message('Reading: ', fi)
    # read input
    ind <- readr::read_table2(
                      fi,
                      col_names = bim_names,
                      col_types = 'ccdicc'
                  )
}
