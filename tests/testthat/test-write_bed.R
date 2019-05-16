context("test-write_bed")

# write_bed is complicated, deserves its own section

# some simple tests don't depend on BEDMatrix being around...

# simulate X (to share across tests)
# create a simple matrix with random valid data
# have n != m so we can check dimensions within write_plink
n <- 5
m <- 10
miss <- 0.1 # add missingness for good measure
fo <- 'delete-me-random-test' # output name without extensions!
fo_bed <- add_ext(fo, 'bed') # output with extension
# create ancestral allele frequencies
p_anc <- runif(m)
# create genotypes
X <- rbinom(n*m, 2, p_anc)
# add missing values
X[sample(n*m, n*m*miss)] <- NA
# turn into matrix
X <- matrix(X, nrow = m, ncol = n)

# simulate phenotype (to share across tests)
pheno <- rnorm(n)

test_that("write_bed and read_bed work", {
    # test that there are errors when crucial data is missing
    expect_error(write_bed()) # all is missing
    expect_error(write_bed('file')) # X is missing
    expect_error(write_bed(X = matrix(NA, 1, 1))) # file is missing
    # die if X is not a matrix!
    expect_error(write_bed('file', 'not-matrix'))
    
    # this should work
    write_bed(fo, X)

    # read tests
    # parse data back, verify agreement!
    X2 <- read_bed(fo, m, n)
    expect_equal(X, X2)
    # errors for missing params
    expect_error( read_bed() ) # missing all
    expect_error( read_bed(m_loci = m, n_ind = n) ) # missing file
    expect_error( read_bed(fo, n_ind = n) ) # missing m_loci
    expect_error( read_bed(fo, m) ) # missing n_ind
    # error tests for bad dimensions
    expect_error( read_bed(fo, n, m) ) # reversed dimensions: padding checks and padding mismatches catch these!
    expect_error( read_bed(fo, m+1, n) )
    expect_error( read_bed(fo, m-1, n) )
    expect_error( read_bed(fo, m, n-1) )
    expect_error( read_bed(fo, m, n+4) ) # have to be off by a whole byte to notice some of these errors
    
    # delete output when done
    invisible(file.remove(fo_bed))

    # now add invalid values to X, make sure it dies!
    X2 <- X
    # add a negative value in a random location
    X2[sample(n*m, 1)] <- -1
    # actually die!
    expect_error( write_bed(fo, X2) )
    # make sure output doesn't exist anymore (code should automatically clean it up)
    expect_false( file.exists(fo_bed) )

    # another test
    X2 <- X
    # add a 3 in a random location
    X2[sample(n*m, 1)] <- 3
    # actually die!
    expect_error( write_bed(fo, X2) )
    # make sure output doesn't exist anymore (code should automatically clean it up)
    expect_false( file.exists(fo_bed) )

    # NOTE: if X contains values that truncate to the correct range (say, 1.5, which becomes 1 upon truncation), then that's what Rcpp does internally and no errors are raised!
})


# this test requires BEDMatrix to read file and print it back out
if (suppressMessages(suppressWarnings(require(BEDMatrix)))) {

    # wrapper to get BEDMatrix to read a matrix in the format we expect it to be
    read_bed_hack <- function(file, m = NULL, n = NULL) {
        # run this way since BEDMatrix is rather verbose
        # when there's no paired FAM/BIM, here provide dimensions and we're good (NULL requires FAM/BIM)
        X <- suppressMessages(suppressWarnings(BEDMatrix(file, n = n, p = m)))
        # this turns it into a regular matrix just like the one we expect
        X <- as.matrix(X)
        # transpose as needed
        X <- t(X)
        # remove dimnames for later comparison (adds unnecessary complexity)
        dimnames(X) <- NULL
        # finally done!
        return(X)
    }

    # generic testing function
    testOneInput <- function(nameIn) {
        nameOut <- paste0(nameIn, '_rewrite')

        # load dummy file
        X <- read_bed_hack(nameIn)
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
        # reload, again
        X2 <- read_bed_hack(nameOut, m = nrow(X), n = ncol(X))
        # compare now
        expect_equal(X, X2)

        # remove temporary output file
        file.remove(f2)
    }

    # generic testing function for read_bed_cpp
    testOneInput_read_cpp <- function(nameIn) {
        # load dummy file
        X <- read_bed_hack(nameIn)
        # load using my code
        file <- add_ext(nameIn, 'bed')
        expect_silent(
            X2 <- read_bed_cpp(file, nrow(X), ncol(X)) # hack use dimensions from the X read by BEDMatrix
        )
        
        # compare now
        expect_equal(X, X2)
    }

    # generic testing function for read_bed
    testOneInput_read <- function(nameIn) {
        # load dummy file
        X <- read_bed_hack(nameIn)
        # load using my code
        file <- add_ext(nameIn, 'bed')
        X2 <- read_bed(file, nrow(X), ncol(X)) # hack use dimensions from the X read by BEDMatrix
        
        # compare now
        expect_equal(X, X2)

        # ensure expected failures do fail
        # mess with dimensions on purpose
        expect_error( read_bed(file, ncol(X), nrow(X)) ) # reverse dimensions, get caught because of padding checks (non-commutative unless both are factors of 4)
        expect_error( read_bed(file, nrow(X)+1, ncol(X)) )
        expect_error( read_bed(file, nrow(X)-1, ncol(X)) )
        expect_error( read_bed(file, nrow(X), ncol(X)-1) )
        # sadly many +1 individual cases don't cause error because they just look like zeroes (in all loci) if there is enough padding.
        # do expect an error if we're off by a whole byte (4 individuals)
        expect_error( read_bed(file, nrow(X), ncol(X)+4) )
    }
    
    test_that("write_bed agrees with BEDMatrix", {
        # repeat on several files
        testOneInput('dummy-33-101-0.1')
        testOneInput('dummy-4-10-0.1')
        testOneInput('dummy-5-10-0.1')
        testOneInput('dummy-6-10-0.1')
        testOneInput('dummy-7-10-0.1')
    })
    
    test_that("read_bed_cpp agrees with BEDMatrix", {
        # repeat on several files
        testOneInput_read_cpp('dummy-33-101-0.1')
        testOneInput_read_cpp('dummy-4-10-0.1')
        testOneInput_read_cpp('dummy-5-10-0.1')
        testOneInput_read_cpp('dummy-6-10-0.1')
        testOneInput_read_cpp('dummy-7-10-0.1')
    })
    
    test_that("read_bed agrees with BEDMatrix", {
        # repeat on several files
        testOneInput_read('dummy-33-101-0.1')
        testOneInput_read('dummy-4-10-0.1')
        testOneInput_read('dummy-5-10-0.1')
        testOneInput_read('dummy-6-10-0.1')
        testOneInput_read('dummy-7-10-0.1')
    })
    
    test_that("write_plink works", {
        # test that there are errors when crucial data is missing
        expect_error(write_plink()) # all is missing
        expect_error(write_plink('file')) # tibble is missing
        expect_error(write_plink(X = matrix(NA, 1, 1))) # file is missing

        # this autocompletes bim and fam!
        write_plink(fo, X)
        # make sure we can read outputs!
        # NOTE this uses BEDMatrix, which loads all three files by default and checks their dimensions!
        X2 <- read_bed_hack(fo)
        # compare now
        expect_equal(X, X2)
        # read with my new function
        data <- read_plink(fo)
        # compare again
        expect_equal(X, data$X)
        # delete all three outputs when done
        # this also tests that all three files existed!
        expect_silent( delete_files_plink(fo) )

        # this autocompletes bim and fam except for pheno
        write_plink(fo, X, pheno = pheno)
        # in this case parse fam and make sure we recover pheno!
        fam <- read_fam(fo)
        # compare!
        expect_equal(fam$pheno, pheno)
        # gratuitously retest genotype reading (and BEDMatrix-mediated consistency of data)
        X2 <- read_bed_hack(fo)
        # compare now
        expect_equal(X, X2)
        # read with my new function
        data <- read_plink(fo)
        # compare again
        expect_equal(X, data$X)
        # delete all three outputs when done
        # this also tests that all three files existed!
        expect_silent( delete_files_plink(fo) )

        # create a case in which fam is also provided, make sure we get warning
        fam <- make_fam(n = n)
        expect_warning( write_plink(fo, X, fam = fam, pheno = pheno) )
        # parse fam and make sure pheno was missing
        fam <- read_fam(fo)
        expect_equal(fam$pheno, rep.int(0, n))
        # delete all three outputs when done
        # this also tests that all three files existed!
        expect_silent( delete_files_plink(fo) )
    })
}

