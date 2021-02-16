#' Write GCTA GRM binary files
#'
#' This function writes a GCTA Genetic Relatedness Matrix (GRM, i.e. kinship) set of files in their binary format, given a kinship matrix and, if available, the corresponding matrix of pair sample sizes (non-trivial under missingness) and individuals table.
#'
#' @param name The base name of the output files.  Files with that base and extensions `.grm.bin`, `.grm.N.bin`, and `.grm.id` may be created depending on the data provided.
#' @param kinship The symmetric `n`-times-`n` kinship matrix to write into file with extension `.grm.bin`.
#' @param M The optional symmetric `n`-times-`n` matrix of pair sample sizes to write into file with extension `.grm.N.bin`.
#' @param fam The optional data.frame or tibble with individual annotations (columns with names `fam` and `id`, subset of columns of Plink FAM) to write into file with extension `.grm.id`.
#' If `fam` is `NULL` but `kinship` has non-`NULL` column or row names, these are used as the second (`id`) value in the output table (the first (`fam`) column is set to the missing value in this case).
#' @param verbose If `TRUE` (default), function reports the path of the files being written.
#'
#' @examples
#' # to write existing data `kinship`, `M`, and `fam` into files "data.grm.bin" etc, run like this:
#' # write_grm("data", kinship, M = M, fam = fam )
#' 
#' # The following example is more detailed but also more awkward
#' # because (only for these examples) the package must create the file in a *temporary* location
#' 
#' # create dummy data to write
#' # kinship for 3 individuals
#' kinship <- matrix(
#'     c(
#'         0.6, 0.2, 0.0,
#'         0.2, 0.5, 0.1,
#'         0.0, 0.1, 0.5
#'     ),
#'     nrow = 3
#' )
#' # pair sample sizes matrix
#' M <- matrix(
#'     c(
#'         10, 9, 8,
#'          9, 9, 7,
#'          8, 7, 8
#'     ),
#'     nrow = 3
#' )
#' # individual annotations table
#' library(tibble)
#' fam <- tibble(
#'     fam = 1:3,
#'     id = 1:3
#' )
#' # dummy files to write and delete
#' name <- tempfile('delete-me-example') # no extension
#' # write the data now!
#' write_grm( name, kinship, M = M, fam = fam )
#' # delete outputs when done
#' delete_files_grm( name )
#' 
#' @seealso
#' [read_grm()]
#' 
#' @export
write_grm <- function( name, kinship, M = NULL, fam = NULL, verbose = TRUE ) {
    # test presence of required data
    if ( missing( name ) )
        stop('Base `name` for GRM files is required!')
    if ( missing( kinship ) )
        stop('`kinship` is required!')
    # other sanity checks
    if ( !is.matrix( kinship ) )
        stop('`kinship` must be a matrix!')
    n_ind <- nrow( kinship )
    if ( ncol( kinship ) != n_ind )
        stop('`kinship` must be a square matrix!')
    if ( !isSymmetric( kinship ) )
        stop('`kinship` must be a symmetric matrix!')

    # validate other things before writing anything
    # validate pair sample size matrix
    if ( !is.null( M ) ) {
        if ( !is.matrix( M ) )
            stop('`M` must be a matrix!')
        if ( ncol( M ) != n_ind || nrow( M ) != n_ind )
            stop('`M` and `kinship` dimensions must agree!')
        if ( !isSymmetric( M ) )
            stop('`M` must be a symmetric matrix!')
    }
    # validate FAM matrix, or create a reasonable default if possible otherwise
    if ( !is.null( fam ) ) {
        if ( !is.data.frame( fam ) )
            stop('`fam` must be a data.frame, tibble, or equivalent!')
        if ( nrow( fam ) != n_ind )
            stop('`fam` and `kinship` must have the same number of rows!')
        if ( is.null( fam[['fam']] ) )
            stop('`fam` must have a column with name `fam`!')
        if ( is.null( fam[['id']] ) )
            stop('`fam` must have a column with name `id`!')
    } else {
        # create a reasonable fam, if `kinship` has column or row names
        # create FAM, filling in the usual defaults for column `fam` in this case
        if ( !is.null( colnames( kinship ) ) ) {
            fam <- make_fam( tibble::tibble( id = colnames( kinship ) ) )
        } else if ( !is.null( rownames( kinship ) ) ) {
            fam <- make_fam( tibble::tibble( id = rownames( kinship ) ) )
        }
        # else fam stays NULL
    }

    # ready to write files!
    
    # complete output paths
    file_bin <- paste0( name, ".grm.bin" )
    file_sizes <- paste0( name, ".grm.N.bin" )

    # write the kinship matrix
    if (verbose)
        message('Writing: ', file_bin)
    # turn matrix into a vector, with entries in the same order that GCTA reads them (according to their sample script)
    kinship_vec <- mat_sym_to_vec( kinship )
    # number of pairs, including diagonal
    n2 <- n_ind * ( n_ind + 1 ) / 2
    # sanity check
    stopifnot( length( kinship_vec ) == n2 )
    con_bin <- file( file_bin, "wb" )
    # this is the magic!
    # write the vector of length n*(n+1)/2
    writeBin( kinship_vec, con_bin, size = 4 )
    close( con_bin )

    # write the pair sample size matrix if available
    if ( !is.null( M ) ) {
        if (verbose)
            message('Writing: ', file_sizes)
        # turn matrix into a vector, with entries in the same order that GCTA reads them (according to their sample script)
        M_vec <- mat_sym_to_vec( M )
        # must encode ints as doubles for the correct data to get written (ints get encoded wrong!)
        class( M_vec ) <- 'double'
        # sanity check
        stopifnot( length( M_vec ) == n2 )
        con_sizes <- file( file_sizes, "wb" )
        # this is the magic!
        # write the vector of length n*(n+1)/2
        writeBin( M_vec, con_sizes, size = 4 )
        close( con_sizes )
    }

    # write FAM table if available
    if ( !is.null( fam ) ) {
        # this generic writer does all the magic
        write_tab_generic(
            file = name,
            tib = fam,
            ext = 'grm.id',
            tib_names = c('fam', 'id'),
            verbose = verbose
        )
    }
}
