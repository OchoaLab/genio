context("test-grm")

test_that("vec_to_mat_sym works on toy examples", {
    # test that there are errors when crucial data is missing
    expect_error(vec_to_mat_sym()) # all is missing
    expect_error(vec_to_mat_sym(x = 1))
    expect_error(vec_to_mat_sym(n = 1))
    # errors when lengths don't match
    expect_error(vec_to_mat_sym(x = 1:3, n = 1))

    # finally, a positive test
    expect_equal(
        vec_to_mat_sym(x = 1:3, n = 2),
        matrix(
            c(1, 2,
              2, 3),
            nrow = 2,
            ncol = 2
        )
    )
    # and a bigger example
    expect_equal(
        vec_to_mat_sym(x = 1:6, n = 3),
        matrix(
            c(1, 2, 4,
              2, 3, 5,
              4, 5, 6),
            nrow = 3,
            ncol = 3
        )
    )
})

test_that("mat_sym_to_vec works on toy examples", {
    # test that there are errors when crucial data is missing
    expect_error(mat_sym_to_vec()) # all is missing
    # errors when input is not actually a matrix
    expect_error(mat_sym_to_vec(mat = 1))
    expect_error(mat_sym_to_vec(mat = list(1)))
    
    # a positive result
    mat <- matrix(
        c(1, 2,
          2, 3),
        nrow = 2,
        ncol = 2
    )
    expect_equal(
        mat_sym_to_vec(mat),
        1:3
    )
    # and a bigger example
    mat <- matrix(
        c(1, 2, 4,
          2, 3, 5,
          4, 5, 6),
        nrow = 3,
        ncol = 3
    )
    expect_equal(
        mat_sym_to_vec(mat),
        1:6
    )
})

test_that("mat_sym_to_vec and vec_to_mat_sym invert each other", {
    # to make it all more challenging, create larger random examples
    # but not too large, tests should still be fast
    n <- 7
    mat <- matrix(
        runif(n),
        nrow = n,
        ncol = n
    )
    # make symmetric
    mat <- mat + t(mat)
    # test that original matrix is recovered turning into vector and back
    expect_equal(
        vec_to_mat_sym( mat_sym_to_vec(mat), n ),
        mat
    )

    # now the other way
    vec <- runif( n*(n+1)/2 )
    expect_equal(
        mat_sym_to_vec( vec_to_mat_sym( vec, n ) ),
        vec
    )
})

test_that("read_grm works on small random sample", {
    # expect error when file is missing
    expect_error( read_grm() )
    expect_error( read_grm( 'made-up-base' ) )

    # sim dimensions used in test too
    n_ind <- 7
    m_loci <- 10
    miss <- 0.1
    name <- paste0('dummy-', n_ind, '-', m_loci, '-', miss)

    # complete paths for files to move for tests further below
    file_sizes <- paste0( name, ".grm.N.bin" )
    file_ids <- paste0( name, ".grm.id" )
    file_sizes_tmp <- paste0( file_sizes, '-TMP' )
    file_ids_tmp <- paste0( file_ids, '-TMP' )
    # clean up after failed tests
    if ( !file.exists( file_sizes ) ) {
        if ( file.exists( file_sizes_tmp ) ) {
            expect_true( file.rename( file_sizes_tmp, file_sizes ) )
        } else 
            stop('Unexpected absence of file: ', file_sizes)
    }
    if ( !file.exists( file_ids ) ) {
        if ( file.exists( file_ids_tmp ) ) {
            expect_true( file.rename( file_ids_tmp, file_ids ) )
        } else 
            stop('Unexpected absence of file: ', file_ids)
    }
    
    # this reads real example, with everything present
    obj <- read_grm( name )
    # check overall object
    expect_equal( length( obj ), 3 )
    expect_equal( names( obj ), c('kinship', 'M', 'id') )
    # check individual objects
    # test kinship matrix
    expect_true( is.matrix( obj$kinship ) )
    expect_equal( ncol( obj$kinship ), n_ind ) # expected dimensions
    expect_equal( nrow( obj$kinship ), n_ind )
    expect_equal( obj$kinship, t( obj$kinship ) ) # symmetric
    # test pair sample sizes matrix
    expect_true( is.matrix( obj$M ) )
    expect_equal( ncol( obj$M ), n_ind ) # expected dimensions
    expect_equal( nrow( obj$M ), n_ind )
    expect_equal( obj$M, t( obj$M ) ) # symmetric
    expect_true( min(obj$M) > 0 ) # clear range expectations (these are counts)
    expect_true( max(obj$M) <= m_loci )
    # test IDs table
    expect_true( is_tibble( obj$id ) )
    expect_equal( ncol( obj$id ), 2 )
    expect_equal( nrow( obj$id ), n_ind )
    expect_equal( names( obj$id ), c('fam', 'id') )
    # match up names across matrices
    expect_equal( obj$id$id, colnames( obj$kinship ) )
    expect_equal( obj$id$id, rownames( obj$kinship ) )
    expect_equal( obj$id$id, colnames( obj$M ) )
    expect_equal( obj$id$id, rownames( obj$M ) )

    # temporarly move ID file, to test what happens when that is missing
    expect_true( file.rename( file_ids, file_ids_tmp ) )
    # all should work but there's no IDs
    # must provide n in this case!
    expect_error( read_grm( name ) )
    obj <- read_grm( name, n_ind = n_ind )
    # check overall object
    expect_equal( length( obj ), 2 )
    expect_equal( names( obj ), c('kinship', 'M') )
    # check individual objects
    # test kinship matrix
    expect_true( is.matrix( obj$kinship ) )
    expect_equal( ncol( obj$kinship ), n_ind ) # expected dimensions
    expect_equal( nrow( obj$kinship ), n_ind )
    expect_equal( obj$kinship, t( obj$kinship ) ) # symmetric
    # test pair sample sizes matrix
    expect_true( is.matrix( obj$M ) )
    expect_equal( ncol( obj$M ), n_ind ) # expected dimensions
    expect_equal( nrow( obj$M ), n_ind )
    expect_equal( obj$M, t( obj$M ) ) # symmetric
    expect_true( min(obj$M) > 0 ) # clear range expectations (these are counts)
    expect_true( max(obj$M) <= m_loci )
    # names should all be missing
    expect_true( is.null( colnames( obj$kinship ) ) )
    expect_true( is.null( rownames( obj$kinship ) ) )
    expect_true( is.null( colnames( obj$M ) ) )
    expect_true( is.null( rownames( obj$M ) ) )
    
    # temporarly move pair sample sizes file, to test what happens when that is missing
    # note IDs file still missing too
    expect_true( file.rename( file_sizes, file_sizes_tmp ) )
    # all should work but there's no IDs
    # must provide n in this case!
    expect_error( read_grm( name ) )
    obj <- read_grm( name, n_ind = n_ind )
    # check overall object
    expect_equal( length( obj ), 1 )
    expect_equal( names( obj ), 'kinship' )
    # test kinship matrix
    expect_true( is.matrix( obj$kinship ) )
    expect_equal( ncol( obj$kinship ), n_ind ) # expected dimensions
    expect_equal( nrow( obj$kinship ), n_ind )
    expect_equal( obj$kinship, t( obj$kinship ) ) # symmetric
    # names should all be missing
    expect_true( is.null( colnames( obj$kinship ) ) )
    expect_true( is.null( rownames( obj$kinship ) ) )

    # move back IDs file, but keep pair sample sizes file missing
    expect_true( file.rename( file_ids_tmp, file_ids ) )
    obj <- read_grm( name )
    # check overall object
    expect_equal( length( obj ), 2 )
    expect_equal( names( obj ), c('kinship', 'id') )
    # check individual objects
    # test kinship matrix
    expect_true( is.matrix( obj$kinship ) )
    expect_equal( ncol( obj$kinship ), n_ind ) # expected dimensions
    expect_equal( nrow( obj$kinship ), n_ind )
    expect_equal( obj$kinship, t( obj$kinship ) ) # symmetric
    # test IDs table
    expect_true( is_tibble( obj$id ) )
    expect_equal( ncol( obj$id ), 2 )
    expect_equal( nrow( obj$id ), n_ind )
    expect_equal( names( obj$id ), c('fam', 'id') )
    # match up names across matrices
    expect_equal( obj$id$id, colnames( obj$kinship ) )
    expect_equal( obj$id$id, rownames( obj$kinship ) )
    
    # move all back when done
    expect_true( file.rename( file_sizes_tmp, file_sizes ) )
})
