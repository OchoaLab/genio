#' Convert character sex codes to integer codes
#'
#' This function accepts the character sex codes accepted by eigenstrat and turns them into the integer codes accepted by plink.
#' Matching is case insensitive.
#' The correspondence is:
#' \describe{
#'   \item{U:}{ 0 (unknown) }
#'   \item{M:}{ 1 (male) }
#'   \item{F:}{ 2 (female) }
#' }
#' Any other characters will also be mapped to 0 (unknown) but with a warning (U does not generate warnings).
#'
#' @param sex Character vector of sex codes
#'
#' @return The converged numeric vector of sex codes
#'
#' @examples
#' # verify the mapping above
#' sex_char <- c('U', 'm', 'f') # mixed case works!
#' sex_int <- 0:2 # expected values
#' stopifnot(
#'   all(
#'     sex_to_int( sex_char ) == sex_int
#'   )
#' )
#'
#' @seealso
#' \code{\link{sex_to_char}}
#' 
#' Eigenstrat IND format reference:
#' \url{https://github.com/DReichLab/EIG/tree/master/CONVERTF}
#' 
#' Plink FAM format reference:
#' \url{https://www.cog-genomics.org/plink/1.9/formats#fam}
#'
#' @export
sex_to_int <- function(sex) {
    if (missing(sex))
        stop('Required `sex` is missing!')
    
    # converts character sex codes (used by eigenstrat) into integers (used by plink)
    # this is super quick, but returns characters
    sex <- chartr('UuMmFf', '001122', sex)
    
    # look for things that were not translated
    indeces <- !( sex %in% 0:2 ) # bad cases (potentially)
    if (any(indeces)) {
        # message
        warning('Invalid sex values outside of U,M,F treated as missing: ', unique(sex[indeces]))
        # map them to zeroes
        sex[indeces] <- 0
    }
    
    # convert to integers
    sex <- as.numeric(sex)
    
    # return modified vector when done
    return(sex)
}
