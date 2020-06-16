# a generic deleter of files with nice informative messages
# expects all of the files to delete to actually exists, otherwise throws warnings
# also warns when things were there but not deleted
delete_files_generic <- function(name, exts) {
    # list of files that must exist
    files <- paste0(name, '.', exts)
    
    # check each in order to produce most informative messages
    for (file in files) {
        # test that it's actually there!
        if( file.exists( file ) ) {
            # remove if it was there
            if ( !file.remove( file ) )
                warning( 'Could not remove file: ', file )
        } else {
            warning( 'File to remove did not exist: ', file )
        }
    }
}
