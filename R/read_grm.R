#' Read GCTA GRM binary files
#'
#' This function reads a GCTA Genetic Relatedness Matrix (GRM, i.e. kinship) set of files in their binary format, returning the kinship matrix and, if available, the corresponding matrix of pair sample sizes (non-trivial under missingness) and individuals table.
#'
#' @param name The base name of the input files.  Files with that base and extensions `.grm.bin`, `.grm.N.bin`, and `.grm.id` are read if they exist.  Only `.grm.bin` is absolutely required; `.grm.id` can be substituted by the number of individuals (see below); `.grm.N.bin` is entirely optional.
#' @param n_ind The number of individuals, required if the file with the extension `.grm.id` is missing.  If the file with the `.grm.id` extension is present, then this `n_ind` is ignored.
#' @param verbose If TRUE (default) function reports the path of the files being loaded.
#'
#' @return A list with named elements:
#' 
#' - `kinship`: The symmetric `n`-times-`n` kinship matrix (GRM).  Has IDs as row and column names if the file with extension `.grm.id` was available.
#' - `M`: The symmetric `n`-times-`n` matrix of pair sample sizes (number of non-missing loci pairs), if the file with extension `.grm.N.bin` was available.  Has IDs as row and column names if the file with extension `.grm.id` was available.
#' - `fam`: A tibble with two columns: `fam` and `id`, same as in plink FAM files.  Returned if the file with extension `.grm.id` was available.
#'
#' @examples
#' # read an existing set of GRM files
#' file <- system.file("extdata", 'sample.grm.bin', package = "genio", mustWork = TRUE)
#' file <- sub('\\.grm\\.bin$', '', file) # remove extension from this path on purpose
#' obj <- read_grm(file)
#' stopifnot( !is.null( obj$kinship ) ) # the kinship matrix
#' stopifnot( !is.null( obj$M ) )       # the pair sample sizes matrix
#' stopifnot( !is.null( obj$fam ) )     # the fam and ID tibble
#' 
#' @seealso
#' Greatly adapted from sample code from GCTA:
#' \url{https://cnsgenomics.com/software/gcta/#MakingaGRM}
#' 
#' @export
read_grm <- function( name, n_ind = NA, verbose = TRUE ) {
    if ( missing( name ) )
        stop('Base `name` for GRM files is required!')
    # complete paths
    file_bin <- paste0( name, ".grm.bin" )
    file_sizes <- paste0( name, ".grm.N.bin" )
    file_fam <- paste0( name, ".grm.id" )
    # only the binary file is required
    if ( !file.exists( file_bin ) )
        stop( 'Required file missing: ', file_bin )

    # read IDs, if present
    fam <- NULL
    if ( file.exists( file_fam ) ) {
        # this is a table with two columns (family and id)
        fam <- read_tab_generic(
            file = name,
            ext = 'grm.id',
            tib_names = c('fam', 'id'),
            col_types = 'cc',
            verbose = verbose
        )
        # get number of individuals
        n_ind <- nrow( fam )
    } else if ( is.na( n_ind ) ) {
        stop('Either `n_ind` or the IDs file are required: ', file_fam)
    }
    # number of pairs, including diagonal
    n2 <- n_ind * ( n_ind + 1 ) / 2
    
    # read actual kinship values!
    if (verbose)
        message('Reading: ', file_bin)
    con_bin <- file( file_bin, "rb" )
    # this is the magic!
    # returns a vector of length n*(n+1)/2
    kinship_vec <- readBin( con_bin, n = n2, what = numeric(0), size = 4 )
    close( con_bin )
    # map to symmetric matrices as desired
    kinship <- vec_to_mat_sym( kinship_vec, n_ind )
    # add names (only IDs), if available
    if ( !is.null( fam ) ) {
        colnames( kinship ) <- fam$id
        rownames( kinship ) <- fam$id
    }
    
    # prepare return value
    # the kinship matrix is the only required data
    obj <- list( kinship = kinship )

    # read sample sizes matrix, if present
    if ( file.exists( file_sizes ) ) {
        if (verbose)
            message('Reading: ', file_sizes)
        con_sizes <- file( file_sizes, "rb" )
        M_vec <- readBin( con_sizes, n = n2, what = numeric(0), size = 4 )
        close( con_sizes )
        # map to symmetric matrices as desired
        M <- vec_to_mat_sym( M_vec, n_ind )
        # add names (only IDs), if available
        if ( !is.null( fam ) ) {
            colnames( M ) <- fam$id
            rownames( M ) <- fam$id
        }
        # add to return value
        obj$M <- M
    }

    # add IDS data to the very end
    if ( !is.null( fam ) )
        obj$fam <- fam

    # return all of the available data
    return( obj )
}
