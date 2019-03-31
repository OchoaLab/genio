# not a regular test, just a way to time differences in algorithm

library(Rcpp)

# load the two functions we need
source('../R/add_ext.R')
source('../R/write_bed.R')
sourceCpp("../src/write_bed_cpp.cpp")
sourceCpp("../src/write_bed_cpp2.cpp")
sourceCpp("../src/write_bed_cpp3.cpp")

# create a very large file to write
n <- 1003
m <- 100000
miss <- 0.1 # add missingness for good measure
fo1 <- 'random-test1.bed' # output name
fo2 <- 'random-test2.bed' # output name

message('creating X...')
system.time({
    # create ancestral allele frequencies
    p_anc <- runif(m)
    # create genotypes
    X <- rbinom(n*m, 2, p_anc)
    # add missing values
    X[sample(n*m, n*m*miss)] <- NA
    # turn into matrix
    X <- matrix(X, nrow=m, ncol=n)
})

message('V1...')
system.time( write_bed(fo1, X, v=0) )

message('V2...')
system.time( write_bed(fo2, X, v=3) )

# make sure outputs agree!
data1 <- readLines(fo1, warn=FALSE)
data2 <- readLines(fo2, warn=FALSE)
# compare now
if (all(data1 == data2)) {
    message('Outputs agree!')
} else {
    # in this case we don't erase outputs, so we can inspect!
    stop('Error: outputs disagree!')
}

# remove output when done
invisible(file.remove(fo1))
invisible(file.remove(fo2))
