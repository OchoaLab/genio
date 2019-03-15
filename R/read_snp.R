# internal constant
snp_names <- c('id', 'chr', 'posg', 'pos', 'ref', 'alt')

#' Read eigenstrat *.snp files
#'
#' This function reads a standard eigenstrat *.snp file into a tibble.
#' It uses readr::read_table2 to do it efficiently.
#'
#' @param fi File in (whatever is accepted by readr::read_table2).
#' If file as given does not exist and is missing the expected *.snp extension, the function adds the .snp extension and uses that path if that file exists.
#' Additionally, the .gz extension is added automatically if the file (after *.snp extension is added as needed) is still not found and did not already contained the .gz extension and adding it points to an existing file.
#' @param verbose If TRUE (default) function reports the path of the file being loaded (after autocompleting the extensions).
#'
#' @return A tibble with columns: id, chr, posg, pos, ref, alt
#'
#' @examples
#' # read an existing eigenstrat *.snp file
#' fi <- system.file("extdata", 'sample.snp', package = "genio", mustWork = TRUE)
#' snp <- read_snp(fi)
#' snp
#'
#' # can specify without extension
#' fi <- sub('\\.snp$', '', fi) # remove extension from this path on purpose
#' fi # verify .snp is missing
#' snp <- read_snp(fi) # load it anyway!
#' snp
#' 
#' @export
read_snp <- function(fi, verbose=TRUE) {
    # add .snp and/or .gz if missing and needed
    fi <- real_path(fi, 'snp')
    # announce what we ended up loading, nice to know
    if(verbose) message('Reading: ', fi)
    # read input
    ind <- readr::read_table2(
                      fi,
                      col_names = snp_names,
                      col_types = 'ccdicc'
                  )
}
