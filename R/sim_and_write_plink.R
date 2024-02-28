#' Simulate and write genotypes to plink format on the fly
#'
#' To save memory, simulate small chunks of variants at the time and write them to file as you go.
#' This is a wrapper around [write_plink()] and [readr::write_lines()] (for ancestral allele frequencies, optional) with `append = TRUE` that simplifies looping somewhat.
#' The function always appends to the output, so it can be called several times if convenient, for example to simulate separate chromosomes.
#'
#' @param sim_chunk A function that generates a small number of loci at the time, to be called iteratively until the whole genome is complete.  It should accept a single parameter, the number of loci to simulate at one time, and returns a list with these named elements:
#' - `X`: the simulated genotype matrix, with the desired number of loci and the same individuals in every call.  Required.
#' - `bim`: the simulated variant table for the loci that were just simulated.  Required.
#' - `p_anc`: the vector of ancestral allele frequencies (required for simulating traits with correctly specified heritabilities).  Optional.
#' @param m_loci Total number of loci to simulate.
#' @param fam Sample table of simulation to write.
#' @param file Output file path, without extensions (each of .bed, .bim, .fam extensions will be added automatically as needed).
#' @param file_p_anc Complete file path (with extensions) of vector of ancestral allele frequencies, if `sim_chunk` generates them (optional).
#' This file is created with [readr::write_lines()], so it is a plain text file with each line being the ancestral allele frequency of each locus in order, and it may be compressed if this file has a .gz extension.
#' @param n_data_cut Number of cells (individuals times loci) to aim to simulate at the time.  Actual number may be smaller to ensure that the number of loci is an integer, except if the number of individuals is greater than `n_data_cut` then a single locus will be simulated at the time (and the number of cells will be greater than `n_data_cut`).
#'
#' @examples
#'
#' # some global constants that will be accessed by simulator function
#' n <- 10
#' # and a global variable updated as we go
#' m_last <- 0
#' 
#' # define a trivial but complete genotype simulator function
#' my_sim_chunk <- function( m_chunk ) {
#'     # construct ancestral allele frequencies
#'     p_anc <- runif( m_chunk )
#'     # simulate genotypes from HWE
#'     X <- matrix( rbinom( m_chunk * n, 2, p_anc ), m_chunk, n )
#'     # construct a trivial BIM table
#'     bim <- make_bim( n = m_chunk )
#'     # but make sure count continues across chunks without repeats
#'     # (so IDs and positions don't clash!)
#'     bim$id <- m_last + ( 1 : m_chunk )
#'     # update global value (use <<-) for next round
#'     m_last <<- m_last + m_chunk
#'     # return all of these elements in a named list!
#'     return( list( X = X, bim = bim, p_anc = p_anc ) )
#' }
#'
#' # the fam table is created fully now
#' fam <- make_fam( n = n )
#' # set other parameters
#' m_loci <- 100
#'
#' # this is only necessary for example files to be in a *temporary* location
#' # (don't use `tempfile` in real cases)
#' # plink files path without extension
#' file <- tempfile('test')
#' # p_anc file should have extension
#' filep <- tempfile('test-p-anc.txt.gz')
#' 
#' # simulate and write as we go!
#' sim_and_write_plink( my_sim_chunk, m_loci, fam, file, filep )
#'
#' # clean up: delete sample outputs
#' delete_files_plink( file )
#' file.remove( filep )
#'
#' @seealso
#' [write_plink()]
#' 
#' @export
sim_and_write_plink <- function( sim_chunk, m_loci, fam, file, file_p_anc = NA, n_data_cut = 10^6 ) {
    # validate inputs
    # these are required
    if ( missing( sim_chunk ) )
        stop( '`sim_chunk` is required!' )
    if ( missing( m_loci ) )
        stop( '`m_loci` is required!' )
    if ( missing( fam ) )
        stop( '`fam` is required!' )
    if ( missing( file ) )
        stop( '`file` is required!' )
    # further validations
    if ( !is.function( sim_chunk ) )
        stop( '`sim_chunk` must be a function!' )
    if ( !is.numeric( m_loci ) )
        stop( '`m_loci` must be numeric!' )
    if ( length( m_loci ) != 1 )
        stop( '`m_loci` must be a scalar!' )
    if ( !is.data.frame( fam ) )
        stop( '`fam` must be a data frame (including tibble)' )
    if ( !is.character( file ) )
        stop( '`file` must be a string!' )
    if ( length( file ) != 1 )
        stop( '`file` must be a scalar!' )
    # file_p_anc is optional, test if not NA
    if ( !is.na( file_p_anc ) ) {
        if ( !is.character( file_p_anc ) )
            stop( '`file_p_anc` must be a string!' )
        if ( length( file_p_anc ) != 1 )
            stop( '`file_p_anc` must be a scalar!' )
    }
    # further fam validations will be performed by write_plink

    # calculate chunk size
    m_chunk <- floor( n_data_cut / nrow( fam ) )
    # should at least have one locus, so fix if that's the case (and hope for the best, memory-wise)
    if ( m_chunk < 1 )
        m_chunk <- 1

    # now process each chunk
    # keep track of how much is left
    m_loci_left <- m_loci
    while ( m_loci_left > 0 ) {
        # use the standard chunk size here, unless we have fewer loci left (at the end)
        m_chunk_i <- if ( m_loci_left > m_chunk ) m_chunk else m_loci_left
        
        # draw allele freqs and genotypes
        out <- sim_chunk( m_chunk_i )
        # validate first time only, assume it works every time afterwards
        if ( m_loci_left == m_loci ) {
            if ( !is.list( out ) )
                stop( 'Function `sim_chunk` must return a list!' )
            if ( ! 'X' %in% names( out ) )
                stop( '`sim_chunk` return list must include genotypes named "X"!' )
            if ( ! 'bim' %in% names( out ) )
                stop( '`sim_chunk` return list must include variant table named "bim"!' )
            # p_anc is optional, but save it if present!
            if ( 'p_anc' %in% names( out ) )
                if ( is.na( file_p_anc ) )
                    stop( '`sim_chunk` returned `p_anc` but `file_p_anc` was not provided!' )
        }
        
        # append to plink BED/BIM/FAM 
        write_plink(
            file,
            X = out$X,
            bim = out$bim,
            fam = fam,
            verbose = FALSE,
            append = TRUE
        )

        # append to p_anc file if we have the data
        # at this point we have required `file_p_anc` if it was needed, so just assume we can write it all out
        if ( 'p_anc' %in% names( out ) )
            readr::write_lines( out$p_anc, file_p_anc, append = TRUE )
        
        # decrement for next round
        m_loci_left <- m_loci_left - m_chunk_i
    }
}
