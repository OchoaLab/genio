#' Reencode a Plink BED file to (twice) heterozygote indicators
#'
#' Given an existing plink-formatted BED (binary) file, this function reads it, transforms genotypes on the go, and writes a new BED file such that heterozygotes are encoded as 2 and homozygotes as 0.
#' In other words, it transforms the numerical genotype values `c( 0, 1, 2, NA )` into `c( 0, 2, 0, NA )`.
#' Heterozygotes are encoded as 2, rather than 1, so existing code for calculating allele frequencies and related quantities, such as kinship estimates, works on this data as intended.
#' Intended to transform extremely large files that should not be loaded entirely into memory at once.
#'
#' @param file_in Input file path.
#' *.bed extension may be omitted (will be added automatically if `file` doesn't exist but `file`.bed does).
#' @param file_out Output file path.
#' *.bed extension may be omitted (will be added automatically if it is missing).
#' @param m_loci Number of loci in the input genotype table.
#' If `NA`, it is deduced from the paired *.bim file
#' @param n_ind Number of individuals in the input genotype table.
#' If `NA`, it is deduced from the paired *.fam file
#' @param make_bim_fam If `TRUE`, create symbolic links (using [symlink()]) for the output file's *.bim and *.fam that link to the corresponding input files.
#' Otherwise only the *.bed file is created.
#' @param verbose If `TRUE` (default) function reports the path of the files being read and written to (after autocompleting the extension).
#'
#' @examples
#' # define input and output, both of which will also work without extension
#' # read an existing Plink *.bed file
#' file_in <- system.file("extdata", 'sample.bed', package = "genio", mustWork = TRUE)
#' # write to a *temporary* location for this example
#' file_out <- tempfile('delete-me-example')
#' 
#' # in default mode, deduces dimensions from paired *.bim and *.fam tables
#' het_reencode_bed( file_in, file_out )
#'
#' # delete output when done
#' delete_files_plink( file_out )
#' 
#' @seealso
#' [read_bed()] and [write_bed()], from which much of the code of this function is derived, which explains additional BED format requirements.
#'
#' @export
het_reencode_bed <- function(file_in, file_out, m_loci = NA, n_ind = NA, make_bim_fam = TRUE, verbose = TRUE) {
    # die if things are missing
    if ( missing( file_in ) )
        stop('Input file path is required!')
    if ( missing( file_out ) )
        stop('Output file path is required!')

    # below only works if name is missing bed extension
    name_in <- sub( '\\.bed$', '', file_in )
    name_out <- sub( '\\.bed$', '', file_out )
    
    # set dimensions via names if provided
    if ( is.na( m_loci ) )
        m_loci <- count_lines( name_in, 'bim', verbose = verbose )
    if ( is.na( n_ind ) )
        n_ind <- count_lines( name_in, 'fam', verbose = verbose )
    
    # add bed extensions if they weren't already there
    file_in <- add_ext_read( file_in, 'bed' )
    file_out <- add_ext( file_out, 'bed' )
    
    # C++ doesn't work with tildes in names, so let's expand paths before we pass to C++
    # (keep shorter versions around for messages and within-R extra processing below)
    file_in_full <- path.expand( file_in )
    file_out_full <- path.expand( file_out )

    # before passing it to c++ function, make sure it exists
    # C++ does its own check, but on very long paths the buffer overflows
    if ( !file.exists( file_in_full ) )
        stop( 'File does not exist: ', file_in_full )
    
    # announce what we ended up loading and writing, nice to know
    if ( verbose ) {
        message( 'Reading: ', file_in )
        message( 'Writing: ', file_out )
    }
    
    # apply Rcpp function now!
    het_reencode_bed_cpp( file_in_full, file_out_full, m_loci, n_ind )

    if ( make_bim_fam ) {
        # when done, add bim/fam symlinks!
        symlink( paste0( name_in, '.bim' ), paste0( name_out, '.bim' ), verbose = verbose )
        symlink( paste0( name_in, '.fam' ), paste0( name_out, '.fam' ), verbose = verbose )
    }
}

