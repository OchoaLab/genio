#' Read a genotype matrix in plink BED format
#'
#' This function reads genotypes encoded in a plink-formatted BED (binary) file, returning them in a standard R matrix containing genotypes (values in \code{c(0,1,2,NA)}).
#' Each genotype per locus (m loci) and individual (n total) counts the number of alternative alleles or \code{NA} for missing data.
#' No *.fam or *.bim files are read by this basic function.
#' Since BED does not encode the data dimensions internally, these values must be provided by the user.
#'
#' The code enforces several checks to validate data given the requested dimensions.
#' Errors are thrown if file terminates too early or does not terminate after genotype matrix is filled.
#' In addition, as each locus is encoded in an integer number of bytes, and each byte contains up to four individuals, bytes with fewer than four are padded with zeroes (non-zero pads throw errors).
#'
#' This function only supports locus-major BED files, which are the standard for modern data.
#' Format is validated via the BED file's magic numbers (first three bytes of file).
#' Older BED files can be convered using plink.
#' 
#' @param file Input file path.
#' *.bed extension may be omitted (will be added automatically if it is missing).
#' @param m_loci Number of loci in the input genotype table.
#' User must provide this value, as it is not inferrable from the BED file itself.
#' @param n_ind Number of individuals in the input genotype table.
#' User must provide this value, as it is not inferrable from the BED file itself.
#' @param verbose If TRUE (default) function reports the path of the file being read (after autocompleting the extension).
#'
#' @return The \eqn{m \times n}{m-by-n} genotype matrix.
#'
#' @examples
#' # first obtain data dimensions from BIM and FAM files
#' # all file paths
#' file_bed <- system.file("extdata", 'sample.bed', package = "genio", mustWork = TRUE)
#' file_bim <- system.file("extdata", 'sample.bim', package = "genio", mustWork = TRUE)
#' file_fam <- system.file("extdata", 'sample.fam', package = "genio", mustWork = TRUE)
#' # read annotation tables
#' bim <- read_bim(file_bim)
#' fam <- read_fam(file_fam)
#' # dimensions are number of rows of each case
#' m_loci <- nrow(bim)
#' n_ind <- nrow(fam)
#' 
#' # read an existing plink *.bim file
#' X <- read_bed(file_bed, m_loci, n_ind)
#' X
#'
#' # can specify without extension
#' file_bed <- sub('\\.bed$', '', file_bed) # remove extension from this path on purpose
#' file_bed # verify .bed is missing
#' X <- read_bed(file_bed, m_loci, n_ind) # loads too!
#' X
#' 
#' @seealso
#' Plink BED format reference:
#' \url{https://www.cog-genomics.org/plink/1.9/formats#bed}
#'
#' @export
read_bed <- function(file, m_loci, n_ind, verbose = TRUE) {
    # die if things are missing
    if (missing(file))
        stop('Output file path is required!')
    if (missing(m_loci))
        stop('Number of loci (m_loci) is required!')
    if (missing(n_ind))
        stop('Number of individuals (n_ind) is required!')
    
    # add bed extension if it wasn't already there
    file <- add_ext(file, 'bed')
    
    # announce what we ended up loading, nice to know
    if (verbose)
        message('Reading: ', file)
    
    # read in Rcpp!
    X <- read_bed_cpp(file, m_loci, n_ind)
}
