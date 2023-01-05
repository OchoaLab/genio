#include <Rcpp.h>
#include <string.h>
#include <cerrno>
using namespace Rcpp;

// [[Rcpp::export]]
void write_bed_cpp(const char* file, IntegerMatrix X, bool append) {
  // - file assumed to be full path (no missing extensions)
  // - append = TRUE changes mode and prevents writing of header
  
  int n_ind = X.nrow();
  int m_loci = X.ncol();
  // number of columns (bytes) in output (for buffer), after byte compression
  int n_buf = ( m_loci + 3 ) / 4;
  // initialize row buffer
  unsigned char *buffer = (unsigned char *) malloc( n_buf );

  // append changes mode
  const char *mode = ( append ) ? "ab" : "wb";
  // open output file
  FILE *file_stream = fopen( file, mode );
  if ( file_stream == NULL ) {
    // send error message to R
    stop( "Could not open BED file `%s` for writing: %s", file, strerror( errno ) );
  }

  if ( !append ) {
    // write header
    // NOTE: append has to be FALSE for header to be written.  Outside R wrapper code forces append = FALSE when file does not exist (so this is written the first time only).  This Rcpp function does not check for file existence
    // assume standard locus-major order and latest format
    unsigned char byte_header[3] = {0x6c, 0x1b, 1};
    fwrite( byte_header, sizeof(unsigned char), 3, file_stream );
  }

  // navigate data and process
  int i, j, k, rem;
  for (i = 0; i < n_ind; i++) {
    // zero out buffer for new row
    memset( buffer, 0, n_buf );
    // always reset these at start of row
    k = 0; // to map input to buffer indeces
    rem = 0; // to map bit position within byte
    for (j = 0; j < m_loci; j++) {
      // this does some efficient bit operations:
      // - "|=" adds things in the empty bit positions
      // - "<<" puts the new number in the right bit position
      // map cases here (this is sadly so unintuitive)
      if (X(i,j) == NA_INTEGER) {
	buffer[k] |= (1 << rem); // NA -> 1
      } else if (X(i,j) == 1) {
	buffer[k] |= (2 << rem); // 1 -> 2
      } else if (X(i,j) == 0) {
	buffer[k] |= (3 << rem); // 0 -> 3
      } else if (X(i,j) != 2) { // 2 -> 0, so do nothing there, but die if we had any other values!
	// wrap up everything properly
	free( buffer ); // free buffer memory
	fclose( file_stream ); // close file
	remove( file ); // delete partial output (will be useless binary data anyway)
	// now send error message to R
	stop( "Invalid genotype '%d' at row %d, col %d.", X(i,j), i+1, j+1 ); // convert to 1-based coordinates
      }

      // update these variables for next round
      if (rem == 6) {
	rem = 0; // start a new round
	k++; // this only increments in this case
      } else {
	rem += 2; // increment as usual (always factors of two)
      }
    }
    
    // write buffer (row) out 
    fwrite( buffer, 1, n_buf, file_stream );
  }

  if ( fclose( file_stream ) != 0 )
    stop("Input BED file stream close failed!");

  // done with buffer
  free( buffer );
}
