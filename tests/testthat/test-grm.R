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
