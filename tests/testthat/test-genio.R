context("test-genio")

# all examples have 10 rows by construction, hardcode for tests here
n_rows <- 10

test_that("add_ext works", {
    # create a scenario where we know if the desired extension is already there or not
    ext <- 'bim'
    foExtN <- 'file-that-does-not-exist'
    foExtY <- paste0(foExtN, '.', ext)
    # test that missing extension got added correctly
    expect_equal(foExtY, add_ext(foExtN, ext))
    # test that present extension doesn't get added again
    expect_equal(foExtY, add_ext(foExtY, ext))
})

test_that("real_path works", {
    # function returns input when file does not exist
    fi <- 'file-that-does-not-exist'
    expect_equal(fi, real_path(fi, 'fam'))

    # test with real file (uncompressed)
    # file path of interest
    fi <- system.file("extdata", 'sample.fam', package = "genio", mustWork = TRUE)
    # when its correctly specified, real_path does not change it!
    expect_equal(fi, real_path(fi, 'fam'))
    # now we omit the extension, will still work
    fiNoExt <- sub('\\.fam$', '', fi)
    expect_equal(fi, real_path(fiNoExt, 'fam'))
    
    # repeat with a compressed file
    # file path of interest
    fi <- system.file("extdata", 'sample2.fam.gz', package = "genio", mustWork = TRUE)
    # when its correctly specified, real_path does not change it!
    expect_equal(fi, real_path(fi, 'fam'))
    # now we omit the .gz extension, will still work
    fiNoGz <- sub('\\.gz$', '', fi)
    expect_equal(fi, real_path(fiNoGz, 'fam'))
    # now we omit the .fam extension too, will still work
    fiNoGzNoExt <- sub('\\.fam$', '', fiNoGz)
    expect_equal(fi, real_path(fiNoGzNoExt, 'fam'))
    
})

test_that("read_fam works", {
    # load sample file
    fi <- system.file("extdata", 'sample.fam', package = "genio", mustWork = TRUE)
    # this should just work (no "expect" test)
    fam <- read_fam(fi)
    # test that number of columns is as expected
    expect_equal(ncol(fam), length(fam_names))
    # test that names are in right order too
    expect_equal(names(fam), fam_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(fam), n_rows)

    # repeat with missing extension
    fiNoExt <- sub('\\.fam$', '', fi)
    # this should just work (no "expect" test)
    fam <- read_fam(fiNoExt)
    # test that number of columns is as expected
    expect_equal(ncol(fam), length(fam_names))
    # test that names are in right order too
    expect_equal(names(fam), fam_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(fam), n_rows)

    # repeat with compressed file (and true full path)
    fi <- system.file("extdata", 'sample2.fam.gz', package = "genio", mustWork = TRUE)
    # this should just work (no "expect" test)
    fam <- read_fam(fi)
    # test that number of columns is as expected
    expect_equal(ncol(fam), length(fam_names))
    # test that names are in right order too
    expect_equal(names(fam), fam_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(fam), n_rows)
    
    # repeat with missing .gz extension
    fiNoGz <- sub('\\.gz$', '', fi)
    # this should just work (no "expect" test)
    fam <- read_fam(fiNoGz)
    # test that number of columns is as expected
    expect_equal(ncol(fam), length(fam_names))
    # test that names are in right order too
    expect_equal(names(fam), fam_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(fam), n_rows)

    # repeat with missing .fam.gz double extension
    fiNoGzNoExt <- sub('\\.fam$', '', fiNoGz)
    # this should just work (no "expect" test)
    fam <- read_fam(fiNoGzNoExt)
    # test that number of columns is as expected
    expect_equal(ncol(fam), length(fam_names))
    # test that names are in right order too
    expect_equal(names(fam), fam_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(fam), n_rows)

})

test_that("read_bim works", {
    # load sample file
    fi <- system.file("extdata", 'sample.bim', package = "genio", mustWork = TRUE)
    # this should just work (no "expect" test)
    bim <- read_bim(fi)
    # test that number of columns is as expected
    expect_equal(ncol(bim), length(bim_names))
    # test that names are in right order too
    expect_equal(names(bim), bim_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(bim), n_rows)

    # repeat with missing extension
    fiNoExt <- sub('\\.bim$', '', fi)
    # this should just work (no "expect" test)
    bim <- read_bim(fiNoExt)
    # test that number of columns is as expected
    expect_equal(ncol(bim), length(bim_names))
    # test that names are in right order too
    expect_equal(names(bim), bim_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(bim), n_rows)

    # repeat with compressed file (and true full path)
    fi <- system.file("extdata", 'sample2.bim.gz', package = "genio", mustWork = TRUE)
    # this should just work (no "expect" test)
    bim <- read_bim(fi)
    # test that number of columns is as expected
    expect_equal(ncol(bim), length(bim_names))
    # test that names are in right order too
    expect_equal(names(bim), bim_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(bim), n_rows)
    
    # repeat with missing .gz extension
    fiNoGz <- sub('\\.gz$', '', fi)
    # this should just work (no "expect" test)
    bim <- read_bim(fiNoGz)
    # test that number of columns is as expected
    expect_equal(ncol(bim), length(bim_names))
    # test that names are in right order too
    expect_equal(names(bim), bim_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(bim), n_rows)

    # repeat with missing .bim.gz double extension
    fiNoGzNoExt <- sub('\\.bim$', '', fiNoGz)
    # this should just work (no "expect" test)
    bim <- read_bim(fiNoGzNoExt)
    # test that number of columns is as expected
    expect_equal(ncol(bim), length(bim_names))
    # test that names are in right order too
    expect_equal(names(bim), bim_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(bim), n_rows)

})

test_that("read_ind works", {
    # load sample file
    fi <- system.file("extdata", 'sample.ind', package = "genio", mustWork = TRUE)
    # this should just work (no "expect" test)
    ind <- read_ind(fi)
    # test that number of columns is as expected
    expect_equal(ncol(ind), length(ind_names))
    # test that names are in right order too
    expect_equal(names(ind), ind_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(ind), n_rows)

    # repeat with missing extension
    fiNoExt <- sub('\\.ind$', '', fi)
    # this should just work (no "expect" test)
    ind <- read_ind(fiNoExt)
    # test that number of columns is as expected
    expect_equal(ncol(ind), length(ind_names))
    # test that names are in right order too
    expect_equal(names(ind), ind_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(ind), n_rows)

    # repeat with compressed file (and true full path)
    fi <- system.file("extdata", 'sample2.ind.gz', package = "genio", mustWork = TRUE)
    # this should just work (no "expect" test)
    ind <- read_ind(fi)
    # test that number of columns is as expected
    expect_equal(ncol(ind), length(ind_names))
    # test that names are in right order too
    expect_equal(names(ind), ind_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(ind), n_rows)
    
    # repeat with missing .gz extension
    fiNoGz <- sub('\\.gz$', '', fi)
    # this should just work (no "expect" test)
    ind <- read_ind(fiNoGz)
    # test that number of columns is as expected
    expect_equal(ncol(ind), length(ind_names))
    # test that names are in right order too
    expect_equal(names(ind), ind_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(ind), n_rows)

    # repeat with missing .ind.gz double extension
    fiNoGzNoExt <- sub('\\.ind$', '', fiNoGz)
    # this should just work (no "expect" test)
    ind <- read_ind(fiNoGzNoExt)
    # test that number of columns is as expected
    expect_equal(ncol(ind), length(ind_names))
    # test that names are in right order too
    expect_equal(names(ind), ind_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(ind), n_rows)

})

test_that("read_snp works", {
    # load sample file
    fi <- system.file("extdata", 'sample.snp', package = "genio", mustWork = TRUE)
    # this should just work (no "expect" test)
    snp <- read_snp(fi)
    # test that number of columns is as expected
    expect_equal(ncol(snp), length(snp_names))
    # test that names are in right order too
    expect_equal(names(snp), snp_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(snp), n_rows)

    # repeat with missing extension
    fiNoExt <- sub('\\.snp$', '', fi)
    # this should just work (no "expect" test)
    snp <- read_snp(fiNoExt)
    # test that number of columns is as expected
    expect_equal(ncol(snp), length(snp_names))
    # test that names are in right order too
    expect_equal(names(snp), snp_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(snp), n_rows)

    # repeat with compressed file (and true full path)
    fi <- system.file("extdata", 'sample2.snp.gz', package = "genio", mustWork = TRUE)
    # this should just work (no "expect" test)
    snp <- read_snp(fi)
    # test that number of columns is as expected
    expect_equal(ncol(snp), length(snp_names))
    # test that names are in right order too
    expect_equal(names(snp), snp_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(snp), n_rows)
    
    # repeat with missing .gz extension
    fiNoGz <- sub('\\.gz$', '', fi)
    # this should just work (no "expect" test)
    snp <- read_snp(fiNoGz)
    # test that number of columns is as expected
    expect_equal(ncol(snp), length(snp_names))
    # test that names are in right order too
    expect_equal(names(snp), snp_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(snp), n_rows)

    # repeat with missing .snp.gz double extension
    fiNoGzNoExt <- sub('\\.snp$', '', fiNoGz)
    # this should just work (no "expect" test)
    snp <- read_snp(fiNoGzNoExt)
    # test that number of columns is as expected
    expect_equal(ncol(snp), length(snp_names))
    # test that names are in right order too
    expect_equal(names(snp), snp_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(snp), n_rows)

})

