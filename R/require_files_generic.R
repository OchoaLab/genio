require_files_generic <- function(name, exts) {
    if ( missing( name ) )
        stop('Base `name` of files to require is required!')
    if ( missing( exts ) )
        stop('Extensions `exts` of files to require is required!')
    
    # list of files that must exist
    files <- paste0( name, '.', exts )
    
    # check each in order to produce most informative messages
    for ( file in files ) {
        if ( !file.exists( file ) )
            stop( 'Required file is missing: ', file )
    }
}
