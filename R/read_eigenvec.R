#' Read plink eigenvec file
#'
#' This function reads a plink eigenvec file, parsing columns strictly.
#' First two must be 'fam' and 'id', which are strings, and all remaining columns (eigenvectors) must be numeric.
#'
#' @param file The input file path, potentially excluding extension.
#' @param ext File extension (default "eigenvec") can be changed if desired.
#' @param comment A string used to identify comments.
#' Any text after the comment characters will be silently ignored.
#' Passed to `\link[readr]{read_table2}`.
#' '#' (default) works for plink2 eigenvec files, which have a header lines that starts with this character (the header is therefore ignored).
#' @param verbose If TRUE (default) function reports the path of the file being written (after autocompleting the extension).
#'
#' @return A list with two elements:
#'
#' - `eigenvec`: A numeric R matrix containing the parsed eigenvectors
#' - `fam`: A tibble with two columns, `fam` and `id`, which are the first two columns of the parsed file.
#'
#' @examples
#' # read an existing *.eigenvec file created by GCTA
#' file <- system.file("extdata", 'sample-gcta.eigenvec', package = "genio", mustWork = TRUE)
#' data <- read_eigenvec(file)
#' # numeric eigenvector matrix
#' data$eigenvec
#' # fam/id tibble
#' data$fam
#'
#' # can specify without extension
#' file <- sub('\\.eigenvec$', '', file) # remove extension from this path on purpose
#' file # verify .eigenvec is missing
#' data <- read_eigenvec(file) # load it anyway!
#' data$eigenvec
#'
#' # read an existing *.eigenvec file created by plink2
#' file <- system.file("extdata", 'sample-plink2.eigenvec', package = "genio", mustWork = TRUE)
#' data <- read_eigenvec(file)
#' # numeric eigenvector matrix
#' data$eigenvec
#' # fam/id tibble
#' data$fam
#'
#' @seealso
#' \code{\link{write_eigenvec}} for writing an eigenvec file.
#' 
#' Plink 1 eigenvec format reference:
#' \url{https://www.cog-genomics.org/plink/1.9/formats#eigenvec}
#' 
#' Plink 2 eigenvec format reference:
#' \url{https://www.cog-genomics.org/plink/2.0/formats#eigenvec}
#'
#' GCTA eigenvec format reference:
#' \url{https://cnsgenomics.com/software/gcta/#PCA}
#' 
#' @export
read_eigenvec <- function(
                          file,
                          ext = 'eigenvec',
                          comment = '#',
                          verbose = TRUE
                          ) {
    if ( missing( file ) )
        stop('`file` is required!')
    
    # add .ext and/or .gz if missing and needed
    file <- real_path(file, ext)
    
    # announce what we ended up loading, nice to know
    if (verbose)
        message('Reading: ', file)

    # first two columns must be strings, the rest must be numeric (double)
    col_types <- readr::cols(
                            X1 = 'c',
                            X2 = 'c',
                            .default = 'd'
                        )
    
    # GCTA uses spaces (instead of tabs), so let's use this more general parser
    eigenvec <- readr::read_table2(
        file,
        col_names = FALSE,
        col_types = col_types,
        comment = comment
    )
    # first two columns (FAM/ID) should be separated
    fam <- eigenvec[ , 1:2 ]
    # add usual column names
    colnames( fam ) <- c('fam', 'id')
    eigenvec <- eigenvec[ , -(1:2) ]
    # change these column names too
    colnames( eigenvec ) <- 1 : ncol( eigenvec )
    # turn to numeric matrix
    eigenvec <- as.matrix( eigenvec )

    
    # return both bits of data
    return(
        list(
            eigenvec = eigenvec,
            fam = fam
        )
    )
}
