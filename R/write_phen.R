#' Write *.phen files
#' 
#' This function writes a tibble with the right columns into a standard *.phen file.
#' It uses readr::write_tsv to do it efficiently.
#' GCTA and EMMAX use this format.
#' 
#' @param file Output file (whatever is accepted by readr::write_tsv).
#' If file is missing the expected *.phen extension, the function adds it.
#' @param tib The tibble or data.frame to write.
#' It must contain these columns: fam, id, pheno.
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
#'     fam = 1:3,
#'     id = 1:3,
#'     pheno = 1
#' )
#' # a dummy file
#' file_out <- tempfile('delete-me-example', fileext = '.phen') # will also work without extension
#' # write the table out in *.phen format (no header, columns in right order)
#' write_phen(file_out, tib)
#' # delete output when done
#' file.remove(file_out)
#' 
#' @seealso
#' GCTA PHEN format reference:
#' \url{https://cnsgenomics.com/software/gcta/#GREMLanalysis}
#'
#' @export
write_phen <- function(file, tib, verbose = TRUE) {
    # this generic writer does all the magic
    write_tab_generic(
        file = file,
        tib = tib,
        ext = 'phen',
        tib_names = phen_names,
        verbose = verbose
    )
}
