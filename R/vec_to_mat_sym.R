# internal function, used by read_grm only
vec_to_mat_sym <- function(x, n) {
    if ( missing(x) )
        stop('Input vector `x` is required!')
    if ( missing(n) )
        stop('Number of individuals `n` is required!')
    
    # turns a vector as GCTA writes it into a symmetric matrix
    # sanity check
    n2 <- n*(n+1)/2
    if ( length(x) != n2 )
        stop('Input vector does not have expected length: ', length(x), ' != ', n2 )

    # create square matrix
    mat <- matrix(NA, nrow = n, ncol = n)
    # assigning this way works!
    mat[ upper.tri(mat, diag = TRUE) ] <- x
    # copy lower triangle, but do this by transposition (safest)
    indexes <- lower.tri(mat)
    mat[ indexes ]  <- t(mat)[ indexes ]
    # return final matrix
    return( mat )
}
