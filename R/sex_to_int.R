#' Convert character sex codes to integer codes
#'
#' This function accepts the character sex codes accepted by Eigenstrat and turns them into the integer codes accepted by Plink.
#' Matching is case insensitive.
#' Cases outside the table below are mapped to `0` (unknown) with a warning.
#' The correspondence is:
#' - `U`: `0` (unknown)
#' - `M`: `1` (male)
#' - `F`: `2` (female)
#' 
#' @param sex Character vector of sex codes
#'
#' @return The converted numeric vector of sex codes
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
#' [sex_to_char()]
#' 
#' Eigenstrat IND format reference:
#' <https://github.com/DReichLab/EIG/tree/master/CONVERTF>
#' 
#' Plink FAM format reference:
#' <https://www.cog-genomics.org/plink/1.9/formats#fam>
#'
#' @export
sex_to_int <- function(sex) {
    if (missing(sex))
        stop('Required `sex` is missing!')
    
    # converts character sex codes (used by Eigenstrat) into integers (used by Plink)
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
