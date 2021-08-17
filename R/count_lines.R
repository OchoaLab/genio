#' Count the number of lines of a file
#'
#' This function returns the number of lines in a file.
#' It is intended to result in fast retrieval of numbers of individuals (from FAM or equivalent files) or loci (BIM or equivalent files) when the input files are extremely large and no other information is required from these files.
#' This code uses C++ to quickly counts lines (like linux's `wc -l` but this one is cross-platform).
#'
#' Note: this function does not work correctly with compressed files (they are not uncompressed prior to counting newlines).
#'
#' @param file The input file path to read (a string).
#' @param ext An optional extension.
#' If `NA` (default), `file` is expected to exist as-is.
#' Otherwise, if `file` doesn't exist and the extension was missing, then this extension is added.
#' @param verbose If `TRUE` (default), writes a message reporting the file whose lines are being counted (after adding extensions if it was needed).
#'
#' @return The number of lines in the file.
#'
#' @examples
#' # count number of individuals from an existing plink *.fam file
#' file <- system.file("extdata", 'sample.fam', package = "genio", mustWork = TRUE)
#' n_ind <- count_lines(file)
#' n_ind
#'
#' # count number of loci from an existing plink *.bim file
#' file <- system.file("extdata", 'sample.bim', package = "genio", mustWork = TRUE)
#' m_loci <- count_lines(file)
#' m_loci
#'
#' @export
count_lines <- function( file, ext = NA, verbose = TRUE ) {
    # R code is a wrapper around C++ code, with extra nice features too awkward to do in C++
    # the C++ portion is extremely bare, a poor man's `wc -l`

    # add extension if necessary
    file <- add_ext_read( file, ext )
    
    # make sure file exists
    if ( !file.exists( file ) )
        stop( 'File does not exist: ', file )

    # message
    if ( verbose )
        message( 'Counting lines: ', file )

    # C++ doesn't work with tildes in names, so let's expand path before we pass to C++
    file <- path.expand( file )
    
    # count lines using C++
    n <- count_lines_cpp( file )
    # though the return value is clearly an integer in C++, R fudges it and returns a double unless we force it to integer!
    # however, retain as double to prevent overflows if needed (not sure if that can happen since C++ would overflow as well, right?  meh)
    if ( n <= .Machine$integer.max )
        n <- as.integer( n )
    return( n )
}
