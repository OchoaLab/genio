#' Convert an Eigenstrat IND tibble into a Plink FAM tibble
#'
#' This function takes an existing IND tibble and creates a FAM tibble with the same information and dummy values for missing data.
#' In particular, the output FAM tibble will contain these columns with these contents
#' (IND only contain `id`, `sex`, and `label`, so there is no loss of information):
#' - `fam`: IND `label`
#' - `id`: IND `id`
#' - `pat`: `0` (missing paternal ID)
#' - `mat`: `0` (missing maternal ID)
#' - `sex`: IND `sex` converted to Plink integer codes via [sex_to_int()]
#' - `peno`: `0` (missing phenotype)
#'
#' @param ind The input Eigenstrat IND tibble to convert.
#'
#' @return A Plink FAM tibble.
#'
#' @examples
#' # create a sample IND tibble
#' library(tibble)
#' ind <- tibble(
#'   id = 1:3,
#'   sex = c('U', 'M', 'F'),
#'   label = c(1, 1, 2)
#' )
#' # convert to FAM
#' fam <- ind_to_fam(ind)
#' # inspect:
#' fam
#'
#' @seealso
#' [sex_to_int()]
#'
#' Eigenstrat IND format reference:
#' <https://github.com/DReichLab/EIG/tree/master/CONVERTF>
#' 
#' Plink FAM format reference:
#' <https://www.cog-genomics.org/plink/1.9/formats#fam>
#'
#' @export
ind_to_fam <- function(ind) {
    # check that mandatory arguments aren't missing
    if (missing(ind))
        stop('Input tibble/data.frame (ind) is required!')
    
    # validate tibble (check against expected column names)
    validate_tab_generic(ind, 'ind', ind_names)
    
    # the "fam" data we want is a new tibble
    # it contains the same info as the input, adds trivial "missing" parents and phenotype
    # also need to convert `sex` column
    fam <- tibble::tibble(
        fam = ind$label,
        id = ind$id,
        pat = 0,
        mat = 0,
        sex = sex_to_int( ind$sex ),
        pheno = 0,
        )

    # return "fam" tibble
    return(fam)
}

