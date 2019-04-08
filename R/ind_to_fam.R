#' Convert an eigenstrat IND tibble into a plink FAM tibble
#'
#' This function takes an existing IND tibble and creates a FAM tibble with the same information and dummy values for missing data.
#' In particular, the output FAM tibble will contain these columns with these contents:
#' \describe{
#'   \item{fam:}{ IND label }
#'   \item{id:}{ IND id }
#'   \item{pat:}{ \code{0} (missing paternal ID) }
#'   \item{mat:}{ \code{0} (missing maternal ID) }
#'   \item{sex:}{ IND sex converted to plink integer codes via \code{\link{sex_to_int}} }
#'   \item{peno:}{ \code{0} (missing phenotype) }
#' }
#' As IND tibbles only contain the three columns listed above, there is no loss of information.
#'
#' @param ind The input eigenstrat IND tibble to convert.
#'
#' @return A plink FAM tibble.
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
#' \code{\link{sex_to_int}}
#'
#' Eigenstrat IND format reference:
#' \url{https://github.com/DReichLab/EIG/tree/master/CONVERTF}
#' 
#' Plink FAM format reference:
#' \url{https://www.cog-genomics.org/plink/1.9/formats#fam}
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

