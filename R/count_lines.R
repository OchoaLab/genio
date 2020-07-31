#' Count the number of lines of a file
#'
#' This function returns the number of lines in a file.
#' It is intended to result in fast retrieval of numbers of individuals (from FAM or equivalent files) or loci (BIM or equivalent files) when the input files are extremely large and no other information is required from these files.
#' This code uses C++ to quickly counts lines (like linux's `wc -l` but this one is cross-platform).
#'
#' @param file The input file path to read (a string).
#' @param ext An optional extension.
#' If `NA` (default), `file` is expected to contain its extension already.
#' Otherwise, this extension is added, but only if this extension was not already there (so if inputs were `file = 'file.bim', ext = 'bim'`, file is not altered and read without errors).
#' @param verbose If `TRUE` (default), writes a message reporting the file whose lines are being counted (after adding extensions if it was needed).
#' @param iter If `TRUE`, uses a version of the C++ code that uses iterators, should be even faster but makes more assumptions (the newline character should be encoded as 0x0a (ok in most reasonable encodings, including ISO-8859 and UTF-8)).
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
count_lines <- function( file, ext = NA, verbose = TRUE, iter = FALSE ) {
    # R code is a wrapper around C++ code, with extra nice features too awkward to do in C++
    # the C++ portion is extremely bare, a poor man's `wc -l`

    # add extension if necessary
    # in that case a .gz extension might also be added, if it was needed
    # (but .gz is never added if `ext = NA` !)
    if ( !is.na( ext ) )
        file <- real_path( file, ext )

    # make sure file exists
    if ( !file.exists( file ) )
        stop( 'File does not exist: ', file )

    # message
    if ( verbose )
        message( 'Counting lines: ', file )

    # count lines using C++, return that value
    if ( iter ) {
        # try another version that uses iterators, should be faster but gets confused if file doesn't end in newline
        return( count_lines_iterators_cpp( file ) )
    } else {
        return( count_lines_cpp( file ) )
    }
}
# TODO:
# - try C++ iterators
# - what about gzip files???
