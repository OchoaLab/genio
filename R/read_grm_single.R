# reused to parse each of the grm.bin and grm.N.bin files, and related plink2 king and etc bin files
read_grm_single <- function(
                            file,
                            n_ind,
                            n2,
                            shape,
                            size_bytes,
                            fam,
                            verbose
                            ) {
    # some minimal validations, though the more serious validations should have been done earlier, outside this function
    if ( missing( file ) )
        stop( '`file` is required!' )
    if ( missing( n_ind ) )
        stop( '`n_ind` is required!' )
    if ( missing( n2 ) )
        stop( '`n2` is required!' )
    if ( missing( shape ) )
        stop( '`shape` is required!' )
    if ( missing( size_bytes ) )
        stop( '`size_bytes` is required!' )
    if ( missing( fam ) )
        stop( '`fam` is required!' )
    if ( missing( verbose ) )
        stop( '`verbose` is required!' )
    if ( !file.exists( file ) )
        stop( 'Required file missing: ', file )
    
    # read actual values!
    if (verbose)
        message('Reading: ', file)
    
    # check sizes
    file_size_obs <- file.info( file )$size
    file_size_exp <- n2 * size_bytes
    if ( file_size_obs != file_size_exp )
        stop( 'File size (', file_size_obs, ') was not as expected (', file_size_exp, ')!  `shape` or `size_bytes` might need adjusting, or file might be corrupt.' )
    
    # otherwise parse it
    con_bin <- file( file, "rb" )
    # this is the magic!
    # returns a vector of length n2
    kinship_vec <- readBin( con_bin, n = n2, what = numeric(0), size = size_bytes )
    close( con_bin )
    
    # map to symmetric or given matrices as desired
    kinship <- switch(
        shape,
        triangle = vec_to_mat_sym( kinship_vec, n_ind ),
        strict_triangle = vec_to_mat_sym( kinship_vec, n_ind, strict = TRUE ),
        square = matrix( kinship_vec, nrow = n_ind, ncol = n_ind )
    )
    
    # add names (only IDs), if available
    if ( !is.null( fam ) ) {
        colnames( kinship ) <- fam$id
        rownames( kinship ) <- fam$id
    }

    return( kinship )
}
