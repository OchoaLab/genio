#' Convert integer sex codes to character codes
#'
#' This function accepts the integer sex codes accepted by plink and turns them into the character codes accepted by eigenstrat.
#' Only upper-case characters are returned.
#' The correspondence is:
#' \describe{
#'   \item{0:}{ U (unknown) }
#'   \item{1:}{ M (male) }
#'   \item{2:}{ F (female) }
#' }
#' Any other cases will also be mapped to U (unknown) but with a warning (0 does not generate warnings).
#'
#' @param sex Integer vector of sex codes
#'
#' @return The converged character vector of sex codes
#'
#' @examples
#' # verify the mapping above
#' sex_int <- 0:2
#' sex_char <- c('U', 'M', 'F') # expected values
#' stopifnot(
#'   all(
#'     sex_to_char( sex_int ) == sex_char
#'   )
#' )
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
sex_to_char <- function(sex) {
    if (missing(sex))
        stop('Required `sex` is missing!')
    
    # converts integers sex codes (used by plink) into character (used by eigenstrat)
    sex <- chartr('012', 'UMF', sex)
    
    # look for things that were not translated
    indeces <- !( sex %in% c('U', 'M', 'F') ) # bad cases (potentially)
    if (any(indeces)) {
        # message
        warning('Invalid sex values outside of 0,1,2 treated as missing: ', unique(sex[indeces]))
        # map them to unknowns
        sex[indeces] <- 'U'
    }
    
    # return modified vector when done
    return(sex)
}
