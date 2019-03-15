# internal constant
ind_names <- c('id', 'sex', 'label')

#' Read eigenstrat *.ind files
#'
#' This function reads a standard eigenstrat *.ind file into a tibble.
#' It uses readr::read_table2 to do it efficiently.
#'
#' @param fi File in (whatever is accepted by readr::read_table2).
#' If file as given does not exist and is missing the expected *.ind extension, the function adds the .ind extension and uses that path if that file exists.
#' Additionally, the .gz extension is added automatically if the file (after *.ind extension is added as needed) is still not found and did not already contained the .gz extension and adding it points to an existing file.
#' @param verbose If TRUE (default) function reports the path of the file being loaded (after autocompleting the extensions).
#'
#' @return A tibble with columns: id, sex, label.
#'
#' @examples
#' # read an existing eigenstrat *.ind file
#' fi <- system.file("extdata", 'sample.ind', package = "genio", mustWork = TRUE)
#' ind <- read_ind(fi)
#' ind
#'
#' # can specify without extension
#' fi <- sub('\\.ind$', '', fi) # remove extension from this path on purpose
#' fi # verify .ind is missing
#' ind <- read_ind(fi) # load it anyway!
#' ind
#' 
#' @export
read_ind <- function(fi, verbose=TRUE) {
    # add .ind and/or .gz if missing and needed
    fi <- real_path(fi, 'ind')
    # announce what we ended up loading, nice to know
    if(verbose) message('Reading: ', fi)
    # read input
    ind <- readr::read_table2(
                      fi,
                      col_names = ind_names,
                      col_types = 'ccc'
                  )
}
