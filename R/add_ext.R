# This script add desired extension if it's missing
# Unlike real_path, this does not assume file exists (it can be a file to be written later)
#
# Internal function    
add_ext <- function(fo, ext) {
    # both inputs are mandatory
    if (missing(fo))
        stop('Output file (fo) is required!')
    if (missing(ext))
        stop('Expected file extension (ext) is required!')
    
    # test presence of expected extension (must be at the end)
    if ( ! grepl( paste0('\\.', ext, '$'), fo) ) {
        # add extension if it wasn't there already
        fo <- paste0(fo, '.', ext)
    }
    # return whatever fo is now
    return(fo)
}
