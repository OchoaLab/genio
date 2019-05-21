# internal constant
bim_names <- c('chr', 'id', 'posg', 'pos', 'ref', 'alt')

#' Read plink *.bim files
#'
#' This function reads a standard plink *.bim file into a tibble.
#' It uses readr::read_table2 to do it efficiently.
#'
#' @param file Input file (whatever is accepted by readr::read_table2).
#' If file as given does not exist and is missing the expected *.bim extension, the function adds the .bim extension and uses that path if that file exists.
#' Additionally, the .gz extension is added automatically if the file (after *.bim extension is added as needed) is still not found and did not already contained the .gz extension and adding it points to an existing file.
#' @param verbose If TRUE (default) function reports the path of the file being loaded (after autocompleting the extensions).
#'
#' @return A tibble with columns: chr, id, posg, pos, ref, alt
#'
#' @examples
#' # read an existing plink *.bim file
#' file <- system.file("extdata", 'sample.bim', package = "genio", mustWork = TRUE)
#' bim <- read_bim(file)
#' bim
#'
#' # can specify without extension
#' file <- sub('\\.bim$', '', file) # remove extension from this path on purpose
#' file # verify .bim is missing
#' bim <- read_bim(file) # loads too!
#' bim
#' 
#' @seealso
#' \code{\link{read_plink}} for reading a set of BED/BIM/FAM files.
#'
#' Plink BIM format reference:
#' \url{https://www.cog-genomics.org/plink/1.9/formats#bim}
#'
#' @export
read_bim <- function(file, verbose = TRUE) {
    # this generic reader does all the magic
    read_tab_generic(
        file = file,
        ext = 'bim',
        tib_names = bim_names,
        col_types = 'ccdicc',
        verbose = verbose
    )
}
