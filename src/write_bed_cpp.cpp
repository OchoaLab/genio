#include <iostream>
#include <fstream>
#include <vector>
#include <Rcpp.h>
#include "constants.h"
using namespace Rcpp;

// [[Rcpp::export]]
void write_bed_cpp(const char* file, IntegerMatrix X, bool append) {
  // - file assumed to be full path (no missing extensions)
  // - append = TRUE changes mode and prevents writing of header
  
  size_t m_loci = X.nrow();
  size_t n_ind = X.ncol();
  // number of columns (bytes) in output (for buffer), after byte compression
  size_t n_buf = ( n_ind + 3 ) / 4;
  // initialize row buffer
  std::vector<char> buffer_out( n_buf );

  // open output file
  // append changes mode
  std::ios_base::openmode mode = std::ios::binary;
  if ( append )
    mode |= std::ios::app;
  std::ofstream file_out_stream( file, mode );
  if ( !file_out_stream.is_open() )
    stop( "Could not open BED file `%s` for writing!", file );
  
  if ( !append ) {
    // write header
    // NOTE: append has to be FALSE for header to be written.  Outside R wrapper code forces append = FALSE when file does not exist (so this is written the first time only).  This Rcpp function does not check for file existence
    // assume standard locus-major order and latest format
    file_out_stream.write( (char *)plink_bed_byte_header, 3 );
  }

  // navigate data and process
  size_t i, j, k, rem;
  for (i = 0; i < m_loci; i++) {
    // zero out output buffer for new row
    std::fill( buffer_out.begin(), buffer_out.end(), 0 );
    // always reset these at start of row
    k = 0; // to map input to buffer indeces
    rem = 0; // to map bit position within byte
    for (j = 0; j < n_ind; j++) {
      // this does some efficient bit operations:
      // - "|=" adds things in the empty bit positions
      // - "<<" puts the new number in the right bit position
      // map cases here (this is sadly so unintuitive)
      if (X(i,j) == NA_INTEGER) {
	buffer_out[k] |= (1 << rem); // NA -> 1
      } else if (X(i,j) == 1) {
	buffer_out[k] |= (2 << rem); // 1 -> 2
      } else if (X(i,j) == 0) {
	buffer_out[k] |= (3 << rem); // 0 -> 3
      } else if (X(i,j) != 2) { // 2 -> 0, so do nothing there, but die if we had any other values!
	file_out_stream.close();
	remove( file ); // delete partial output (will be useless binary data anyway)
	// now send error message to R
	stop( "Invalid genotype '%d' at row %u, col %u.", X(i,j), i+1, j+1 ); // convert to 1-based coordinates
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
    file_out_stream.write( buffer_out.data(), n_buf );
  }

  file_out_stream.close();
}
