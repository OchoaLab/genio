# dies with informative error messages if input is not tibble or if expected column names are missing
validate_tab_generic <- function(tib, ext, tib_names) {
    # check that mandatory arguments aren't missing
    if (missing(tib))
        stop('input tibble/data.frame (tib) is required!')
    if (missing(ext))
        stop('output extension (ext) is required!')
    if (missing(tib_names))
        stop('table column names (tib_names) is required!')

    # validate ind
    if (!is.data.frame(tib)) # tibbles satisfy this
        stop('Fatal: Input "', ext, '" is not a data.frame (includes tibbles)')
    
    # check input names
    indexes <- !(tib_names %in% names(tib))
    if (any(indexes))
        stop('missing column names from "', ext, '" input table: ', tib_names[indexes])
}
