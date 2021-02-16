#' Convert integer sex codes to character codes
#'
#' This function accepts the integer sex codes accepted by Plink and turns them into the character codes accepted by Eigenstrat.
#' Only upper-case characters are returned.
#' Cases outside the table below are mapped to `U` (unknown) with a warning.
#' The correspondence is:
#' - `0`: `U` (unknown)
#' - `1`: `M` (male)
#' - `2`: `F` (female)
#'
#' @param sex Integer vector of sex codes
#'
#' @return The converted character vector of sex codes
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
#' [sex_to_int()]
#' 
#' Eigenstrat IND format reference:
#' <https://github.com/DReichLab/EIG/tree/master/CONVERTF>
#' 
#' Plink FAM format reference:
#' <https://www.cog-genomics.org/plink/1.9/formats#fam>
#'
#' @export
sex_to_char <- function(sex) {
    if (missing(sex))
        stop('Required `sex` is missing!')
    
    # converts integers sex codes (used by Plink) into character (used by Eigenstrat)
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
