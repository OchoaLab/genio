# Tries to fix path when a name is provided but not found, and an extension is expected
# This function simply returns the input path when its guesses don't result in files that exist, doesn't die unless arguments are missing.
#
# Internal function    
real_path <- function(file, ext) {
    # both inputs are mandatory
    if (missing(file))
        stop('Input file is required!')
    if (missing(ext))
        stop('Expected file extension (ext) is required!')
    
    # if "file" was not a character object, then the following manipulations won't work, so just return that and hope for the best
    if (!is.character(file))
        return(file)
    # ditto if file already exists, we're set!
    if (file.exists(file))
        return(file)
    # now assume file as specified is not found

    # if the file already ends in .gz, don't do anything!
    # this is because .gz must be the final extension, we won't try to fix this path
    if ( grepl('\\.gz$', file) )
        return(file)
    # now assume .gz is missing
    
    # test presence of expected extension
    # in the absence of .gz, the expected extension must be the last one ("$" in regex below)
    if ( grepl( paste0('\\.', ext, '$'), file) ) {
        # here we already have the .fam extension but not .gz, so try adding it
        # try adding extension if input file wasn't found
        fileGz <- paste0(file, '.gz')
        # if the second version exists, use that!
        if (file.exists(fileGz))
            file <- fileGz
        # return file, whatever that is here
        return(file)
    }
    
    # now assume both extensions are missing
    # add .fam first
    fileExt <- paste0(file, '.', ext)
    if (file.exists(fileExt)) {
        # if the second version exists, use that!
        # (otherwise stay with file, whatever that is)
        file <- fileExt
    } else {
        # try add gzip extension too
        fileExtGz <- paste0(fileExt, '.gz')
        if (file.exists(fileExtGz))
            file <- fileExtGz
    }
    
    # return whatever file is now (in case of failure it's just input)
    return(file)
}
