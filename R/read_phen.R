# internal constant
phen_names <- c('fam', 'id', 'pheno')

#' Read *.phen files
#'
#' This function reads a standard *.phen file into a tibble.
#' It uses readr::read_table2 to do it efficiently.
#' GCTA and EMMAX use this format.
#'
#' @param file Input file (whatever is accepted by readr::read_table2).
#' If file as given does not exist and is missing the expected *.phen extension, the function adds the .phen extension and uses that path if that file exists.
#' Additionally, the .gz extension is added automatically if the file (after *.phen extension is added as needed) is still not found and did not already contained the .gz extension and adding it points to an existing file.
#' @param verbose If TRUE (default) function reports the path of the file being loaded (after autocompleting the extensions).
#'
#' @return A tibble with columns: fam, id, pheno.
#'
#' @examples
#' # read an existing plink *.phen file
#' file <- system.file("extdata", 'sample.phen', package = "genio", mustWork = TRUE)
#' phen <- read_phen(file)
#' phen
#'
#' # can specify without extension
#' file <- sub('\\.phen$', '', file) # remove extension from this path on purpose
#' file # verify .phen is missing
#' phen <- read_phen(file) # load it anyway!
#' phen
#' 
#' @seealso
#' GCTA PHEN format reference:
#' \url{https://cnsgenomics.com/software/gcta/#GREMLanalysis}
#'
#' @export
read_phen <- function(file, verbose = TRUE) {
    # this generic reader does all the magic
    read_tab_generic(
        file = file,
        ext = 'phen',
        tib_names = phen_names,
        col_types = 'ccd',
        verbose = verbose
    )
}
