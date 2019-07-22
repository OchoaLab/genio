#' Write plink *.fam files
#' 
#' This function writes a tibble with the right columns into a standard plink *.fam file.
#' It uses readr::write_tsv to do it efficiently.
#' 
#' @param file Output file (whatever is accepted by readr::write_tsv).
#' If file is missing the expected *.fam extension, the function adds it.
#' @param tib The tibble or data.frame to write.
#' It must contain these columns: fam, id, pat, mat, sex, pheno.
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
#'     pat = 0,
#'     mat = 0,
#'     sex = 1,
#'     pheno = 1
#' )
#' # a dummy file
#' file_out <- tempfile('delete-me-example', fileext = '.fam') # will also work without extension
#' # write the table out in *.fam format (no header, columns in right order)
#' write_fam(file_out, tib)
#' # delete output when done
#' file.remove(file_out)
#' 
#' @seealso
#' \code{\link{write_plink}} for writing a set of BED/BIM/FAM files.
#' 
#' Plink FAM format reference:
#' \url{https://www.cog-genomics.org/plink/1.9/formats#fam}
#'
#' @export
write_fam <- function(file, tib, verbose = TRUE) {
    # this generic writer does all the magic
    write_tab_generic(
        file = file,
        tib = tib,
        ext = 'fam',
        tib_names = fam_names,
        verbose = verbose
    )
}
