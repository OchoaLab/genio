#' Create a Plink FAM tibble
#'
#' This function simplifies the creation of Plink FAM-formatted tibbles, which autocompletes missing information if a partial tibble is provided, or generates a completely made up tibble if the number of individuals is provided.
#' The default values are most useful for simulated genotypes, where IDs can be made up but must be unique, and there are no parents, families, gender, or phenotype.
#'
#' Autocompleted column values:
#' - `fam`: `1:n`
#' - `id`: `1:n`
#' - `pat`: `0` (missing)
#' - `mat`: `0` (missing)
#' - `sex`: `0` (missing)
#' - `pheno`: `0` (missing)
#' 
#' Note that `n` is either given directly or obtained from the input tibble.
#'
#' @param tib The input tibble (optional).
#' Missing columns will be autocompleted with reasonable values that are accepted by Plink and other external software.
#' If missing, all will be autocompleted, but `n` is required.
#' @param n The desired number of individuals (rows).
#' Required if `tib` is missing; otherwise it is ignored.
#'
#' @return The input tibble with autocompleted columns and columns in default order, or the made up tibble if only the number of individuals was provided.
#' The output begins with the standard columns in standard order: `fam`, `id`, `pat`, `mat`, `sex`, `pheno`.
#' Additional columns in the input tibble are preserved but placed after the standard columns.
#'
#' @examples
#' # create a synthetic tibble for 10 individuals
#' # (most common use case)
#' fam <- make_fam(n = 10)
#'
#' # manually create a partial tibble with only phenotypes defined
#' library(tibble)
#' fam <- tibble(pheno = 0:2)
#' # autocomplete the rest of the columns
#' fam <- make_fam(fam)
#' 
#' @seealso
#' Plink FAM format reference:
#' <https://www.cog-genomics.org/plink/1.9/formats#fam>
#'
#' @export
make_fam <- function(tib, n = NA) {
    if (missing(tib)) {
        # there's nothing to edit, create a blank tibble
        # this is the only case in which n is required
        if (is.na(n))
            stop('Both `tib` and `n` are missing!')
        # initialize tibble this way
        tib <- tibble::tibble(.rows = n)
    } else {
        # define n this way 
        n <- nrow(tib)
    }

    # unique indexes for everything
    indexes <- 1:n

    # start filling in missing data
    # NOTE: for column "col" that don't exist yet, tib$col throws a warning but tib[['col']] is ok, so we use that notation here
    # fam and id must be unique
    if (is.null(tib[['fam']]))
        tib$fam <- indexes
    if (is.null(tib[['id']]))
        tib$id <- indexes
    # parents can (and should) be missing (all set to 0)
    if (is.null(tib[['pat']]))
        tib$pat <- 0
    if (is.null(tib[['mat']]))
        tib$mat <- 0
    # default sex is all missing (0)
    if (is.null(tib[['sex']]))
        tib$sex <- 0
    # default phenotype is all missing (0)
    if (is.null(tib[['pheno']]))
        tib$pheno <- 0
    
    # it's nice to have the main columns be shown in the default order (autocomplete will insert things after existing columns)
    # check if there are any extra columns first
    namesExist <- names(tib)
    indexes <- !(namesExist %in% fam_names) # true for extra names only
    # reorder main columns, stick extras in existing order at the end
    # this works even when all indexes are FALSE
    tib <- tib[, c(fam_names, namesExist[indexes])]
    # done, return tib
    return(tib)
}
