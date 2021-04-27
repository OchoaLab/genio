#' Write a matrix to a file without row or column names
#'
#' The inverse function of [read_matrix()], this writes what is intended to be a numeric matrix to a tab-delimited file without row or column names present.
#' It uses [readr::write_tsv()] to do it efficiently.
#' Intended for outputs such as those of admixture inference approaches.
#' 
#' @param file Output file (whatever is accepted by [readr::write_tsv()]).
#' If file is missing the expected extension (see below), the function adds it.
#' @param x The matrix to write.
#' Unlike [read_matrix()], this is not in fact required to be a matrix or be strictly numeric; anything that coerces to tibble or data.frame is acceptable.
#' @param ext The desired file extension.
#' If `NA`, no extension is added.
#' Works if `file` already contains desired extension.
#' @param verbose If `TRUE` (default), function reports the path of the file being written (after autocompleting the extension).
#' @param append If `TRUE`, appends rows onto the file. (Default is `FALSE`).
#'
#' @return The output `x`, coerced into data.frame, invisibly (what [readr::write_tsv()] returns).
#'
#' @examples
#' # to write an existing matrix `x` into file "data.txt", run like this:
#' # write_matrix( "data", x )
#' # this also works
#' # write_matrix( "data.txt", x )
#' 
#' # The following example is more detailed but also more awkward
#' # because (only for these examples) the package must create the file in a *temporary* location
#' 
#' # create a dummy matrix with the right columns
#' x <- rbind( 1:3, (0:2)/10, -1:1 )
#' # a dummy file
#' file_out <- tempfile('delete-me-example', fileext = '.txt') # will also work without extension
#' # write the matrix without header
#' write_matrix( file_out, x )
#' # delete output when done
#' file.remove( file_out )
#'
#' @seealso
#' [read_matrix()], the inverse function.
#'
#' @export
write_matrix <- function( file, x, ext = 'txt', verbose = TRUE, append = FALSE ) {
    if ( missing( file ) )
        stop( 'Output file path (file) is required!' )
    if ( missing( x ) )
        stop( 'Matrix `x` is required!' )
    
    # add extension if it wasn't already there
    file <- add_ext(file, ext)
    
    # announce what we ended up writing, nice to know
    if (verbose) {
        if (append) {
            message('Appending: ', file)
        } else {
            message('Writing: ', file)
        }
    }

    # convert to data frame if necessary
    if ( !is.data.frame( x ) )
        x <- as.data.frame( x )
    
    # writes using tab separators
    readr::write_tsv(
               x,
               file,
               col_names = FALSE,
               append = append
           )
#    write.table(x, file, sep = "\t", row.names = FALSE, col.names = FALSE)
}
