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

    # examples with missing diagonal (strict triangle)
    expect_equal(
        vec_to_mat_sym(x = 1:3, n = 3, strict = TRUE),
        matrix(
            c(NA, 1, 2,
              1, NA, 3,
              2, 3, NA),
            nrow = 3,
            ncol = 3
        )
    )
    expect_equal(
        vec_to_mat_sym(x = 1:6, n = 4, strict = TRUE),
        matrix(
            c(NA, 1, 2, 4,
              1, NA, 3, 5,
              2, 3, NA, 6,
              4, 5, 6, NA),
            nrow = 4,
            ncol = 4
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
    # strict case (diagonal ignored)
    expect_equal(
        mat_sym_to_vec(mat, strict = TRUE),
        2
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
    # strict case (diagonal ignored)
    expect_equal(
        mat_sym_to_vec(mat, strict = TRUE),
        c(2, 4, 5)
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
    # strict triangle works with the additional constraint that the diagonal be NA
    diag( mat ) <- NA
    expect_equal(
        vec_to_mat_sym( mat_sym_to_vec( mat, strict = TRUE ), n, strict = TRUE ),
        mat
    )

    # now the other way
    vec <- runif( n*(n+1)/2 )
    expect_equal(
        mat_sym_to_vec( vec_to_mat_sym( vec, n ) ),
        vec
    )
    # for strict, diagonal just doesn't exist, but size has to be different
    vec <- runif( n*(n-1)/2 )
    expect_equal(
        mat_sym_to_vec( vec_to_mat_sym( vec, n, strict = TRUE ), strict = TRUE ),
        vec
    )
    
})

test_that("require_files_grm works", {
    # this should work (pass existing files)
    expect_silent( require_files_grm('dummy-7-10-0.1') )
    # try something that doesn't exist, expect to fail
    expect_error( require_files_grm('file-that-does-not-exist') )
})

test_that("delete_files_grm works", {
    # positive control
    # create dummy GRM files
    file <- 'delete-me-test' # no extension
    # add each extension and create empty files
    file.create( paste0(file, '.grm.bin') )
    file.create( paste0(file, '.grm.N.bin') )
    file.create( paste0(file, '.grm.id') )
    
    # delete the BED/BIM/FAM files we just created
    expect_silent( delete_files_grm(file) )

    # negative control
    # there will be warnings for files that didn't exist
    expect_warning( delete_files_grm('file-that-does-not-exist') )
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
    file_fam <- paste0( name, ".grm.id" )
    file_sizes_tmp <- paste0( file_sizes, '-TMP' )
    file_fam_tmp <- paste0( file_fam, '-TMP' )
    # clean up after failed tests
    if ( !file.exists( file_sizes ) ) {
        if ( file.exists( file_sizes_tmp ) ) {
            expect_true( file.rename( file_sizes_tmp, file_sizes ) )
        } else 
            stop('Unexpected absence of file: ', file_sizes)
    }
    if ( !file.exists( file_fam ) ) {
        if ( file.exists( file_fam_tmp ) ) {
            expect_true( file.rename( file_fam_tmp, file_fam ) )
        } else 
            stop('Unexpected absence of file: ', file_fam)
    }
    
    # this reads real example, with everything present
    expect_silent(
        obj <- read_grm( name, verbose = FALSE )
    )
    # check overall object
    expect_equal( length( obj ), 3 )
    expect_equal( names( obj ), c('kinship', 'M', 'fam') )
    # check individual objects
    # test kinship matrix
    expect_true( is.matrix( obj$kinship ) )
    expect_equal( ncol( obj$kinship ), n_ind ) # expected dimensions
    expect_equal( nrow( obj$kinship ), n_ind )
    expect_true( isSymmetric( obj$kinship ) )
    # test pair sample sizes matrix
    expect_true( is.matrix( obj$M ) )
    expect_equal( ncol( obj$M ), n_ind ) # expected dimensions
    expect_equal( nrow( obj$M ), n_ind )
    expect_true( isSymmetric( obj$M ) )
    expect_true( min(obj$M) > 0 ) # clear range expectations (these are counts)
    expect_true( max(obj$M) <= m_loci )
    # test Fam table
    expect_true( is_tibble( obj$fam ) )
    expect_equal( ncol( obj$fam ), 2 )
    expect_equal( nrow( obj$fam ), n_ind )
    expect_equal( names( obj$fam ), c('fam', 'id') )
    # match up names across matrices
    expect_equal( obj$fam$id, colnames( obj$kinship ) )
    expect_equal( obj$fam$id, rownames( obj$kinship ) )
    expect_equal( obj$fam$id, colnames( obj$M ) )
    expect_equal( obj$fam$id, rownames( obj$M ) )

    # temporarly move ID file, to test what happens when that is missing
    expect_true( file.rename( file_fam, file_fam_tmp ) )
    # all should work but there's no Fam
    # must provide n in this case!
    expect_error( read_grm( name ) )
    expect_silent(
        obj <- read_grm( name, n_ind = n_ind, verbose = FALSE )
    )
    # check overall object
    expect_equal( length( obj ), 2 )
    expect_equal( names( obj ), c('kinship', 'M') )
    # check individual objects
    # test kinship matrix
    expect_true( is.matrix( obj$kinship ) )
    expect_equal( ncol( obj$kinship ), n_ind ) # expected dimensions
    expect_equal( nrow( obj$kinship ), n_ind )
    expect_true( isSymmetric( obj$kinship ) )
    # test pair sample sizes matrix
    expect_true( is.matrix( obj$M ) )
    expect_equal( ncol( obj$M ), n_ind ) # expected dimensions
    expect_equal( nrow( obj$M ), n_ind )
    expect_true( isSymmetric( obj$M ) )
    expect_true( min(obj$M) > 0 ) # clear range expectations (these are counts)
    expect_true( max(obj$M) <= m_loci )
    # names should all be missing
    expect_true( is.null( colnames( obj$kinship ) ) )
    expect_true( is.null( rownames( obj$kinship ) ) )
    expect_true( is.null( colnames( obj$M ) ) )
    expect_true( is.null( rownames( obj$M ) ) )
    
    # temporarly move pair sample sizes file, to test what happens when that is missing
    # note Fam file still missing too
    expect_true( file.rename( file_sizes, file_sizes_tmp ) )
    # all should work but there's no Fam
    # must provide n in this case!
    expect_error( read_grm( name ) )
    expect_silent(
        obj <- read_grm( name, n_ind = n_ind, verbose = FALSE )
    )
    # check overall object
    expect_equal( length( obj ), 1 )
    expect_equal( names( obj ), 'kinship' )
    # test kinship matrix
    expect_true( is.matrix( obj$kinship ) )
    expect_equal( ncol( obj$kinship ), n_ind ) # expected dimensions
    expect_equal( nrow( obj$kinship ), n_ind )
    expect_true( isSymmetric( obj$kinship ) )
    # names should all be missing
    expect_true( is.null( colnames( obj$kinship ) ) )
    expect_true( is.null( rownames( obj$kinship ) ) )

    # move back Fam file, but keep pair sample sizes file missing
    expect_true( file.rename( file_fam_tmp, file_fam ) )
    expect_silent(
        obj <- read_grm( name, verbose = FALSE )
    )
    # check overall object
    expect_equal( length( obj ), 2 )
    expect_equal( names( obj ), c('kinship', 'fam') )
    # check individual objects
    # test kinship matrix
    expect_true( is.matrix( obj$kinship ) )
    expect_equal( ncol( obj$kinship ), n_ind ) # expected dimensions
    expect_equal( nrow( obj$kinship ), n_ind )
    expect_true( isSymmetric( obj$kinship ) )
    # test FAM table
    expect_true( is_tibble( obj$fam ) )
    expect_equal( ncol( obj$fam ), 2 )
    expect_equal( nrow( obj$fam ), n_ind )
    expect_equal( names( obj$fam ), c('fam', 'id') )
    # match up names across matrices
    expect_equal( obj$fam$id, colnames( obj$kinship ) )
    expect_equal( obj$fam$id, rownames( obj$kinship ) )
    
    # move all back when done
    expect_true( file.rename( file_sizes_tmp, file_sizes ) )
})

test_that("write_grm works on small random sample", {
    # load the same case used for read tests
    n_ind <- 7
    m_loci <- 10
    miss <- 0.1
    name <- paste0('dummy-', n_ind, '-', m_loci, '-', miss)
    # reads case (everything present)
    expect_silent(
        obj <- read_grm( name, verbose = FALSE )
    )
    
    # now write to a new location
    name_out <- tempfile('delete-me_test-write')
    expect_silent(
        write_grm(
            name_out,
            kinship = obj$kinship,
            M = obj$M,
            fam = obj$fam,
            verbose = FALSE
        )
    )

    # files should match!
    # compare them
    for (ext in exts_grm) {
        # paths for both files that should be identical
        f1 <- paste0( name, '.', ext )
        f2 <- paste0( name_out, '.', ext )
        # load all data brute force
        data1 <- readLines(f1, warn = FALSE)
        data2 <- readLines(f2, warn = FALSE)
        # compare now
        expect_equal(data1, data2)
    }
    
    # delete new junk files when done
    delete_files_grm( name_out )
})

test_that("write_grm and read_grm are inverses on randomly generated data", {
    # the earlier case was one fixed file that doesn't change
    # here we generate new random data everytime and test that it makes sense
    n_ind <- 10
    m_loci <- 1000
    # the kinship and N matrices don't have to be particularly realistic, we just want to write and read back and confirm they're the same values
    kinship <- matrix(
        runif( n_ind * n_ind ),
        nrow = n_ind
    )
    # here it's made symmetric, and positive definite for good measure
    kinship <- crossprod( kinship )
    # random sample sizes too
    M <- matrix(
        sample.int( m_loci / 2, n_ind * n_ind ),
        nrow = n_ind
    )
    # make symmetric here too, but not positive definite (integers are more realistic)
    M <- M + t(M)
    # dummy individual data
    # cast as character for easier, exact matching
    fam <- tibble(
        fam = as.character( 1 : n_ind ),
        id = as.character( 1 : n_ind )
    )
    # add column and row names, as that's how they're read back (for easier, exact matching)
    rownames( kinship ) <- fam$id
    colnames( kinship ) <- fam$id
    rownames( M ) <- fam$id
    colnames( M ) <- fam$id
    
    # write all of this to a temporary file
    name <- tempfile('delete-me_test-write')
    expect_silent(
        write_grm(
            name,
            kinship = kinship,
            M = M,
            fam = fam,
            verbose = FALSE
        )
    )
    # read it back
    expect_silent(
        obj <- read_grm( name, verbose = FALSE )
    )
    # compare each element, we expect things to be identical!
    # there is expected loss of precision, this makes it all more lenient than usual
    expect_equal( kinship, obj$kinship, tolerance = 1e-7, scale = 1 )
    expect_equal( M, obj$M, tolerance = 1e-7, scale = 1 )
    # the dumb subsetting fixes a weird class issue; don't understand the use of that, but meh
    # https://www.tidyverse.org/blog/2018/12/readr-1-3-1/
    expect_equal( fam, obj$fam[] )
    
    # delete new junk files when done
    delete_files_grm( name )
})

test_that( "read_grm with shape='square' or shape='strict' and size_bytes=8 or 4 work on plink2 king sample data", {
    # the square matrix is trivial to parse, but binary parsers must match it!
    file_square <- system.file("extdata", 'sample-king-sq.king', package = "genio", mustWork = TRUE)
    # this toy example has some -inf values that readr doesn't parse correctly, sadly
    # (not a serious problem expected on any real dataset with sufficient SNPs)
    # so it generates warnings (suppressed here) and sets those two values to NAs
    # (read_matrix works as-is because file exists, so default txt extension isn't added)
    kinship_square <- suppressWarnings( read_matrix( file_square ) )
    # turn both NAs into -Inf as needed
    kinship_square[ is.na( kinship_square ) ] <- -Inf
    # make sure this matrix is symmetric as it should be
    expect_true( isSymmetric( kinship_square ) )
    # get true dimension of example
    n_ind <- nrow( kinship_square )

    # get and add IDs to expected kinship
    file_square_ids <- system.file("extdata", 'sample-king-sq.king.id', package = "genio", mustWork = TRUE)
    expect_silent(
        fam <- readr::read_tsv(
            file_square_ids,
            col_names = c('fam', 'id'),
            col_types = 'cc',
            comment = '#'
        )
    )
    colnames( kinship_square ) <- fam$id
    rownames( kinship_square ) <- fam$id
    
    # for strict triangle data there's no diagonal (its trivial as verified here too)
    expect_true( all( diag( kinship_square ) == 0.5 ) )
    kinship_square_strict <- kinship_square
    diag( kinship_square_strict ) <- NA

    # due to greater roundoff errors here, need greater tolerance
    tol4 <- 1e-6 # 2^(-2^4)
    tol8 <- 1e-6 # unclear why this also has to be so large!
    
    # test square bin4 reader function
    file_sq_bin4 <- system.file("extdata", 'sample-king-sq-bin4.king.bin', package = "genio", mustWork = TRUE)
    # remove extension from this path on purpose
    file_sq_bin4 <- sub('\\.king\\.bin$', '', file_sq_bin4)
    # get data!
    expect_silent(
        data_sq_bin4 <- read_grm( file_sq_bin4, ext = 'king', shape = 'square', verbose = FALSE )
    )
    # validate list
    expect_true( is.list( data_sq_bin4 ) )
    expect_equal( names( data_sq_bin4 ), c('kinship', 'fam') )
    # validate fam
    expect_equal( data_sq_bin4$fam, fam )
    # validate kinship
    # since output has limited precision, we need to increase our tolerance!
    expect_equal( data_sq_bin4$kinship, kinship_square, tolerance = tol4 )

    # test square bin(8) reader
    file_sq_bin8 <- system.file("extdata", 'sample-king-sq-bin.king.bin', package = "genio", mustWork = TRUE)
    # remove extension from this path on purpose
    file_sq_bin8 <- sub('\\.king\\.bin$', '', file_sq_bin8)
    # get data!
    expect_silent(
        data_sq_bin8 <- read_grm( file_sq_bin8, ext = 'king', shape = 'square', size_bytes = 8, verbose = FALSE )
    )
    # validate list
    expect_true( is.list( data_sq_bin8 ) )
    expect_equal( names( data_sq_bin8 ), c('kinship', 'fam') )
    # validate fam
    expect_equal( data_sq_bin8$fam, fam )
    # validate kinship
    expect_equal( data_sq_bin8$kinship, kinship_square, tolerance = tol8 )
    
    # test strict triangle bin4 reader function
    file_tr_bin4 <- system.file("extdata", 'sample-king-tr-bin4.king.bin', package = "genio", mustWork = TRUE)
    # remove extension from this path on purpose
    file_tr_bin4 <- sub('\\.king\\.bin$', '', file_tr_bin4)
    # get data!
    expect_silent(
        data_tr_bin4 <- read_grm( file_tr_bin4, ext = 'king', shape = 'strict', verbose = FALSE )
    )
    # validate list
    expect_true( is.list( data_tr_bin4 ) )
    expect_equal( names( data_tr_bin4 ), c('kinship', 'fam') )
    # validate fam
    expect_equal( data_tr_bin4$fam, fam )
    # validate kinship
    expect_equal( data_tr_bin4$kinship, kinship_square_strict, tolerance = tol4 )

    # test strict triangle bin8 reader function
    file_tr_bin8 <- system.file("extdata", 'sample-king-tr-bin.king.bin', package = "genio", mustWork = TRUE)
    # remove extension from this path on purpose
    file_tr_bin8 <- sub('\\.king\\.bin$', '', file_tr_bin8)
    # get data!
    expect_silent(
        data_tr_bin8 <- read_grm( file_tr_bin8, ext = 'king', shape = 'strict', size_bytes = 8, verbose = FALSE )
    )
    # validate list
    expect_true( is.list( data_tr_bin8 ) )
    expect_equal( names( data_tr_bin8 ), c('kinship', 'fam') )
    # validate fam
    expect_equal( data_tr_bin8$fam, fam )
    # validate kinship
    expect_equal( data_tr_bin8$kinship, kinship_square_strict, tolerance = tol8 )

    # make sure parsing fails when sizes are misspecified
    # (file sizes are checked for agreement)
    expect_error( read_grm( file_sq_bin4, ext = 'king', shape = 'square', size_bytes = 8, verbose = FALSE ) )
    expect_error( read_grm( file_sq_bin8, ext = 'king', shape = 'square', size_bytes = 4, verbose = FALSE ) )
    expect_error( read_grm( file_tr_bin4, ext = 'king', shape = 'strict', size_bytes = 8, verbose = FALSE ) )
    expect_error( read_grm( file_tr_bin8, ext = 'king', shape = 'strict', size_bytes = 4, verbose = FALSE ) )
    # and even more so for misspecified shapes
    expect_error( read_grm( file_sq_bin4, ext = 'king', shape = 'triangle', size_bytes = 4, verbose = FALSE ) )
    expect_error( read_grm( file_sq_bin4, ext = 'king', shape = 'triangle', size_bytes = 8, verbose = FALSE ) )
    expect_error( read_grm( file_sq_bin8, ext = 'king', shape = 'triangle', size_bytes = 4, verbose = FALSE ) )
    expect_error( read_grm( file_sq_bin8, ext = 'king', shape = 'triangle', size_bytes = 8, verbose = FALSE ) )
    expect_error( read_grm( file_sq_bin4, ext = 'king', shape = 'strict', size_bytes = 4, verbose = FALSE ) )
    expect_error( read_grm( file_sq_bin4, ext = 'king', shape = 'strict', size_bytes = 8, verbose = FALSE ) )
    expect_error( read_grm( file_sq_bin8, ext = 'king', shape = 'strict', size_bytes = 4, verbose = FALSE ) )
    expect_error( read_grm( file_sq_bin8, ext = 'king', shape = 'strict', size_bytes = 8, verbose = FALSE ) )
    expect_error( read_grm( file_tr_bin4, ext = 'king', shape = 'triangle', size_bytes = 4, verbose = FALSE ) )
    expect_error( read_grm( file_tr_bin4, ext = 'king', shape = 'triangle', size_bytes = 8, verbose = FALSE ) )
    expect_error( read_grm( file_tr_bin8, ext = 'king', shape = 'triangle', size_bytes = 4, verbose = FALSE ) )
    expect_error( read_grm( file_tr_bin8, ext = 'king', shape = 'triangle', size_bytes = 8, verbose = FALSE ) )
    expect_error( read_grm( file_tr_bin4, ext = 'king', shape = 'square', size_bytes = 4, verbose = FALSE ) )
    expect_error( read_grm( file_tr_bin4, ext = 'king', shape = 'square', size_bytes = 8, verbose = FALSE ) )
    expect_error( read_grm( file_tr_bin8, ext = 'king', shape = 'square', size_bytes = 4, verbose = FALSE ) )
    expect_error( read_grm( file_tr_bin8, ext = 'king', shape = 'square', size_bytes = 8, verbose = FALSE ) )
})

