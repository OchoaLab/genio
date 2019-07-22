# need to load it explicitly for some tests
library(tibble)

context("test-genio")

# all examples have 10 rows by construction, hardcode for tests here
n_rows <- 10

test_that("add_ext works", {
    # test that there are errors when crucial data is missing
    expect_error(add_ext()) # all is missing
    expect_error(add_ext('file')) # ext is missing
    expect_error(add_ext(ext='txt')) # file is missing
    
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
    # test that there are errors when crucial data is missing
    expect_error(real_path()) # all is missing
    expect_error(real_path('file')) # ext is missing
    expect_error(real_path(ext='txt')) # file is missing
    
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
    # test that there are errors when crucial data is missing
    expect_error(read_fam()) # file is missing
    expect_error(read_fam('bogus-file')) # file is non-existent (read_table2 will complain)
    
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

test_that("read_phen works", {
    # test that there are errors when crucial data is missing
    expect_error(read_phen()) # file is missing
    expect_error(read_phen('bogus-file')) # file is non-existent (read_table2 will complain)
    
    # load sample file
    fi <- system.file("extdata", 'sample.phen', package = "genio", mustWork = TRUE)
    # this should just work (no "expect" test)
    phen <- read_phen(fi)
    # test that number of columns is as expected
    expect_equal(ncol(phen), length(phen_names))
    # test that names are in right order too
    expect_equal(names(phen), phen_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(phen), n_rows)

    # repeat with missing extension
    fiNoExt <- sub('\\.phen$', '', fi)
    # this should just work (no "expect" test)
    phen <- read_phen(fiNoExt)
    # test that number of columns is as expected
    expect_equal(ncol(phen), length(phen_names))
    # test that names are in right order too
    expect_equal(names(phen), phen_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(phen), n_rows)

    # repeat with compressed file (and true full path)
    fi <- system.file("extdata", 'sample2.phen.gz', package = "genio", mustWork = TRUE)
    # this should just work (no "expect" test)
    phen <- read_phen(fi)
    # test that number of columns is as expected
    expect_equal(ncol(phen), length(phen_names))
    # test that names are in right order too
    expect_equal(names(phen), phen_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(phen), n_rows)
    
    # repeat with missing .gz extension
    fiNoGz <- sub('\\.gz$', '', fi)
    # this should just work (no "expect" test)
    phen <- read_phen(fiNoGz)
    # test that number of columns is as expected
    expect_equal(ncol(phen), length(phen_names))
    # test that names are in right order too
    expect_equal(names(phen), phen_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(phen), n_rows)

    # repeat with missing .phen.gz double extension
    fiNoGzNoExt <- sub('\\.phen$', '', fiNoGz)
    # this should just work (no "expect" test)
    phen <- read_phen(fiNoGzNoExt)
    # test that number of columns is as expected
    expect_equal(ncol(phen), length(phen_names))
    # test that names are in right order too
    expect_equal(names(phen), phen_names)
    # the example had n_rows lines only, check that too
    expect_equal(nrow(phen), n_rows)

})

test_that("read_bim works", {
    # test that there are errors when crucial data is missing
    expect_error(read_bim()) # file is missing
    expect_error(read_bim('bogus-file')) # file is non-existent (read_table2 will complain)
    
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
    # test that there are errors when crucial data is missing
    expect_error(read_ind()) # file is missing
    expect_error(read_ind('bogus-file')) # file is non-existent (read_table2 will complain)
    
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
    # test that there are errors when crucial data is missing
    expect_error(read_snp()) # file is missing
    expect_error(read_snp('bogus-file')) # file is non-existent (read_table2 will complain)
    
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

test_that("write_fam works", {
    # test that there are errors when crucial data is missing
    expect_error(write_fam()) # all is missing
    expect_error(write_fam('file')) # tibble is missing
    expect_error(write_fam(tib=data.frame(id=1))) # file is missing (tib is incomplete too, but that gets tested downstream)
    
    # load sample file
    fi <- system.file("extdata", 'sample.fam', package = "genio", mustWork = TRUE)
    # create a dummy output we'll delete later
    fo <- tempfile('delete-me_test-write', fileext = '.fam')
    # this should just work (tested earlier)
    fam1 <- read_fam(fi)
    # try writing it back elsewhere
    write_fam(fo, fam1)
    # and read it back again to comare
    fam2 <- read_fam(fo)
    # compare
    expect_equal(fam1, fam2)
    # delete output when done
    invisible(file.remove(fo))

    # repeat by randomly reordering data, should automatically reorder too
    fam1_r <- fam1[, sample.int(ncol(fam1))]
    # try writing it back elsewhere
    write_fam(fo, fam1_r)
    # and read it back again to compare
    fam2 <- read_fam(fo)
    # compare
    expect_equal(fam1, fam2)
    # delete output when done
    invisible(file.remove(fo))

    # repeat by adding junk columns, should be automatically ignored
    fam1_r <- fam1 # copy first
    fam1_r$junk <- 1 # add a junk column
    # try writing it back elsewhere
    write_fam(fo, fam1_r)
    # and read it back again to compare
    fam2 <- read_fam(fo)
    # compare
    expect_equal(fam1, fam2)
    # delete output when done
    invisible(file.remove(fo))

    # delete a column, test that an error is thrown
    fam1_r <- fam1 # copy first
    fam1_r$id <- NULL # delete this column
    expect_error(write_fam(fo, fam1_r))
})

test_that("write_phen works", {
    # test that there are errors when crucial data is missing
    expect_error(write_phen()) # all is missing
    expect_error(write_phen('file')) # tibble is missing
    expect_error(write_phen(tib=data.frame(id=1))) # file is missing (tib is incomplete too, but that gets tested downstream)
    
    # load sample file
    fi <- system.file("extdata", 'sample.phen', package = "genio", mustWork = TRUE)
    # create a dummy output we'll delete later
    fo <- tempfile('delete-me_test-write', fileext = '.phen')
    # this should just work (tested earlier)
    phen1 <- read_phen(fi)
    # try writing it back elsewhere
    write_phen(fo, phen1)
    # and read it back again to compare
    phen2 <- read_phen(fo)
    # compare
    expect_equal(phen1, phen2)
    # delete output when done
    invisible(file.remove(fo))

    # repeat by randomly reordering data, should automatically reorder too
    phen1_r <- phen1[, sample.int(ncol(phen1))]
    # try writing it back elsewhere
    write_phen(fo, phen1_r)
    # and read it back again to compare
    phen2 <- read_phen(fo)
    # compare
    expect_equal(phen1, phen2)
    # delete output when done
    invisible(file.remove(fo))

    # repeat by adding junk columns, should be automatically ignored
    phen1_r <- phen1 # copy first
    phen1_r$junk <- 1 # add a junk column
    # try writing it back elsewhere
    write_phen(fo, phen1_r)
    # and read it back again to compare
    phen2 <- read_phen(fo)
    # compare
    expect_equal(phen1, phen2)
    # delete output when done
    invisible(file.remove(fo))

    # delete a column, test that an error is thrown
    phen1_r <- phen1 # copy first
    phen1_r$id <- NULL # delete this column
    expect_error(write_phen(fo, phen1_r))

    # create a random trait, test that writing and reading it both work
    # random quantitiative trait
    phen1$pheno <- rnorm(n_rows)
    # introduce NAs too!
    phen1$pheno[7:8] <- NA
    # try writing it back elsewhere
    write_phen(fo, phen1)
    # and read it back again to compare
    phen2 <- read_phen(fo)
    # compare
    expect_equal(phen1, phen2)
    # delete output when done
    invisible(file.remove(fo))
})

test_that("write_bim works", {
    # test that there are errors when crucial data is missing
    expect_error(write_bim()) # all is missing
    expect_error(write_bim('file')) # tibble is missing
    expect_error(write_bim(tib=data.frame(id=1))) # file is missing (tib is incomplete too, but that gets tested downstream)
    
    # load sample file
    fi <- system.file("extdata", 'sample.bim', package = "genio", mustWork = TRUE)
    # create a dummy output we'll delete later
    fo <- tempfile('delete-me_test-write', fileext = '.bim')
    # this should just work (tested earlier)
    bim1 <- read_bim(fi)
    # try writing it back elsewhere
    write_bim(fo, bim1)
    # and read it back again to comare
    bim2 <- read_bim(fo)
    # compare
    expect_equal(bim1, bim2)
    # delete output when done
    invisible(file.remove(fo))

    # repeat by randomly reordering data, should automatically reorder too
    bim1_r <- bim1[, sample.int(ncol(bim1))]
    # try writing it back elsewhere
    write_bim(fo, bim1_r)
    # and read it back again to comare
    bim2 <- read_bim(fo)
    # compare
    expect_equal(bim1, bim2)
    # delete output when done
    invisible(file.remove(fo))

    # repeat by adding junk columns, should be automatically ignored
    bim1_r <- bim1 # copy first
    bim1_r$junk <- 1 # add a junk column
    # try writing it back elsewhere
    write_bim(fo, bim1_r)
    # and read it back again to comare
    bim2 <- read_bim(fo)
    # compare
    expect_equal(bim1, bim2)
    # delete output when done
    invisible(file.remove(fo))

    # delete a column, test that an error is thrown
    bim1_r <- bim1 # copy first
    bim1_r$id <- NULL # delete this column
    expect_error(write_bim(fo, bim1_r))
})

test_that("write_ind works", {
    # test that there are errors when crucial data is missing
    expect_error(write_ind()) # all is missing
    expect_error(write_ind('file')) # tibble is missing
    expect_error(write_ind(tib=data.frame(id=1))) # file is missing (tib is incomplete too, but that gets tested downstream)
    
    # load sample file
    fi <- system.file("extdata", 'sample.ind', package = "genio", mustWork = TRUE)
    # create a dummy output we'll delete later
    fo <- tempfile('delete-me_test-write', fileext = '.ind')
    # this should just work (tested earlier)
    ind1 <- read_ind(fi)
    # try writing it back elsewhere
    write_ind(fo, ind1)
    # and read it back again to comare
    ind2 <- read_ind(fo)
    # compare
    expect_equal(ind1, ind2)
    # delete output when done
    invisible(file.remove(fo))

    # repeat by randomly reordering data, should automatically reorder too
    ind1_r <- ind1[, sample.int(ncol(ind1))]
    # try writing it back elsewhere
    write_ind(fo, ind1_r)
    # and read it back again to comare
    ind2 <- read_ind(fo)
    # compare
    expect_equal(ind1, ind2)
    # delete output when done
    invisible(file.remove(fo))

    # repeat by adding junk columns, should be automatically ignored
    ind1_r <- ind1 # copy first
    ind1_r$junk <- 1 # add a junk column
    # try writing it back elsewhere
    write_ind(fo, ind1_r)
    # and read it back again to comare
    ind2 <- read_ind(fo)
    # compare
    expect_equal(ind1, ind2)
    # delete output when done
    invisible(file.remove(fo))

    # delete a column, test that an error is thrown
    ind1_r <- ind1 # copy first
    ind1_r$id <- NULL # delete this column
    expect_error(write_ind(fo, ind1_r))
})

test_that("write_snp works", {
    # test that there are errors when crucial data is missing
    expect_error(write_snp()) # all is missing
    expect_error(write_snp('file')) # tibble is missing
    expect_error(write_snp(tib=data.frame(id=1))) # file is missing (tib is incomplete too, but that gets tested downstream)
    
    # load sample file
    fi <- system.file("extdata", 'sample.snp', package = "genio", mustWork = TRUE)
    # create a dummy output we'll delete later
    fo <- tempfile('delete-me_test-write', fileext = '.snp')
    # this should just work (tested earlier)
    snp1 <- read_snp(fi)
    # try writing it back elsewhere
    write_snp(fo, snp1)
    # and read it back again to comare
    snp2 <- read_snp(fo)
    # compare
    expect_equal(snp1, snp2)
    # delete output when done
    invisible(file.remove(fo))

    # repeat by randomly reordering data, should automatically reorder too
    snp1_r <- snp1[, sample.int(ncol(snp1))]
    # try writing it back elsewhere
    write_snp(fo, snp1_r)
    # and read it back again to comare
    snp2 <- read_snp(fo)
    # compare
    expect_equal(snp1, snp2)
    # delete output when done
    invisible(file.remove(fo))

    # repeat by adding junk columns, should be automatically ignored
    snp1_r <- snp1 # copy first
    snp1_r$junk <- 1 # add a junk column
    # try writing it back elsewhere
    write_snp(fo, snp1_r)
    # and read it back again to comare
    snp2 <- read_snp(fo)
    # compare
    expect_equal(snp1, snp2)
    # delete output when done
    invisible(file.remove(fo))

    # delete a column, test that an error is thrown
    snp1_r <- snp1 # copy first
    snp1_r$id <- NULL # delete this column
    expect_error(write_snp(fo, snp1_r))
})

test_that("make_fam works", {
    # test that there are errors when crucial data is missing
    expect_error(make_fam()) # all is missing

    # this should work
    fam <- make_fam(n = n_rows)
    # check the tibble
    expect_equal(nrow(fam), n_rows)
    expect_equal(names(fam), fam_names)

    # ultimate test, make sure we can write it and also parse it without issues
    # create a dummy output we'll delete later
    fo <- tempfile('delete-me_test-make', fileext = '.fam')
    # to make comparison exact, change some column modes from numeric to character
    fam$fam <- as.character(fam$fam)
    fam$id <- as.character(fam$id)
    fam$pat <- as.character(fam$pat)
    fam$mat <- as.character(fam$mat)
    # write it
    write_fam(fo, fam)
    # read it
    fam2 <- read_fam(fo)
    # compare
    # NOTE: there's a weird issue with class() here that makes this not work unless it's "fam2[]" specifically
    # https://www.tidyverse.org/articles/2018/12/readr-1-3-1/#tibble-subclass
    expect_equal(fam, fam2[])
    # delete output when done
    invisible(file.remove(fo))

    # try a case where we are missing standard columns, add extra columns
    fam <- tibble(pheno =  0:2, subpop = 2:0, age = 30:32)
    # autocomplete and reorder
    fam <- make_fam(fam)
    # test that columns are as expected
    # first all standard columns, then additions in previous order
    expect_equal(names(fam), c(fam_names, 'subpop', 'age'))
    # test rows for good measure
    expect_equal(nrow(fam), 3)
    # make sure pheno was as we specified above and not overwritten with 0's
    expect_equal(fam$pheno, 0:2)
})

test_that("make_bim works", {
    # test that there are errors when crucial data is missing
    expect_error(make_bim()) # all is missing

    # this should work
    bim <- make_bim(n = n_rows)
    # check the tibble
    expect_equal(nrow(bim), n_rows)
    expect_equal(names(bim), bim_names)

    # ultimate test, make sure we can write it and also parse it without issues
    # create a dummy output we'll delete later
    fo <- tempfile('delete-me_test-make', fileext = '.bim')
    # to make comparison exact, change some column modes from numeric to character
    bim$chr <- as.character(bim$chr)
    bim$id <- as.character(bim$id)
    bim$ref <- as.character(bim$ref)
    bim$alt <- as.character(bim$alt)
    # write it
    write_bim(fo, bim)
    # read it
    bim2 <- read_bim(fo)
    # compare
    # NOTE: there's a weird issue with class() here that makes this not work unless it's "bim2[]" specifically
    # https://www.tidyverse.org/articles/2018/12/readr-1-3-1/#tibble-subclass
    expect_equal(bim, bim2[])
    # delete output when done
    invisible(file.remove(fo))

    # try a case where we are missing standard columns, add extra columns
    bim <- tibble(chr = 1:10, fst = (1:10)/100, maf = fst)
    # autocomplete and reorder
    bim <- make_bim(bim)
    # test that columns are as expected
    # first all standard columns, then additions in previous order
    expect_equal(names(bim), c(bim_names, 'fst', 'maf'))
    # test rows for good measure
    expect_equal(nrow(bim), 10)
    # make sure chr was as we specified above and not overwritten with 1's
    expect_equal(bim$chr, 1:10)
})

test_that("require_files_plink works", {
    # these should all just work (pass existing files)
    require_files_plink('dummy-33-101-0.1')
    require_files_plink('dummy-4-10-0.1')
    require_files_plink('dummy-5-10-0.1')
    require_files_plink('dummy-6-10-0.1')
    require_files_plink('dummy-7-10-0.1')
    # try something that doesn't exist, expect to fail
    expect_error( require_files_plink('file-that-does-not-exist') )
})

test_that("delete_files_plink works", {
    # positive control
    # create dummy BED/BIM/FAM files
    file <- 'delete-me-test' # no extension
    # add each extension and create empty files
    file.create( paste0(file, '.bed') )
    file.create( paste0(file, '.bim') )
    file.create( paste0(file, '.fam') )
    
    # delete the BED/BIM/FAM files we just created
    expect_silent( delete_files_plink(file) )

    # negative control
    # there will be warnings for files that didn't exist
    expect_warning( delete_files_plink('file-that-does-not-exist') )
})

test_that("sex_to_int works", {
    # die if input is missing
    expect_error( sex_to_int() )
        
    # positive control
    # construct a simple test where we know the answers
    sex_char <- c('U', 'M', 'F', 'F', 'M', 'U')
    sex_int <- c(0:2, 2:0)
    expect_equal( sex_to_int(sex_char), sex_int )
    # lowercase should work too
    sex_char <- c('u', 'm', 'f', 'f', 'm', 'u')
    expect_equal( sex_to_int(sex_char), sex_int )
    
    # negative controls
    # these throw warnings now (not fatal)
    expect_warning( sex_to_int(c('A', 'B', 'C', 'D')) ) # all invalid
    expect_warning( sex_to_int(c('U', 'M', 'F', 'A')) ) # only last one is invalid
})

test_that("sex_to_char works", {
    # die if input is missing
    expect_error( sex_to_char() )
        
    # positive control
    # construct a simple test where we know the answers
    sex_int <- c(0:2, 2:0)
    sex_char <- c('U', 'M', 'F', 'F', 'M', 'U')
    expect_equal( sex_to_char(sex_int), sex_char )
    
    # negative controls
    # these throw warnings now (not fatal)
    expect_warning( sex_to_char(4:10) ) # all invalid
    expect_warning( sex_to_char(0:3) ) # only last one is invalid

    # test that functions invert themselves as expected
    expect_equal( sex_to_char( sex_to_int(sex_char) ), sex_char )
    expect_equal( sex_to_int( sex_to_char(sex_int) ), sex_int )
})

test_that("validate_tab_generic works", {
    # load sample file
    fi <- system.file("extdata", 'sample.fam', package = "genio", mustWork = TRUE)
    # this should just work (no "expect" test)
    fam <- read_fam(fi)

    # test that there are errors when crucial data is missing
    expect_error(validate_tab_generic()) # all is missing
    expect_error(validate_tab_generic(tib = fam)) # ext, tib_names are missing
    expect_error(validate_tab_generic(ext = 'fam')) # tib, tib_names are missing
    expect_error(validate_tab_generic(tib_names = fam_names)) # tib, ext are missing
    expect_error(validate_tab_generic(tib = fam, ext = 'fam')) # tib_names are missing
    expect_error(validate_tab_generic(tib = fam, tib_names = fam_names)) # ext missing
    expect_error(validate_tab_generic(ext = 'fam', tib_names = fam_names)) # tib missing

    # when all is present and valid, no errors or warnings are thrown
    expect_silent(validate_tab_generic(tib = fam, ext = 'fam', tib_names = fam_names))

    # more negative controls
    # tibble must be a data.frame (includes tibbles)
    expect_error(validate_tab_generic(tib = 'not-tibble', ext = 'fam', tib_names = fam_names))
    # set wrong columns (so they're missing)
    expect_error(validate_tab_generic(tib = fam, ext = 'fam', tib_names = bim_names))
    # NOTE: ext is only used to print the informative messages, but it is not itself validated or matched against anything
})

test_that("ind_to_fam works", {
    # load sample files
    # FAM (negative control)
    fi <- system.file("extdata", 'sample.fam', package = "genio", mustWork = TRUE)
    fam <- read_fam(fi)
    # IND (positive control)
    fi <- system.file("extdata", 'sample.ind', package = "genio", mustWork = TRUE)
    ind <- read_ind(fi)
    
    # die if input is missing
    expect_error( ind_to_fam() )
    # die if input is not an IND table
    expect_error( ind_to_fam(fam) )
    # convert a proper IND file... (overwrites earlier FAM)
    fam <- ind_to_fam(ind)
    # check that we have the values we expect
    expect_equal( fam$id, ind$id )
    expect_equal( fam$fam, ind$label )
    expect_equal( fam$sex, sex_to_int(ind$sex) ) # needs conversion
    expect_equal( sex_to_char(fam$sex), ind$sex ) # gratuitously test reverse conversion
    # these were default values, check that they are so
    expect_true( all(fam$pat == 0) )
    expect_true( all(fam$mat == 0) )
    expect_true( all(fam$pheno == 0) )
})
