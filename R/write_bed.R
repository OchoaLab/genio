#' @useDynLib genio
#' @importFrom Rcpp sourceCpp
NULL

#' Write a genotype matrix into Plink BED format
#'
#' This function accepts a standard R matrix containing genotypes (values in `c( 0, 1, 2, NA )`) and writes it into a Plink-formatted BED (binary) file.
#' Each genotype per locus (`m` loci) and individual (`n` total) counts the number of alternative alleles or `NA` for missing data.
#' No *.fam or *.bim files are created by this basic function.
#'
#' Genotypes with values outside of \[0, 2\] cause an error, in which case the partial output is deleted.
#' However, beware that decimals get truncated internally, so values that truncate to 0, 1, or 2 will not raise errors.
#' The BED format does not accept fractional dosages, so such data will not be written as expected.
#' 
#' @param file Output file path.  .bed extension may be omitted (will be added automatically if it is missing).
#' @param X The `m`-by-`n` genotype matrix.
#' Row and column names, if present, are ignored.
#' @param verbose If `TRUE` (default), function reports the path of the file being written (after autocompleting the extension).
#' @param append If `TRUE`, appends variants onto the file. (Default is `FALSE`).
#'
#' @return Nothing
#'
#' @examples
#' # to write an existing matrix `X` into file "data.bed", run like this:
#' # write_bed("data", X)
#' # this also works
#' # write_bed("data.bed", X)
#' 
#' # The following example is more detailed but also more awkward
#' # because (only for these examples) the package must create the file in a *temporary* location
#' 
#' file_out <- tempfile('delete-me-example', fileext = '.bed') # will also work without extension
#' # create 10 random genotypes
#' X <- rbinom(10, 2, 0.5)
#' # replace 3 random genotypes with missing values
#' X[sample(10, 3)] <- NA
#' # turn into 5x2 matrix
#' X <- matrix(X, nrow = 5, ncol = 2)
#' # write this data to file in BED format
#' # (only *.bed gets created, no *.fam or *.bim in this call)
#' write_bed(file_out, X)
#' # delete output when done
#' file.remove(file_out)
#'
#' @seealso
#' [write_plink()] for writing a set of BED/BIM/FAM files.
#' 
#' Plink BED format reference:
#' <https://www.cog-genomics.org/plink/1.9/formats#bed>
#'
#' @export
write_bed <- function(file, X, verbose = TRUE, append = FALSE) {
    # die if things are missing
    if (missing(file))
        stop('Output file path is required!')
    if (missing(X))
        stop('Genotype matrix (X) is required!')
    
    # make sure X is a matrix
    if (!is.matrix(X))
        stop('Genotypes (X) must be a matrix!')

    # make sure append is a scalar logical, so Rcpp never dies mysteriously
    if ( length( append ) > 1 )
        stop('`append` must be a scalar. Instead got length: ', length( append ) )
    if ( !is.logical( append ) )
        stop('`append` must be logical.  Instead got class: ', class( append ) )
    
    # add bed extension if it wasn't already there
    file <- add_ext(file, 'bed')
    
    # let's test if file exists
    # if it does, and we want to append, then that's as it should be
    # if it doesn't exist, treat as non-append (so Rcpp code adds header first time)
    # (testing for file existence is more painful within Rcpp, so meh)
    if ( append && !file.exists( file ) )
        append <- FALSE
    
    # announce what we ended up writing, nice to know
    if (verbose) {
        if (append) {
            message('Appending: ', file)
        } else {
            message('Writing: ', file)
        }
    }
    
    # C++ doesn't work with tildes in names, so let's expand path before we pass to C++
    file <- path.expand( file )

    # one issue that C++ code handles poorly is when file is in a directory that doesn't exist
    # check for that here and die gracefully in R if it's the trouble case
    dir_out <- dirname( file )
    if ( !dir.exists( dir_out ) )
        stop( 'Output directory does not exist: ', dir_out )
    
    # process and write in Rcpp!
    # at least an order of magnitude faster than my best pure R solution
    write_bed_cpp(file, X, append = append)
}
