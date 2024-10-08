#' Read a genotype matrix in Plink BED format
#'
#' This function reads genotypes encoded in a Plink-formatted BED (binary) file, returning them in a standard R matrix containing genotypes encoded numerically as dosages (values in `c( 0, 1, 2, NA )`).
#' Each genotype per locus (`m` loci) and individual (`n` total) counts the number of reference alleles, or `NA` for missing data.
#' No *.fam or *.bim files are read by this basic function.
#' Since BED does not encode the data dimensions internally, these values must be provided by the user.
#'
#' The code enforces several checks to validate data given the requested dimensions.
#' Errors are thrown if file terminates too early or does not terminate after genotype matrix is filled.
#' In addition, as each locus is encoded in an integer number of bytes, and each byte contains up to four individuals, bytes with fewer than four are padded.
#' To agree with other software (plink2, BEDMatrix), byte padding values are ignored (may take on any value without causing errors).
#'
#' This function only supports locus-major BED files, which are the standard for modern data.
#' Format is validated via the BED file's magic numbers (first three bytes of file).
#' Older BED files can be converted using Plink.
#' 
#' @param file Input file path.
#' *.bed extension may be omitted (will be added automatically if `file` doesn't exist but `file`.bed does).
#' See `ext` option below.
#' @param names_loci Vector of loci names, to become the row names of the genotype matrix.
#' If provided, its length sets `m_loci` below.
#' If `NULL`, the returned genotype matrix will not have row names, and `m_loci` must be provided.
#' @param names_ind Vector of individual names, to become the column names of the genotype matrix.
#' If provided, its length sets `n_ind` below.
#' If `NULL`, the returned genotype matrix will not have column names, and `n_ind` must be provided.
#' @param m_loci Number of loci in the input genotype table.
#' Required if `names_loci = NULL`, as its value is not deducible from the BED file itself.
#' Ignored if `names_loci` is provided.
#' @param n_ind Number of individuals in the input genotype table.
#' Required if `names_ind = NULL`, as its value is not deducible from the BED file itself.
#' Ignored if `names_ind` is provided.
#' @param ext The desired file extension (default "bed").
#' Ignored if `file` points to an existing file.
#' Set to `NA` to force `file` to exist as-is.
#' @param verbose If `TRUE` (default) function reports the path of the file being read (after autocompleting the extension).
#'
#' @return The `m`-by-`n` genotype matrix.
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
#' 
#' # read an existing Plink *.bim file
#' # pass locus and individual IDs as vectors, setting data dimensions too
#' X <- read_bed(file_bed, bim$id, fam$id)
#' X
#'
#' # can specify without extension
#' file_bed <- sub('\\.bed$', '', file_bed) # remove extension from this path on purpose
#' file_bed # verify .bed is missing
#' X <- read_bed(file_bed, bim$id, fam$id) # loads too!
#' X
#' 
#' @seealso
#' [read_plink()] for reading a set of BED/BIM/FAM files.
#'
#' [geno_to_char()] for translating numerical genotypes into more human-readable character encodings.
#' 
#' Plink BED format reference:
#' <https://www.cog-genomics.org/plink/1.9/formats#bed>
#'
#' @export
read_bed <- function(file, names_loci = NULL, names_ind = NULL, m_loci = NA, n_ind = NA, ext = 'bed', verbose = TRUE) {
    # die if things are missing
    if (missing(file))
        stop('Input file path is required!')

    # set dimensions via names if provided
    if ( !is.null(names_loci) ) {
        m_loci <- length( names_loci )
    } else {
        if (is.na(m_loci))
            stop('Either `names_loci` or number of loci (`m_loci`) is required!')
    }
    if ( !is.null(names_ind) ) {
        n_ind <- length( names_ind )
    } else {
        if (is.na(n_ind))
            stop('Either `names_ind` or number of individuals (`n_ind`) is required!')
    }
    
    # add bed extension if it wasn't already there
    file <- add_ext_read(file, ext)
    
    # announce what we ended up loading, nice to know
    if (verbose)
        message('Reading: ', file)

    # C++ doesn't work with tildes in names, so let's expand path before we pass to C++
    file <- path.expand(file)

    # before passing it to c++ function, make sure it exists
    # C++ does its own check, but on very long paths the buffer overflows
    if ( !file.exists( file ) )
        stop( 'File does not exist: ', file )
    
    # read in Rcpp!
    X <- read_bed_cpp(file, m_loci, n_ind)

    # add row and/or column names if available
    if ( !is.null(names_loci) )
        rownames(X) <- names_loci
    if ( !is.null(names_ind) )
        colnames(X) <- names_ind
    
    # return!
    return ( X )
}
