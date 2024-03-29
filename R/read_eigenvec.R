#' Read Plink eigenvec file
#'
#' This function reads a Plink eigenvec file, parsing columns strictly.
#' First two must be 'fam' and 'id', which are strings, and all remaining columns (eigenvectors) must be numeric.
#'
#' @param file The input file path, potentially excluding extension.
#' @param ext File extension (default "eigenvec") can be changed if desired.
#' Set to `NA` to force `file` to exist as-is.
#' @param plink2 If `TRUE`, the header is parsed and preserved in the returned data.
#' The first two columns must be FID and IID, which are mandatory.
#' @param comment A string used to identify comments.
#' Any text after the comment characters will be silently ignored.
#' Passed to [readr::read_table()].
#' '#' (default when `plink2 = FALSE`) works for Plink 2 eigenvec files, which have a header lines that starts with this character (the header is therefore ignored).
#' However, `plink2 = TRUE` forces the header to be parsed instead.
#' @param verbose If `TRUE` (default) function reports the path of the file being written (after autocompleting the extension).
#'
#' @return A list with two elements:
#' - `eigenvec`: A numeric R matrix containing the parsed eigenvectors.
#'   If `plink2 = TRUE`, the original column names will be preserved in this matrix.
#' - `fam`: A tibble with two columns, `fam` and `id`, which are the first two columns of the parsed file.
#'   These column names are always the same even if `plink2 = TRUE` (i.e. they won't be `FID` or `IID`).
#'
#' @examples
#' # to read "data.eigenvec", run like this:
#' # data <- read_eigenvec("data")
#' # this also works
#' # data <- read_eigenvec("data.eigenvec")
#' #
#' # either way you get a list with these two items:
#' # numeric eigenvector matrix
#' # data$eigenvec
#' # fam/id tibble
#' # data$fam
#' 
#' # The following example is more awkward
#' # because package sample data has to be specified in this weird way:
#' 
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
#' # read an existing *.eigenvec file created by Plink 2
#' file <- system.file("extdata", 'sample-plink2.eigenvec', package = "genio", mustWork = TRUE)
#' # this version ignores header
#' data <- read_eigenvec(file)
#' # numeric eigenvector matrix
#' data$eigenvec
#' # fam/id tibble
#' data$fam
#'
#' # this version uses header
#' data <- read_eigenvec(file, plink2 = TRUE)
#' # numeric eigenvector matrix
#' data$eigenvec
#' # fam/id tibble
#' data$fam
#'
#' @seealso
#' [write_eigenvec()] for writing an eigenvec file.
#' 
#' Plink 1 eigenvec format reference:
#' <https://www.cog-genomics.org/plink/1.9/formats#eigenvec>
#' 
#' Plink 2 eigenvec format reference:
#' <https://www.cog-genomics.org/plink/2.0/formats#eigenvec>
#'
#' GCTA eigenvec format reference:
#' <https://cnsgenomics.com/software/gcta/#PCA>
#' 
#' @export
read_eigenvec <- function(
                          file,
                          ext = 'eigenvec',
                          plink2 = FALSE,
                          comment = if (plink2) '' else '#',
                          verbose = TRUE
                          ) {
    if ( missing( file ) )
        stop('`file` is required!')
    
    # add .ext and/or .gz if missing and needed
    file <- add_ext_read(file, ext)
    
    # announce what we ended up loading, nice to know
    if (verbose)
        message('Reading: ', file)

    # first two columns must be strings, the rest must be numeric (double)
    # annoyingly, names of columns must match and they have to be spelled out this way (couldn't use variables for the names themselves as they are arguments to a function)
    # NOTE FID at parse time contains the hash!
    col_types <- if ( plink2 ) readr::cols( '#FID' = 'c', IID = 'c', .default = 'd' ) else readr::cols( X1 = 'c', X2 = 'c', .default = 'd' )
    
    # GCTA uses spaces (instead of tabs), so let's use this more general parser
    eigenvec <- readr::read_table(
        file,
        col_names = plink2, # i.e. FALSE or TRUE depending on that
        col_types = col_types,
        comment = comment
    )

    # can do fancier things if there's a header
    fam_names <- c('fam', 'id')
    if ( plink2 ) {
        # remove initial hash that should be there
        names( eigenvec )[1] <- sub( '#', '', names( eigenvec )[1] )
        # extract FAM using plink2 identifiers (so they could be in random orders, in theory, though again current parser enforces a certain order earlier anyway)
        fam_names_in <- c('FID', 'IID')
        # subsetting is easier below with indexes, get them
        indexes <- match( fam_names_in, names( eigenvec ) )
        # columns can be missing (particularly FID), so handle NAs (unmatched cases) if they appear 
        if ( anyNA( indexes ) ) {
            # IID is mandatory
            if ( is.na( indexes[2] ) )
                stop( 'Mandatory column `IID` is missing!' )
            # FID is optional (in theory, though currently parser requires #FID as first column anyway)
            if ( is.na( indexes[1] ) ) {
                # only use IID (guaranteed to exist)
                indexes <- indexes[2]
                fam_names <- fam_names[2]
            }
        }
    } else {
        # when there's no columns, FID/IID must be first two!
        indexes <- 1:2
    }
    # separate FAM from rest of data
    fam <- eigenvec[ , indexes ]
    eigenvec <- eigenvec[ , -indexes ]
    # normalize FAM column names (both cases)
    colnames( fam ) <- fam_names
    # turn to numeric matrix
    eigenvec <- as.matrix( eigenvec )
    # change these column names too (if header was missing)
    if ( !plink2 )
        colnames( eigenvec ) <- 1 : ncol( eigenvec )
    
    # return both bits of data
    return(
        list(
            eigenvec = eigenvec,
            fam = fam
        )
    )
}
