# internal constant
snp_names <- c('id', 'chr', 'posg', 'pos', 'ref', 'alt')

#' Read eigenstrat *.snp files
#'
#' This function reads a standard eigenstrat *.snp file into a tibble.
#' It uses readr::read_table2 to do it efficiently.
#'
#' @param file Input file (whatever is accepted by readr::read_table2).
#' If file as given does not exist and is missing the expected *.snp extension, the function adds the .snp extension and uses that path if that file exists.
#' Additionally, the .gz extension is added automatically if the file (after *.snp extension is added as needed) is still not found and did not already contained the .gz extension and adding it points to an existing file.
#' @param verbose If TRUE (default) function reports the path of the file being loaded (after autocompleting the extensions).
#'
#' @return A tibble with columns: id, chr, posg, pos, ref, alt
#'
#' @examples
#' # read an existing eigenstrat *.snp file
#' file <- system.file("extdata", 'sample.snp', package = "genio", mustWork = TRUE)
#' snp <- read_snp(file)
#' snp
#'
#' # can specify without extension
#' file <- sub('\\.snp$', '', file) # remove extension from this path on purpose
#' file # verify .snp is missing
#' snp <- read_snp(file) # load it anyway!
#' snp
#' 
#' @seealso
#' Eigenstrat SNP format reference:
#' \url{https://github.com/DReichLab/EIG/tree/master/CONVERTF}
#'
#' @export
read_snp <- function(file, verbose = TRUE) {
    # this generic reader does all the magic
    read_tab_generic(
        file = file,
        ext = 'snp',
        tib_names = snp_names,
        col_types = 'ccdicc',
        verbose = verbose
    )
}
