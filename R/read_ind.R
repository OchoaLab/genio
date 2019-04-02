# internal constant
ind_names <- c('id', 'sex', 'label')

#' Read eigenstrat *.ind files
#'
#' This function reads a standard eigenstrat *.ind file into a tibble.
#' It uses readr::read_table2 to do it efficiently.
#'
#' @param file Input file (whatever is accepted by readr::read_table2).
#' If file as given does not exist and is missing the expected *.ind extension, the function adds the .ind extension and uses that path if that file exists.
#' Additionally, the .gz extension is added automatically if the file (after *.ind extension is added as needed) is still not found and did not already contained the .gz extension and adding it points to an existing file.
#' @param verbose If TRUE (default) function reports the path of the file being loaded (after autocompleting the extensions).
#'
#' @return A tibble with columns: id, sex, label.
#'
#' @examples
#' # read an existing eigenstrat *.ind file
#' file <- system.file("extdata", 'sample.ind', package = "genio", mustWork = TRUE)
#' ind <- read_ind(file)
#' ind
#'
#' # can specify without extension
#' file <- sub('\\.ind$', '', file) # remove extension from this path on purpose
#' file # verify .ind is missing
#' ind <- read_ind(file) # load it anyway!
#' ind
#' 
#' @seealso
#' Eigenstrat IND format reference:
#' \url{https://github.com/DReichLab/EIG/tree/master/CONVERTF}
#'
#' @export
read_ind <- function(file, verbose = TRUE) {
    # this generic reader does all the magic
    read_tab_generic(
        file = file,
        ext = 'ind',
        tib_names = ind_names,
        col_types = 'ccc',
        verbose = verbose
    )
}
