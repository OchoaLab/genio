# this abstracts general tab reading regardless of specifics of some of the various formats supported
read_tab_generic <- function(file, ext, tib_names, col_types, verbose = TRUE) {
    # check that mandatory arguments aren't missing
    if (missing(file))
        stop('Input file path (file) is required!')
    if (missing(ext))
        stop('Input extension (ext) is required!')
    if (missing(tib_names))
        stop('Table column names (tib_names) is required!')
    if (missing(col_types))
        stop('Table column types (col_types) is required!')
    
    # add .ext and/or .gz if missing and needed
    file <- real_path(file, ext)
    
    # announce what we ended up loading, nice to know
    if (verbose)
        message('Reading: ', file)
    
    # read input
    ind <- readr::read_table2(
                      file,
                      col_names = tib_names,
                      col_types = col_types
                  )
}
