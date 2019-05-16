# dies with informative error messages if input is not tibble or if expected column names are missing
validate_tab_generic <- function(tib, ext, tib_names) {
    # check that mandatory arguments aren't missing
    if (missing(tib))
        stop('Input tibble/data.frame (tib) is required!')
    if (missing(ext))
        stop('Output extension (ext) is required!')
    if (missing(tib_names))
        stop('Table column names (tib_names) is required!')

    # validate ind
    if (!is.data.frame(tib)) # tibbles satisfy this
        stop('Input "', ext, '" is not a data.frame (includes tibbles)')
    
    # check input names
    indexes <- !(tib_names %in% names(tib))
    if (any(indexes))
        stop('Missing column names from "', ext, '" input table: ', tib_names[indexes])
}
