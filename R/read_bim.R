# internal constant
bim_names <- c('chr', 'id', 'posg', 'pos', 'alt', 'ref')

#' Read Plink *.bim files
#'
#' This function reads a standard Plink *.bim file into a tibble with named columns.
#' It uses [readr::read_table()] to do it efficiently.
#'
#' @param file Input file (whatever is accepted by [readr::read_table()]).
#' If file as given does not exist and is missing the expected *.bim extension, the function adds the .bim extension and uses that path if that file exists.
#' Additionally, the .gz extension is added automatically if the file (after *.bim extension is added as needed) is still not found and did not already contain the .gz extension and adding it points to an existing file.
#' @param verbose If `TRUE` (default) function reports the path of the file being loaded (after autocompleting the extensions).
#'
#' @return A tibble with columns: `chr`, `id`, `posg`, `pos`, `alt`, `ref`.
#'
#' @examples
#' # to read "data.bim", run like this:
#' # bim <- read_bim("data")
#' # this also works
#' # bim <- read_bim("data.bim")
#' 
#' # The following example is more awkward
#' # because package sample data has to be specified in this weird way:
#' 
#' # read an existing Plink *.bim file
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
#' [read_plink()] for reading a set of BED/BIM/FAM files.
#'
#' Plink BIM format references:
#' <https://www.cog-genomics.org/plink/1.9/formats#bim>
#' <https://www.cog-genomics.org/plink/2.0/formats#bim>
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
