# internal function, used by write_grm only
mat_sym_to_vec <- function( mat, strict = FALSE ) {
    if ( missing(mat) )
        stop('Input symmetric matrix `mat` is required!')
    # must be a matrix
    if ( !is.matrix(mat) )
        stop('Input `mat` is not a matrix!')
    # check that input is indeed symmetric
    # for now uses default tolerance
    if ( !isSymmetric(mat) )
        stop('Input matrix `mat` is not symmetric!')
    
    # this obvious reversal of the code in vec_to_mat_sym does it!
    x <- mat[ upper.tri( mat, diag = !strict ) ]
    
    # return vector
    return( x )
}
