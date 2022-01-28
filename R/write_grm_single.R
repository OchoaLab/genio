write_grm_single <- function(
                             file,
                             kinship,
                             n2,
                             shape,
                             size_bytes,
                             verbose
                             ) {
    # some minimal validations, though the more serious validations should have been done earlier, outside this function
    if ( missing( file ) )
        stop( '`file` is required!' )
    if ( missing( kinship ) )
        stop( '`kinship` is required!' )
    if ( missing( n2 ) )
        stop( '`n2` is required!' )
    if ( missing( shape ) )
        stop( '`shape` is required!' )
    if ( missing( size_bytes ) )
        stop( '`size_bytes` is required!' )
    if ( missing( verbose ) )
        stop( '`verbose` is required!' )
    
    # write the kinship matrix
    if (verbose)
        message('Writing: ', file)
    
    # turn matrix into a vector, with entries in the same order that GCTA reads them (according to their sample script)
    # handle other shapes as needed
    kinship_vec <- switch(
        shape,
        triangle = mat_sym_to_vec( kinship ),
        strict_triangle = mat_sym_to_vec( kinship, strict = TRUE ),
        square = as.numeric( kinship ) # simple flattening works!
    )
    
    # check lengths just in case
    stopifnot( length( kinship_vec ) == n2 )
    
    # must encode ints as doubles for the correct data to get written (ints get encoded wrong!)
    # (this occurs for M matrix, not kinship)
    class( kinship_vec ) <- 'double'
    
    con_bin <- file( file, "wb" )
    # this is the magic!
    # write the vector of length n2
    writeBin( kinship_vec, con_bin, size = size_bytes )
    close( con_bin )
}
