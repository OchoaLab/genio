context("test-write_bed")

# write_bed is complicated, deserves its own section

# some simple tests don't depend on BEDMatrix being around...

test_that("write_bed works", {
    # test that there are errors when crucial data is missing
    expect_error(write_bed()) # all is missing
    expect_error(write_bed('file')) # X is missing
    expect_error(write_bed(X=matrix(NA, 1, 1))) # file is missing
    # die if X is not a matrix!
    expect_error(write_bed('file', 'not-matrix'))
    
    # create a simple matrix with random valid data
    n <- 10
    m <- 10
    miss <- 0.1 # add missingness for good measure
    fo <- 'delete-me-random-test.bed' # output name
    # create ancestral allele frequencies
    p_anc <- runif(m)
    # create genotypes
    X <- rbinom(n*m, 2, p_anc)
    # add missing values
    X[sample(n*m, n*m*miss)] <- NA
    # turn into matrix
    X <- matrix(X, nrow=m, ncol=n)
    # this should work
    write_bed(fo, X)
    # delete output when done
    invisible(file.remove(fo))

    # now add invalid values to X, make sure it dies!
    X2 <- X
    # add a negative value in a random location
    X2[sample(n*m, 1)] <- -1
    # actually die!
    expect_error( write_bed(fo, X2) )
    # make sure output doesn't exist anymore (code should automatically clean it up)
    expect_false( file.exists(fo) )

    # another test
    X2 <- X
    # add a 3 in a random location
    X2[sample(n*m, 1)] <- 3
    # actually die!
    expect_error( write_bed(fo, X2) )
    # make sure output doesn't exist anymore (code should automatically clean it up)
    expect_false( file.exists(fo) )

    # NOTE: if X contains values that truncate to the correct range (say, 1.5, which becomes 1 upon truncation), then that's what Rcpp does internally and no errors are raised!
})


# this test requires BEDMatrix to read file and print it back out
if (suppressMessages(suppressWarnings(require(BEDMatrix)))) {

    test_that("write_bed agrees with BEDMatrix", {

        # generic testing function
        testOneInput <- function(nameIn) {
            nameOut <- paste0(nameIn, '_rewrite')

            # load dummy file
            # run this way since BEDMatrix is rather verbose
            X <- suppressMessages(suppressWarnings(BEDMatrix(nameIn)))
            # this turns it into a regular matrix just like the one we expect
            X <- as.matrix(X)
            # transpose as needed
            X <- t(X)
            # remove dimnames for later comparison (adds unnecessary complexity)
            dimnames(X) <- NULL
            # write second version (BED only)
            write_bed(nameOut, X)
            
            # compare outputs, they should be identical!
            # this is less than ideal, but at least it's a pure R solution (not depending on linux 'cmp' or 'diff')
            f1 <- add_ext(nameIn, 'bed')
            f2 <- add_ext(nameOut, 'bed')
            # load all data brute force
            data1 <- readLines(f1, warn=FALSE)
            data2 <- readLines(f2, warn=FALSE)
            # compare now
            expect_equal(data1, data2)

            # extra redundant check...
            # load as BED matrix too
            # because there's no paired FAM/BIM, here provide dimensions and we're good
            X2 <- suppressMessages(suppressWarnings(BEDMatrix(nameOut, n = ncol(X), p = nrow(X))))
            # turn into matrix and transpose too, for comparison
            X2 <- as.matrix(X2)
            X2 <- t(X2)
            # also remove dimnames (default sets a list of NULLs instead of a simple NULL)
            dimnames(X2) <- NULL
            # compare now
            expect_equal(X, X2)

            # remove temporary output file
            file.remove(f2)
        }

        # repeat on several files
        testOneInput('dummy-33-101-0.1')
        testOneInput('dummy-4-10-0.1')
        testOneInput('dummy-5-10-0.1')
        testOneInput('dummy-6-10-0.1')
        testOneInput('dummy-7-10-0.1')
    })
    
}
