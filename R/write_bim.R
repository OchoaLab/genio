#' Write plink *.bim files
#' 
#' This function writes a tibble with the right columns into a standard plink *.bim file.
#' It uses readr::write_tsv to do it efficiently.
#' 
#' @param file Output file (whatever is accepted by readr::write_tsv).
#' If file is missing the expected *.bim extension, the function adds it.
#' @param tib The tibble or data.frame to write.
#' It must contain these columns: chr, id, posg, pos, ref, alt.
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
#'     chr = 1:3,
#'     id = 1:3,
#'     posg = 0,
#'     pos = 1:3,
#'     ref = 'A',
#'     alt = 'B'
#' )
#' # a dummy file
#' file_out <- tempfile('delete-me-example', fileext = '.bim') # will also work without extension
#' # write the table out in *.bim format (no header, columns in right order)
#' write_bim(file_out, tib)
#' # delete output when done
#' file.remove(file_out)
#' 
#' @seealso
#' \code{\link{write_plink}} for writing a set of BED/BIM/FAM files.
#' 
#' Plink BIM format reference:
#' \url{https://www.cog-genomics.org/plink/1.9/formats#bim}
#'
#' @export
write_bim <- function(file, tib, verbose = TRUE) {
    # this generic writer does all the magic
    write_tab_generic(
        file = file,
        tib = tib,
        ext = 'bim',
        tib_names = bim_names,
        verbose = verbose
    )
}
