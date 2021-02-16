#' Create a tidy version of a kinship matrix
#'
#' A square symmetric kinship matrix is transformed into a tibble, with a row per unique element in the kinship matrix, and three columns: ID of row, ID of column, and the kinship value.
#'
#' @param kinship The `n`-by-`n` symmetric kinship matrix
#' @param sort If `TRUE` (default), rows are sorted ascending by kinship value.
#' Otherwise, order is moving along the upper triangle row-by-row
#'
#' @return A tibble with `n * ( n + 1 ) / 2` rows (the upper triangle, including the diagonal), and 3 columns with names: `id1`, `id2`, `kinship`.
#'
#' @examples
#' # create a symmetric matrix
#' kinship <- matrix(
#'     c(
#'         0.5, 0.1, 0.0,
#'         0.1, 0.5, 0.2,
#'         0.0, 0.2, 0.6
#'     ),
#'     nrow = 3
#' )
#' # add names (best for tidy version)
#' colnames(kinship) <- paste0('pop', 1:3)
#' rownames(kinship) <- paste0('pop', 1:3)
#' # this returns tidy version
#' kinship_tidy <- tidy_kinship( kinship )
#' # test colnames
#' stopifnot( colnames( kinship_tidy ) == c('id1', 'id2', 'kinship') )
#' # test row number
#' stopifnot( nrow( kinship_tidy ) == 6 )
#' # inspect it
#' kinship_tidy
#' 
#' @export
tidy_kinship <- function( kinship, sort = TRUE ) {
    # produces a tidy version of a symmetric matrix
    # uses col/rownames as IDs, or indexes if they are missing

    # NOTE: there are cool solutions out there, but all repeat entries for a symmetric matrix
    # https://stackoverflow.com/questions/42810376/what-is-the-best-way-to-tidy-a-matrix-in-r
    # my version does not repeat entries, assumes symmetry

    # limited validations
    # expect square
    n_ind <- nrow(kinship)
    if( n_ind != ncol(kinship) )
        stop('Input must be a square matrix')
    # get IDs, make sure both dimensions match
    ids <- colnames(kinship)
    if ( is.null(ids) ) {
        # use indexes in this case
        warning('`kinship` has no `colnames`!  Using indexes as IDs...')
        ids <- 1 : n_ind
    } else {
        # make sure IDs match both ways
        if ( any( ids != rownames(kinship)) )
            stop('`colnames` and `rownames` of kinship must match!')
    }

    # final length (all different pairs, plus self pair)
    n_pairs <- n_ind * ( n_ind + 1 ) / 2
    # the data we want
    ids1 <- vector('character', n_pairs)
    ids2 <- vector('character', n_pairs)
    kinship_vec <- vector('numeric', n_pairs)
    # navigate pairs without repeats, but include self-pair
    # assume square matrix with equal populations on both sides
    k <- 0 # pair counter
    for (i in 1 : n_ind) {
        pi <- ids[i]
        for (j in i : n_ind) {
            pj <- ids[j]
            # increment pair counter
            k <- k + 1
            # add to data
            ids1[k] <- pi
            ids2[k] <- pj
            kinship_vec[k] <- kinship[i, j]
        }
    }
    # arrange into tibble
    kinship_tidy <- tibble::tibble(
        id1 = ids1,
        id2 = ids2,
        kinship = kinship_vec
    )
    # it's nice to sort by value
    if (sort) {
        indexes <- order( kinship_tidy$kinship )
        kinship_tidy <- kinship_tidy[ indexes, ]
    }
    # return
    return( kinship_tidy )
}
