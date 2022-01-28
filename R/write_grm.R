#' Write GCTA GRM and related plink2 binary files
#'
#' This function writes a GCTA Genetic Relatedness Matrix (GRM, i.e. kinship) set of files in their binary format, given a kinship matrix and, if available, the corresponding matrix of pair sample sizes (non-trivial under missingness) and individuals table.
#' Setting some options allows writing plink2 binary kinship formats such as "king" (follow examples in [read_grm()]).
#'
#' @param name The base name of the output files.
#' Files with that base, plus shared extension (default "grm", see `ext` below), plus extensions `.bin`, `.N.bin`, and `.id` may be created depending on the data provided.
#' @param kinship The symmetric `n`-times-`n` kinship matrix to write into file with extension `.<ext>.bin`.
#' @param M The optional symmetric `n`-times-`n` matrix of pair sample sizes to write into file with extension `.<ext>.N.bin`.
#' @param fam The optional data.frame or tibble with individual annotations (columns with names `fam` and `id`, subset of columns of Plink FAM) to write into file with extension `.<ext>.id`.
#' If `fam` is `NULL` but `kinship` has non-`NULL` column or row names, these are used as the second (`id`) value in the output table (the first (`fam`) column is set to the missing value in this case).
#' @param verbose If `TRUE` (default), function reports the path of the files being written.
#' @param ext Shared extension for all three outputs (see `name` above; default "grm").
#' Another useful value is "king", to match the KING-robust format produced by plink2.
#' If `NA`, no extension is added.
#' If given `ext` is also present at the end of `name`, then it is not added again.
#' @param shape The shape of the information to write (may be abbreviated).
#' Default "triangle" assumes there are `n*(n+1)/2` values to write corresponding to the upper triangle including the diagonal (required for GCTA GRM).
#' "strict_triangle" assumes there are `n*(n-1)/2` values to write corresponding to the upper triangle *excluding* the diagonal (best for plink2 KING-robust).
#' Lastly, "square" assumes there are `n*n` values to write corresponding to the entire square matrix, ignoring symmetry.
#' @param size_bytes The number of bytes per number encoded.
#' Default 4 corresponds to GCTA GRM and plink2 "bin4", whereas plink2 "bin" requires a value of 8.
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
write_grm <- function(
                      name,
                      kinship,
                      M = NULL,
                      fam = NULL,
                      verbose = TRUE,
                      ext = 'grm',
                      shape = c('triangle', 'strict_triangle', 'square'),
                      size_bytes = 4
                      ) {
    # test presence of required data
    if ( missing( name ) )
        stop('Base `name` for output files is required!')
    if ( missing( kinship ) )
        stop('`kinship` is required!')
    # other sanity checks
    if ( !is.matrix( kinship ) )
        stop('`kinship` must be a matrix!')
    n_ind <- nrow( kinship )
    if ( ncol( kinship ) != n_ind )
        stop('`kinship` must be a square matrix!')
    shape <- match.arg( shape )
    if ( shape != 'square' && !isSymmetric( kinship ) )
        stop('`kinship` must be a symmetric matrix unless shape="square"!')
    
    # validate other things before writing anything
    # validate pair sample size matrix
    if ( !is.null( M ) ) {
        if ( !is.matrix( M ) )
            stop('`M` must be a matrix!')
        if ( ncol( M ) != n_ind || nrow( M ) != n_ind )
            stop('`M` and `kinship` dimensions must agree!')
        if ( shape != 'square' && !isSymmetric( M ) )
            stop('`M` must be a symmetric matrix unless shape="square"!')
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
    
    # add shared extension to files, if given and not redundant with name
    name <- add_ext( name, ext )
    # complete output paths
    file_bin <- paste0( name, ".bin" )
    file_sizes <- paste0( name, ".N.bin" )
    file_fam <- paste0( name, ".id" )

    # calculate number of values expected
    # triangle includes diagonal
    # strict triangle (i.e. for king) excludes diagonal!
    n2 <- switch(
        shape,
        square = n_ind^2,
        triangle = n_ind * ( n_ind + 1 ) / 2,
        strict_triangle = n_ind * ( n_ind - 1 ) / 2
    )
    
    # write the kinship matrix
    write_grm_single(
        file = file_bin,
        kinship = kinship,
        n2 = n2,
        shape = shape,
        size_bytes = size_bytes,
        verbose = verbose
    )

    # write the pair sample size matrix if available
    if ( !is.null( M ) ) {
        write_grm_single(
            file = file_sizes,
            kinship = M,
            n2 = n2,
            shape = shape,
            size_bytes = size_bytes,
            verbose = verbose
        )
    }
    
    # write FAM table if available
    if ( !is.null( fam ) ) {
        # this generic writer does all the magic
        write_tab_generic(
            file = file_fam,
            tib = fam,
            ext = NA,
            tib_names = c('fam', 'id'),
            verbose = verbose
        )
    }
}
