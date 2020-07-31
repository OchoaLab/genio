library(genio)
library(stringr)
library(tibble)

# get file to count lines in from ARGV
args <- commandArgs( trailingOnly = TRUE )
file <- args[1]

# make sure file exists before we start
if ( !file.exists( file ) )
    stop( 'File does not exist: ', file )

# this implements an old linux-only solution, uses system `wc`
# this would be my practical standard of "fast"
count_lines_wcl <- function(file) {
    # run wc on terminal
    n <- system2(
        'wc',
        args = c('-l', file),
        stdout = TRUE
    )
    # cool solution to extract numbers
    # https://stla.github.io/stlapblog/posts/Numextract.html
    n <- stringr::str_extract(n, "\\-*\\d+\\.*\\d*")
    # return proper numeric value
    n <- as.numeric(n)
    return(n)
}

# run wc version...
message('wc')
time_wc <- system.time(
    n_wc <- count_lines_wcl( file )
)[3]

# run genio version...
message('genio')
time_genio <- system.time(
    n_genio <- count_lines( file, verbose = FALSE )
)[3]

# gather results in tibble
tib <- tibble(
    method = c(
        'wc',
        'genio'
    ),
    time = c(
        time_wc,
        time_genio
    ),
    lines = c(
        n_wc,
        n_genio
    )
)

# show results
print( tib )
