# this abstracts general tab writing regardless of specifics of some of the various formats supported
write_tab_generic <- function(file, tib, ext, tib_names, verbose=TRUE) {
    # check that mandatory arguments aren't missing
    if (missing(file))
        stop('output file path (file) is required!')
    if (missing(tib))
        stop('input tibble/data.frame (tib) is required!')
    if (missing(ext))
        stop('output extension (ext) is required!')
    if (missing(tib_names))
        stop('table column names (tib_names) is required!')
    
    # compare against expected columns
    # matching must be exact!
    # get indexes of missing columns
    indexes <- !(tib_names %in% names(tib))
    if (any(indexes))
        stop('missing column names from "', ext, '" input table: ', names(tib)[indexes])
    # now that nothing is missing, extract and reorder columns as needed
    tib <- tib[, tib_names]
    
    # add extension if it wasn't already there
    file <- add_ext(file, ext)
    
    # announce what we ended up writing, nice to know
    if (verbose)
        message('Writing: ', file)
    
    # writes using tab separators
    readr::write_tsv(tib, file, col_names=FALSE)
}
