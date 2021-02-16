#' Create a Plink BIM tibble
#'
#' This function simplifies the creation of Plink BIM-formatted tibbles, which autocompletes missing information if a partial tibble is provided, or generates a completely made up tibble if the number of individuals is provided.
#' The default values are most useful for simulated genotypes, where IDs can be made up but must be unique, and there are no chromosomes, positions, or particular reference or alternative alleles.
#'
#' Autocompleted column values:
#' - `chr`: `1` (all data is on a single chromosome)
#' - `id`: `1:n`
#' - `posg`: `0` (missing)
#' - `pos`: `1:n`
#' - `ref`: `1`
#' - `alt`: `2`
#' 
#' Note that `n` is either given directly or obtained from the input tibble.
#'
#' @param tib The input tibble (optional).
#' Missing columns will be autocompleted with reasonable values that are accepted by Plink and other external software.
#' If missing, all will be autocompleted, but `n` is required.
#' @param n The desired number of loci (rows).
#' Required if `tib` is missing; otherwise it is ignored.
#'
#' @return The input tibble with autocompleted columns and columns in default order, or the made up tibble if only the number of individuals was provided.
#' The output begins with the standard columns in standard order: chr, id, posg, pos, ref, alt.
#' Additional columns in the input tibble are preserved but placed after the standard columns.
#'
#' @examples
#' # create a synthetic tibble for 10 loci
#' # (most common use case)
#' bim <- make_bim(n = 10)
#'
#' # manually create a partial tibble with only chromosomes defined
#' library(tibble)
#' bim <- tibble(chr = 0:2)
#' # autocomplete the rest of the columns
#' bim <- make_bim(bim)
#' 
#' @seealso
#' Plink BIM format reference:
#' <https://www.cog-genomics.org/plink/1.9/formats#bim>
#'
#' @export
make_bim <- function(tib, n = NA) {
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
    # place all on chr 1
    if (is.null(tib[['chr']]))
        tib$chr <- 1
    # id and pos must be unique
    if (is.null(tib[['id']]))
        tib$id <- indexes
    if (is.null(tib[['pos']]))
        tib$pos <- indexes
    # set genetic position as missing (this is common)
    if (is.null(tib[['posg']]))
        tib$posg <- 0
    # common default values for these
    if (is.null(tib[['ref']]))
        tib$ref <- 1
    if (is.null(tib[['alt']]))
        tib$alt <- 2
    
    # it's nice to have the main columns be shown in the default order (autocomplete will insert things after existing columns)
    # check if there are any extra columns first
    namesExist <- names(tib)
    indexes <- !(namesExist %in% bim_names) # true for extra names only
    # reorder main columns, stick extras in existing order at the end
    # this works even when all indexes are FALSE
    tib <- tib[, c(bim_names, namesExist[indexes])]
    # done, return tib
    return(tib)
}
