# Tries to fix path when a name is provided but not found, and an extension is expected
# This function simply returns the input path when its guesses don't result in files that exist, doesn't die unless arguments are missing.
#
# Internal function    
real_path <- function(fi, ext) {
    # both inputs are mandatory
    if (missing(fi)) stop('Fatal: input file (fi) is required!')
    if (missing(ext)) stop('Fatal: expected file extension (ext) is required!')
    
    # if "fi" was not a character object, then the following manipulations won't work, so just return that and hope for the best
    if (!is.character(fi)) return(fi)
    # ditto if file already exists, we're set!
    if (file.exists(fi)) return(fi)
    # now assume file as specified is not found

    # if the file already ends in .gz, don't do anything!
    # this is because .gz must be the final extension, we won't try to fix this path
    if ( grepl('\\.gz$', fi) ) return(fi)
    # now assume .gz is missing
    
    # test presence of expected extension
    # in the absence of .gz, the expected extension must be the last one ("$" in regex below)
    if ( grepl( paste0('\\.', ext, '$'), fi) ) {
        # here we already have the .fam extension but not .gz, so try adding it
        # try adding extension if input file wasn't found
        fiGz <- paste0(fi, '.gz')
        # if the second version exists, use that!
        if (file.exists(fiGz)) fi <- fiGz
        # return fi, whatever that is here
        return(fi)
    }
    
    # now assume both extensions are missing
    # add .fam first
    fiExt <- paste0(fi, '.', ext)
    if (file.exists(fiExt)) {
        # if the second version exists, use that!
        # (otherwise stay with fi, whatever that is)
        fi <- fiExt
    } else {
        # try add gzip extension too
        fiExtGz <- paste0(fiExt, '.gz')
        if (file.exists(fiExtGz)) fi <- fiExtGz
    }
    # return whatever fi is now (in case of failure it's just input)
    return(fi)
}
