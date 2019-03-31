#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
void write_bed_cpp(const char* fo, IntegerMatrix X) {
  // NOTES:
  // - code partly based on libplinkio and Wei's R version
  // - input assumed to be padded and reencoded already

  int nrow = X.nrow();
  int ncol = X.ncol();
  // number of columns (bytes) in output (for buffer), after byte compression
  int nbuf = ( ncol + 3 ) / 4;
  // initialize row buffer
  unsigned char *buffer = (unsigned char *) malloc( nbuf );

  // open output file
  FILE *fho = fopen( fo, "w" );
  if ( fho == NULL )
    stop("Fatal: could not open BED file for writing!");

  // write header
  // assume standard locus-major order and latest format
  unsigned char byte_header[3] = {0x6c, 0x1b, 1};
  fwrite( byte_header, sizeof(unsigned char), 3, fho );

  // navigate data and process
  // int j; // to map buffer to input indeces
  int k, rem;
  for (int i = 0; i < nrow; i++) {
    // zero out buffer for new row
    bzero( buffer, nbuf );
    // always reset these at start of row
    k = 0; // to map input to buffer indeces
    rem = 0; // to map bit position within byte
    for (int j = 0; j < ncol; j++) {
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
	stop("Error: encountered a value outside of 0:2 and NA");
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
    fwrite( buffer, 1, nbuf, fho );
  }

  fclose( fho );

  // done with buffer
  free( buffer );
}
