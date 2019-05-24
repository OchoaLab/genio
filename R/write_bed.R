#' @useDynLib genio
#' @importFrom Rcpp sourceCpp
NULL

#' Write a genotype matrix into plink BED format
#'
#' This function accepts a standard R matrix containing genotypes (values in \code{c(0,1,2,NA)}) and writes it into a plink-formatted BED (binary) file.
#' Each genotype per locus (m loci) and individual (n total) counts the number of alternative alleles or \code{NA} for missing data.
#' No *.fam or *.bim files are created by this basic function.
#'
#' Genotypes with values outside of \eqn{[0,2]} cause an error, in which case the partial output is deleted.
#' However, beware that decimals get truncated internally, so values that truncate to 0, 1, or 2 will not raise errors.
#' The BED format does not accept fractional dosages, so such data will not be written as expected.
#' 
#' @param file Output file path.  .bed extension may be omitted (will be added automatically if it is missing).
#' @param X The \eqn{m \times n}{m-by-n} genotype matrix.
#' Row and column names, if present, are ignored.
#' @param verbose If TRUE (default) function reports the path of the file being written (after autocompleting the extension).
#'
#' @return Nothing
#'
#' @examples
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
#' \code{\link{write_plink}} for writing a set of BED/BIM/FAM files.
#' 
#' Plink BED format reference:
#' \url{https://www.cog-genomics.org/plink/1.9/formats#bed}
#'
#' @export
write_bed <- function(file, X, verbose = TRUE) {
    # die if things are missing
    if (missing(file))
        stop('Output file path is required!')
    if (missing(X))
        stop('Genotype matrix (X) is required!')
    
    # make sure X is a matrix
    if (!is.matrix(X))
        stop('Genotypes (X) must be a matrix!')
    
    # add bed extension if it wasn't already there
    file <- add_ext(file, 'bed')
    
    # announce what we ended up writing, nice to know
    if (verbose)
        message('Writing: ', file)
    
    # process and write in Rcpp!
    # at least an order of magnitude faster than my best pure R solution
    write_bed_cpp(file, X)
}
