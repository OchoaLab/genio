#' Convert a genotype matrix from numeric to character codes
#'
#' Given the genotype matrix `X` and `bim` table (as they are parsed by [read_plink()], this outputs a matrix of the same dimensions as `X` but with the numeric codes (all values in 0, 1, 2) translated to human-readable character codes (such as 'A/A', 'A/G', 'G/G', depending on which are the two alleles at the locus as given in the `bim` table, see return value).
#'
#' @param X The genotype matrix.
#' It must have values only in 0, 1, 2, and `NA`.
#' @param bim The variant table.
#' It is required to have the same number of rows as `X`, and to have at least two named columns `alt` and `ref` (alleles 1 and 2 in a plink BIM table).
#' These alleles can be arbitrary strings (i.e. not just SNPs but also indels, any single or multicharacter code, or even blank strings) except the forward slash character ("/") is not allowed anywhere in these strings (function stops if a slash is present), since in the output it is the delimiter string.
#' `ref` and `alt` alleles must be different at each locus.
#' 
#' @return The genotype matrix reencoded as strings.
#' At one locus, if the two alleles (alt and ref) are 'A' and 'B', then the genotypes in the input are encoded as characters as: 0 -> 'A/A', 1 -> 'B/A', and 2 -> 'B/B'.
#' Thus, the numeric encoding counts the reference allele dosage.
#' `NA` values in input `X` remain `NA` in the output.
#' If the input genotype matrix had row and column names, these are inherited by the output matrix.
#'
#' @examples
#' # a numeric/dosage genotype matrix with two loci (rows)
#' # and three individuals (columns)
#' X <- rbind( 0:2, c(0, NA, 2) )
#' # corresponding variant table (minimal case with just two required columns)
#' library(tibble)
#' bim <- tibble( alt = c('C', 'GT'), ref = c('A', 'G') )
#'
#' # genotype matrix translated as characters
#' X_char <- geno_to_char( X, bim )
#' X_char
#' 
#' @seealso
#' [read_plink()],
#' [read_bed()],
#' [read_bim()].
#' 
#' @export
geno_to_char <- function( X, bim ) {
    # all inputs are mandatory
    if ( missing( X ) )
        stop( '`X` is mandatory!' )
    if ( missing( bim ) )
        stop( '`bim` is mandatory!' )

    ### DIMS ###

    # rows of bim and X should agree
    m <- nrow( X )
    if ( nrow( bim ) != m )
        stop( 'Number of rows disagree!  X: ', m, '; bim: ', nrow( bim ) )
    
    ### BIM validation ###

    # expect two alleles only! (could generalize one day maybe)
    if ( is.null( bim$ref ) )
        stop( '`bim` must have a `ref` column!' )
    if ( is.null( bim$alt ) )
        stop( '`bim` must have an `alt` column!' )
    # there can be arbitrarily long and various characters, except slashes (only reserved character)
    indexes <- grepl( '/', bim$ref )
    if ( any( indexes ) ) {
        examples <- unique( bim$ref[ indexes ] )
        if ( length( examples ) > 10 )
            examples <- c( examples[ 1 : 10 ], '...' )
        stop( 'Some elements of `bim$ref` contain slashes (not allowed as it is the allele delimiter in output): ', toString( examples ) )
    }
    # repeat for alt
    indexes <- grepl( '/', bim$alt )
    if ( any( indexes ) ) {
        examples <- unique( bim$alt[ indexes ] )
        if ( length( examples ) > 10 )
            examples <- c( examples[ 1 : 10 ], '...' )
        stop( 'Some elements of `bim$alt` contain slashes (not allowed as it is the allele delimiter in output): ', toString( examples ) )
    }

    ### BED validation ###

    # assumption is all x are in 0,1,2 or NA
    if ( !is.numeric( X ) )
        stop( '`x` must be a numeric vector!' )
    x_valid <- c(0, 1, 2, NA)
    if ( !all( X %in% x_valid ) ) {
        # get unique extra observations, for informative message
        extras <- unique( X[ !(X %in% x_valid) ] )
        # if this happens to be very long, let's cut it at 10 and add "..."
        if ( length( extras ) > 10 )
            extras <- c( extras[ 1 : 10 ], '...' )
        stop( 'All elements of `x` must be in ', toString( x_valid ), '!  Observed these additional cases: ', toString( extras ) )
    }

    ### MAP ###

    # now that all assumptions are met, actually start conversion
    # write an array parallel to x_valid stating the conversion map
    # map is different for each row!
    Y <- matrix( NA, nrow = m, ncol = ncol( X ) )
    # transfer names from X to Y
    # (Y is always blank, so pass whatever X has
    dimnames( Y ) <- dimnames( X )
    for ( i in 1 : m ) {
        # get data from that row only
        x <- X[ i, ]
        a <- bim$alt[i] # ALT is first allele
        r <- bim$ref[i] # REF is second allele
        if ( a == r )
            stop( 'Alleles at locus number ', i, ' are equal (both are ', a, ')!' )
        # which case is which is so confusing!
        # https://www.cog-genomics.org/plink/1.9/formats#bed
        # BED  X
        # 00=0 2  Homozygous for first allele in .bim file
        # 01=1 NA Missing genotype
        # 10=2 1  Heterozygous
        # 11=3 0  Homozygous for second allele in .bim file
        y_valid <- c(
            paste0(r, '/', r), # 0
            paste0(r, '/', a), # 1
            paste0(a, '/', a), # 2
            NA
        )
        # perform map
        Y[ i, ] <- y_valid[ match( x, x_valid ) ]
    }
    # return the mapped character matrix
    return( Y )
}
