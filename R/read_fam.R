# internal constant
fam_names <- c('fam', 'id', 'pat', 'mat', 'sex', 'pheno')

#' Read plink *.fam files
#'
#' This function reads a standard plink *.fam file into a tibble.
#' It uses readr::read_table2 to do it efficiently.
#'
#' @param file Input file (whatever is accepted by readr::read_table2).
#' If file as given does not exist and is missing the expected *.fam extension, the function adds the .fam extension and uses that path if that file exists.
#' Additionally, the .gz extension is added automatically if the file (after *.fam extension is added as needed) is still not found and did not already contained the .gz extension and adding it points to an existing file.
#' @param verbose If TRUE (default) function reports the path of the file being loaded (after autocompleting the extensions).
#'
#' @return A tibble with columns: fam, id, pat, mat, sex, pheno.
#'
#' @examples
#' # read an existing plink *.fam file
#' file <- system.file("extdata", 'sample.fam', package = "genio", mustWork = TRUE)
#' fam <- read_fam(file)
#' fam
#'
#' # can specify without extension
#' file <- sub('\\.fam$', '', file) # remove extension from this path on purpose
#' file # verify .fam is missing
#' fam <- read_fam(file) # load it anyway!
#' fam
#' 
#' @seealso
#' \code{\link{read_plink}} for reading a set of BED/BIM/FAM files.
#' 
#' Plink FAM format reference:
#' \url{https://www.cog-genomics.org/plink/1.9/formats#fam}
#'
#' @export
read_fam <- function(file, verbose = TRUE) {
    # this generic reader does all the magic
    read_tab_generic(
        file = file,
        ext = 'fam',
        tib_names = fam_names,
        col_types = 'ccccid',
        verbose = verbose
    )
}
