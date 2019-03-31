#' @useDynLib genio
#' @importFrom Rcpp sourceCpp
NULL

#' Write a genotype matrix into plink BED format
#'
#' This function accepts a standard R matrix containing genotypes (values in \code{c(0,1,2,NA)}) and writes it into a plink-formatted BED (binary) file.
#' Each genotype per locus (m loci) and individual (n total) counts the number of alternative alleles or \code{NA} for missing data.
#' 
#' @param file Output file path.  .bed extension may be omitted (will be added automatically if it is missing).
#' @param X The \eqn{m \times n}{m-by-n} genotype matrix.
#'
#' @return Nothing
#'
#' @export
# BED format reference:
# https://www.cog-genomics.org/plink/1.9/formats#bed
write_bed <- function(file, X) {
    # die if things are missing
    if (missing(file))
        stop('Fatal: output file path is required!')
    if (missing(X))
        stop('Fatal: genotype matrix (X) is required!')
    # make sure X is a matrix
    if (!is.matrix(X))
        stop('Fatal: genotypes (X) must be a matrix!')
    # add bed extension if it wasn't already there
    file <- add_ext(file, 'bed')
    
    # process and write in Rcpp!
    # at least an order of magnitude faster than my best pure R solution
    write_bed_cpp(file, X)
}
