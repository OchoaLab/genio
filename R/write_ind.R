#' Write eigenstrat *.ind files
#' 
#' This function writes a tibble with the right columns into a standard eigenstrat *.ind file.
#' It uses readr::write_tsv to do it efficiently.
#' 
#' @param file Output file (whatever is accepted by readr::write_tsv).
#' If file is missing the expected *.ind extension, the function adds it.
#' @param tib The tibble or data.frame to write.
#' It must contain these columns: id, sex, label.
#' Throws an error if any of these columns are missing.
#' Additional columns are ignored.
#' Columns are automatically reordered in output as expected in format.
#' @param verbose If TRUE (default) function reports the path of the file being written (after autocompleting the extension).
#'
#' @return The output `tib` invisibly (what readr::write_tsv returns).
#'
#' @examples
#' # create a dummy tibble with the right columns
#' library(tibble)
#' tib <- tibble(
#'     id = 1:3,
#'     sex = 1,
#'     label = 1
#' )
#' # a dummy file
#' file_out <- tempfile('delete-me-example', fileext = '.ind') # will also work without extension
#' # write the table out in *.ind format (no header, columns in right order)
#' write_ind(file_out, tib)
#' # delete output when done
#' file.remove(file_out)
#' 
#' @seealso
#' Eigenstrat IND format reference:
#' \url{https://github.com/DReichLab/EIG/tree/master/CONVERTF}
#'
#' @export
write_ind <- function(file, tib, verbose = TRUE) {
    # this generic writer does all the magic
    write_tab_generic(
        file = file,
        tib = tib,
        ext = 'ind',
        tib_names = ind_names,
        verbose = verbose
    )
}
