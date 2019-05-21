#' Read genotype and sample data in a plink BED/BIM/FAM file set.
#'
#' This function reads a genotype matrix (X) and its associated locus (bim) and individual (fam) data tables in the three plink files in BED, BIM, and FAM formats, respectively.
#' All inputs must exist or an error is thrown.
#' This function is a wrapper around the more basic functions
#' \code{\link{read_bed}},
#' \code{\link{read_bim}},
#' \code{\link{read_fam}}.
#' Below suppose there are \eqn{m} loci and \eqn{n} individuals.
#' 
#' @param file Input file path, without extensions (each of .bed, .bim, .fam extensions will be added automatically as needed).
#' Alternatively, input file path may have .bed extension (but not .bim, .fam, or other extensions).
#' @param verbose If TRUE (default) function reports the paths of the files being read (after autocompleting the extensions).
#'
#' @return A named list with items in this order: X (genotype matrix), bim (tibble), fam (tibble).
#' X has row and column names corresponding to the \code{id} values of the bim and fam tibbles.
#'
#' @examples
#' # first get path to BED file
#' file <- system.file("extdata", 'sample.bed', package = "genio", mustWork = TRUE)
#'
#' # read genotypes and annotation tables
#' plink_data <- read_plink(file)
#' # genotypes
#' plink_data$X
#' # locus annotations
#' plink_data$bim
#' # individual annotations
#' plink_data$fam
#' 
#' # the same works without .bed extension
#' file <- sub('\\.bed$', '', file) # remove extension
#' # it works!
#' plink_data <- read_plink(file)
#'
#' @seealso
#' \code{\link{read_bed}},
#' \code{\link{read_bim}},
#' \code{\link{read_fam}}.
#' 
#' Plink BED/BIM/FAM format reference:
#' \url{https://www.cog-genomics.org/plink/1.9/formats}
#'
#' @export
read_plink <- function(file, verbose = TRUE) {
    # die if things are missing
    if (missing(file))
        stop('Input file path is required!')

    # remove bed extension if present
    file <- sub('\\.bed$', '', file)
    
    # before wasting time parsing, check that all required files are present
    require_files_plink(file)
    
    # first read annotation tables
    bim <- read_bim(file, verbose = verbose)
    fam <- read_fam(file, verbose = verbose)

    # read genotypes, using the above data dimensions
    X <- read_bed(
        file = file,
        names_loci = bim$id,
        names_ind = fam$id,
        verbose = verbose
    )
    
    # returned desired named list with all data
    return(
        list(
            X = X,
            bim = bim,
            fam = fam
        )
    )
}
