#' Read a numerical matrix file into an R matrix
#'
#' Reads a matrix file under strict assumptions that it is entirely numeric and there are no row or column names present in this file.
#' It uses [readr::read_table()] to do it efficiently.
#' Intended for outputs such as those of admixture inference approaches.
#'
#' @param file Input file (whatever is accepted by [readr::read_table()]).
#' If file as given does not exist and is missing the expected extension (see `ext` below), the function adds the extension and uses that path if that file exists.
#' Additionally, the .gz extension is added automatically if the file (after the extension is added as needed) is still not found and did not already contain the .gz extension and adding it points to an existing file.
#' @param ext The desired file extension.
#' Ignored if `file` points to an existing file.
#' Set to `NA` to force `file` to exist as-is.
#' @param verbose If `TRUE` (default) function reports the path of the file being loaded (after autocompleting the extensions).
#'
#' @return A numeric matrix without row or column names.
#' 
#' @examples
#' # to read "data.txt", run like this:
#' # mat <- read_matrix("data")
#' # this also works
#' # mat <- read_matrix("data.txt")
#' 
#' # The following example is more awkward
#' # because package sample data has to be specified in this weird way:
#' 
#' # read an existing matrix *.txt file
#' file <- system.file("extdata", 'sample-Q3.txt', package = "genio", mustWork = TRUE)
#' mat <- read_matrix(file)
#' mat
#'
#' # can specify without extension
#' file <- sub('\\.txt$', '', file) # remove extension from this path on purpose
#' file # verify .txt is missing
#' mat <- read_matrix(file) # load it anyway!
#' mat
#'
#' @seealso
#' [write_matrix()], the inverse function.
#' 
#' @export
read_matrix <- function( file, ext = 'txt', verbose = TRUE ) {
    if ( missing( file ) )
        stop('Input file path `file` is required!')

    # add .ext and/or .gz if missing and needed
    file <- add_ext_read(file, ext)
    
    # announce what we ended up loading, nice to know
    if (verbose)
        message('Reading: ', file)
    
    # read matrices, assume there is no header
    x <- readr::read_table(
        file,
        col_names = FALSE,
        # all columns will be doubles, do not pre-specify the number of columns
        col_types = readr::cols( .default = readr::col_double() )
    )

    # convert to ordinary numerical matrices
    x <- data.matrix( x )

    # column names were set by default to c("X1", "X2", ...) by read_table (no way to avoid it)
    # however, names are useless and misleading, let's remove them before returning
    # these files have no meaninful dimnames, just delete them all
    dimnames( x ) <- NULL
    
    return( x )
}
