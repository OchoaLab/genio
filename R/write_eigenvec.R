#' Write eigenvectors table into a Plink-format file
#' 
#' This function writes eigenvectors in Plink 1 (same as GCTA) format (table with no header, with first two columns being `fam` and `id`), which is a subset of Plink 2 format (which optionally allows column names and does not require fam column).
#' Main expected case is `eigenvec` passed as a numeric matrix and `fam` provided to complete first two missing columns.
#' However, input `eigenvec` may also be a data.frame already containing the `fam` and `id` columns, and other reasonable intermediate cases are also handled.
#' If both `eigenvec` and `fam` are provided and contain overlapping columns, those in `eigenvec` get overwritten with a warning.
#'
#' @param file The output file name (possibly without extension)
#' @param eigenvec A matrix or tibble containing the eigenvectors to include in the file.
#' Column names other than `fam` and `id` can be anything and are all treated as eigenvectors (not written to file).
#' @param fam An optional `fam` table, which is used to add the `fam` and `id` columns to `eigenvec` (which overwrite columns of the same name in `eigenvec` if present, after a warning is produced).
#' Individuals in `fam` and `eigenvec` are assumed to be the same and in the same order.
#' @param ext Output file extension.
#' Since the general "covariates" file format in GCTA and Plink are the same as this, this function may be used to write more general covariates files if desired, in which case users may wish to change this extension for clarity.
#' @param verbose If `TRUE` (default), function reports the path of the file being written (after autocompleting the extension).
#'
#' @return Invisibly, the final `eigenvec` data.frame or tibble written to file, starting with columns `fam` and `id` (merged from the `fam` input, if it was passed) followed by the rest of columns in the input `eigenvec`.
#'
#' @examples
#' # to write an existing matrix `eigenvec` and optional `fam` tibble into file "data.eigenvec",
#' # run like this:
#' # write_eigenvec("data", eigenvec, fam = fam)
#' # this also works
#' # write_eigenvec("data.eigenvec", eigenvec, fam = fam)
#' 
#' # The following example is more detailed but also more awkward
#' # because (only for these examples) the package must create the file in a *temporary* location
#' 
#' # create dummy eigenvectors matrix, in this case from a small identity matrix
#' # number of individuals
#' n <- 10
#' eigenvec <- eigen( diag( n ) )$vectors
#' # subset columns to use top 3 eigenvectors only
#' eigenvec <- eigenvec[ , 1:3 ]
#' # dummy fam data
#' library(tibble)
#' fam <- tibble( fam = 1:n, id = 1:n )
#' 
#' # write this data to .eigenvec file
#' # output path without extension
#' file <- tempfile('delete-me-example')
#' eigenvec_final <- write_eigenvec( file, eigenvec, fam = fam )
#' # inspect the tibble that was written to file (returned invisibly)
#' eigenvec_final
#'
#' # remove temporary file (add extension before deletion)
#' file.remove( paste0( file, '.eigenvec' ) )
#'
#' @seealso
#' [read_eigenvec()] for reading an eigenvec file.
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
write_eigenvec <- function( file, eigenvec, fam = NULL, ext = 'eigenvec', verbose = TRUE ) {
    # required parameters
    if ( missing( file ) )
        stop( '`file` is required!' )
    if ( missing( eigenvec ) )
        stop( '`eigenvec` is required!' )
    
    # eigenvector matrix should be an R matrix or a tibble
    if ( is.matrix( eigenvec ) ) {
        # eigenvalues are often a numeric matrix
        # eigen returns matrix without column names, but tibbles don't like that, so add unique names now
        if ( is.null( colnames( eigenvec ) ) )
            colnames( eigenvec ) <- 1 : ncol(eigenvec)
        # convert now to tibble
        eigenvec <- tibble::as_tibble( eigenvec )
    } else if ( !is.data.frame( eigenvec ) ) {
        stop('`eigenvec` must be a matrix or a data.frame!')
    }
    # desired fam columns
    cols_fam <- c('fam', 'id')
    if ( !is.null( fam ) ) {
        # fam should be data.frame/tibble/etc
        if ( !is.data.frame( fam ) )
            stop('`fam` must be a data.frame!')
        # fam should contain desired columns
        if ( !( all( cols_fam %in% names( fam ) ) ) )
            stop('`fam` is missing at least one of required columns "fam" or "id"!')
        # make sure dimensions agree
        if ( nrow( fam ) != nrow( eigenvec ) )
            stop(
                'Numbers of rows (individuals) differs between `fam` (',
                nrow( fam ),
                ') and `eigenvec` (',
                nrow( eigenvec ),
                ')!'
            )
        if ( any( cols_fam %in% names( eigenvec ) ) ) {
            # warn that some original columns will be overwritten
            warning(
                'Overlapping columns between `eigenvec` and `fam` will be overwritten in `eigenvec`: ',
                toString( cols_fam[ cols_fam %in% names( eigenvec ) ] )
            )
            # toss overlapping columns before merging as below
            eigenvec <- eigenvec[ setdiff( names( eigenvec ), cols_fam ) ]
        }
        # combine data.frames, with initial columns as desired
        eigenvec <- dplyr::bind_cols( fam[ cols_fam ], eigenvec )
    } else {
        # if there was no fam provided, then:
        # - make sure eigenvec has the two required columns
        if ( !( all( cols_fam %in% names( eigenvec ) ) ) )
            stop('`eigenvec` is missing at least one of required columns "fam" or "id"!')
        # - reorder columns if needed
        if ( !all( cols_fam == names( eigenvec )[ 1:2 ] ) ) {
            cols_rest <- setdiff( names( eigenvec ), cols_fam )
            eigenvec <- eigenvec[ c(cols_fam, cols_rest) ]
        }
    }

    # add extension if it wasn't already there
    file <- add_ext(file, ext)
    
    # announce what we ended up writing, nice to know
    if (verbose)
        message('Writing: ', file)
    
    # save in a file like GCTA's
    readr::write_tsv(
        eigenvec,
        file,
        col_names = FALSE
    )
    # return invisible final eigenvec tibble, so we can test that directly (in internal package tests)
    return( invisible( eigenvec ) )
}
