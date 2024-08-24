#' Create a symbolic link to a file, adjusting paths automatically if needed
#'
#' This function creates a symbolic (soft) link to a file, in a solution that works for all major operating systems, so a file can have two names without actually duplicating data.
#' Although the two paths can be specified directly, this function automatically handles a conversion for a common but troublesome case when the link is not in the current directory, in which case the file must be relative to the parent directory of the link, although it is more natural to specify the file relative to the current directory.
#'
#' @param file The file that will be linked.
#' This function does not require this file to exist, but the link will be broken in that case.
#' @param link The path to the link to the file.
#' If this points to an existing file, or an existing link, it will be overwritten.
#' @param adjust_path If `TRUE` (default), `file` is automatically adjusted in the special case in which it is a relative path (assumed to be relative to current directory) but `link` is not in the current directory, in which case `file` is adjusted to be relative to the parent directory of `link`.
#' If `file` is an absolute path, it is never edited, and likewise no editing is needed if `link` is in the current directory.
#' Set to `FALSE` to avoid editing in all cases.
#' @param verbose If `TRUE` (default), function reports the `link` and the final `file` it points to.
#'
#' @examples
#' # in this example, for the existing file, use this file provided by the package.
#' # Note that it is an absolute path, so it will not be edited.
#' file <- system.file("extdata", 'sample.bed', package = "genio", mustWork = TRUE)
#' # this is the path to the link
#' link <- tempfile('delete-me-example', fileext = '.bed')
#' 
#' # create the symbolic link!
#' symlink( file, link )
#'
#' # delete example link when done
#' file.remove( link )
#' 
#' @export
symlink <- function( file, link, adjust_path = TRUE, verbose = TRUE ) {

    if ( adjust_path ) {
        # the regular commands further below already work in common cases, but fail if both `file` is relative (to current directory) and `link` is not in current directory!
        # first we fix this exact problem with R.utils magical functions!  (very tricky to get it to work on Windows, Linux, and MacOS)
        # first ask if `link` is not in current directory this way (returns NULL for files in current dir)
        dir_out <- R.utils::getParent( link )
        # and also don't try to edit `file` if it's already absolute (best behavior is to keep absolute; getRelativePath forces relative which can have unintended consequences)
        if ( !R.utils::isAbsolutePath( file ) && !is.null( dir_out ) ) {
            # corrects relative path to be in terms of destination!
            file <- R.utils::getRelativePath( file, dir_out )
        }
    }

    # announce update if verbose
    if ( verbose )
        message( 'Symlink: ', link, ' -> ', file )
    
    # create symlink!
    if ( .Platform$OS.type == 'unix' ) {
        # linux and macos, here solution is the same for both!
        system2( 'ln', c( '-s', '-f', file, link ) )
        # in my experience, this only fails if `link` already existed and we didn't '-f' (force), but since we did force, I think this will never fail
    } else {
        # windows version, default is sybolic link as desired, no "force" version
        # this can fail due to permissions (in Windows 10?) or because the function doesn't exist (in older Windowses), let it fail verbosely and move on?
        system2( 'mklink', c( link, file ) )
    }
}
