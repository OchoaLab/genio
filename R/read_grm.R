#' Read GCTA GRM and related plink2 binary files
#'
#' This function reads a GCTA Genetic Relatedness Matrix (GRM, i.e. kinship) set of files in their binary format, returning the kinship matrix and, if available, the corresponding matrix of pair sample sizes (non-trivial under missingness) and individuals table.
#' With some option tweaks it can also parse several plink2 binary kinship formats, such as "king".
#'
#' @param name The base name of the input files.
#' Files with that base, plus shared extension (default "grm", see `ext` below), plus extensions `.bin`, `.N.bin`, and `.id` are read if they exist.
#' Only `.<ext>.bin` is absolutely required; `.<ext>.id` can be substituted by the number of individuals (see below); `.<ext>.N.bin` is entirely optional.
#' @param n_ind The number of individuals, required if the file with the extension `.<ext>.id` is missing.
#' If the file with the `.<ext>.id` extension is present, then this `n_ind` is ignored.
#' @param verbose If `TRUE` (default), function reports the path of the files being loaded.
#' @param ext Shared extension for all three inputs (see `name` above; default "grm").
#' Another useful value is "king" for KING-robust estimates produced by plink2.
#' If `NA` no extension is added.
#' If given `ext` is also present at the end of `name`, then it is not added again.
#' @param shape The shape of the information to parse.
#' Default "triangle" assumes there are `n*(n+1)/2` values to parse corresponding to the upper triangle including the diagonal (required for GCTA GRM).
#' "strict_triangle" assumes there are `n*(n-1)/2` values to parse corresponding to the upper triangle *excluding* the diagonal (best for plink2 KING-robust).
#' Lastly, "square" assumes there are `n*n` values to parse corresponding to the entire square matrix, ignoring symmetry.
#' @param size_bytes The number of bytes per number encoded.
#' Default 4 corresponds to GCTA GRM and plink2 "bin4", whereas plink2 "bin" requires a value of 8.
#' @param comment Character to start comments in `<ext>.id` file only.
#' Default "#" helps plink2 `.id` files (which have a header that starts with "#", which is therefore ignored) be parsed just like plink1 and GCTA files (which do not have a header).
#'
#' @return A list with named elements:
#' - `kinship`: The symmetric `n`-times-`n` kinship matrix (GRM).  Has IDs as row and column names if the file with extension `.<ext>.id` was available.
#' - `M`: The symmetric `n`-times-`n` matrix of pair sample sizes (number of non-missing loci pairs), if the file with extension `.<ext>.N.bin` was available.  Has IDs as row and column names if the file with extension `.<ext>.id` was available.
#' - `fam`: A tibble with two columns: `fam` and `id`, same as in Plink FAM files.  Returned if the file with extension `.<ext>.id` was available.
#'
#' @examples
#' # to read "data.grm.bin" and etc, run like this:
#' # obj <- read_grm("data")
#' # obj$kinship # the kinship matrix
#' # obj$M       # the pair sample sizes matrix
#' # obj$fam     # the fam and ID tibble
#' 
#' # The following example is more awkward
#' # because package sample data has to be specified in this weird way:
#' 
#' # read an existing set of GRM files
#' file <- system.file("extdata", 'sample.grm.bin', package = "genio", mustWork = TRUE)
#' file <- sub('\\.grm\\.bin$', '', file) # remove extension from this path on purpose
#' obj <- read_grm(file)
#' obj$kinship # the kinship matrix
#' obj$M       # the pair sample sizes matrix
#' obj$fam     # the fam and ID tibble
#' 
#' @seealso
#' Greatly adapted from sample code from GCTA:
#' <https://cnsgenomics.com/software/gcta/#MakingaGRM>
#' 
#' @export
read_grm <- function(
                     name,
                     n_ind = NA,
                     verbose = TRUE,
                     ext = 'grm',
                     shape = c('triangle', 'strict_triangle', 'square'),
                     size_bytes = 4,
                     comment = '#'
                     ) {
    # various checks
    if ( missing( name ) )
        stop('Base `name` for input files to `read_grm` is required!')
    # add shared extension to files, if given and not redundant with name
    name <- add_ext( name, ext )
    # complete paths
    file_bin <- paste0( name, ".bin" )
    file_sizes <- paste0( name, ".N.bin" )
    file_fam <- paste0( name, ".id" )
    # only the binary file is required
    if ( !file.exists( file_bin ) )
        stop( 'Required file missing: ', file_bin )
    shape <- match.arg( shape )
    
    # read IDs, if present
    fam <- NULL
    if ( file.exists( file_fam ) ) {
        # this is a table with two columns (family and id)
        # this parser should work with plink2 format (only difference is header line, which starts with a comment character, so by default it is ignored)
        fam <- read_tab_generic(
            file = file_fam,
            ext = NA,
            tib_names = c('fam', 'id'),
            col_types = 'cc',
            verbose = verbose,
            comment = comment
        )
        # get number of individuals
        n_ind <- nrow( fam )
    } else if ( is.na( n_ind ) ) {
        stop('Either `n_ind` or the IDs file are required: ', file_fam)
    }
    # calculate number of values expected
    # triangle includes diagonal
    # strict triangle (i.e. for king) excludes diagonal!
    n2 <- switch(
        shape,
        square = n_ind^2,
        triangle = n_ind * ( n_ind + 1 ) / 2,
        strict_triangle = n_ind * ( n_ind - 1 ) / 2
    )
    
    # read actual kinship values!
    kinship <- read_grm_single(
        file = file_bin,
        n_ind = n_ind,
        n2 = n2,
        shape = shape,
        size_bytes = size_bytes,
        fam = fam,
        verbose = verbose
    )

    # prepare return value
    # the kinship matrix is the only required data
    obj <- list( kinship = kinship )

    # read sample sizes matrix, if present
    if ( file.exists( file_sizes ) ) {
        # read it!
        M <- read_grm_single(
            file = file_sizes,
            n_ind = n_ind,
            n2 = n2,
            shape = shape,
            size_bytes = size_bytes,
            fam = fam,
            verbose = verbose
        )
        # add to return value
        obj$M <- M
    }

    # add IDS data to the very end
    if ( !is.null( fam ) )
        obj$fam <- fam

    # return all of the available data
    return( obj )
}
