#include <Rcpp.h>
#include <cerrno>
using namespace Rcpp;

// expected header (magic numbers)
// assume standard locus-major order and latest format
const unsigned char plink_bed_byte_header[3] = {0x6c, 0x1b, 1};

// [[Rcpp::export]]
IntegerMatrix read_bed_cpp(const char* file, int m_loci, int n_ind) {
  // - file assumed to be full path (no missing extensions)
  // unfortunately BED format requires dimensions to be known
  // (so outside this function, the BIM and FAM files must be parsed first)

  // open input file in "binary" mode
  FILE *file_stream = fopen( file, "rb" );
  // die right away if needed, before initializing buffers etc
  if ( file_stream == NULL ) {
    // send error message to R
    char msg[100];
    sprintf(msg, "Could not open BED file `%s` for reading: %s", file, strerror( errno ));
    stop(msg);
  }

  /////////////////////////
  // check magic numbers //
  /////////////////////////

  // for header only
  unsigned char *buffer_header = (unsigned char *) malloc( 3 );
  // for extra sanity checks, keep track of bytes actually read (to recognize truncated files)
  // reuse this one for genotypes below
  size_t n_buf_read;
  
  // read header bytes (magic numbers)
  n_buf_read = fread( buffer_header, sizeof(unsigned char), 3, file_stream );
  // this might just indicate an empty file
  if ( n_buf_read != 3 ) {
    // wrap up everything properly
    free( buffer_header ); // free buffer memory
    fclose( file_stream ); // close file
    // now send error message to R
    stop("Input BED file did not have a complete header (3-byte magic numbers)!");
  }
  
  // require that they match our only supported specification of locus-major order and latest format
  // was using strcmp but there are funky issues (wants signed, but we don't really want order anyway, just test for equality)
  // use explicit loop instead
  int pos;
  for (pos = 0; pos < 3; pos++) {
    if ( plink_bed_byte_header[pos] != buffer_header[pos] ) {
      // wrap up everything properly
      free( buffer_header ); // free buffer memory
      fclose( file_stream ); // close file
      // now send error message to R
      stop("Input BED file is not in supported format.  Either magic numbers do not match, or requested sample-major format is not supported.  Only latest locus-major format is supported!");
    }
  }

  // free header buffer, completely done with it
  free( buffer_header );

  
  ////////////////////
  // read genotypes //
  ////////////////////
  
  // number of columns (bytes) in input (for buffer), after byte compression
  // size set for full row, but overloaded used first for this header comparison
  // chose size_t to have it match n_buf_read value returned by fread
  size_t n_buf = ( n_ind + 3 ) / 4;
  // initialize row buffer
  unsigned char *buffer = (unsigned char *) malloc( n_buf );
  
  // initialize our genotype matrix
  IntegerMatrix X(m_loci, n_ind);
  
  // navigate data and process
  int i, j;
  size_t k; // to match n_buf type
  unsigned char buf_k; // working of buffer at k'th position
  unsigned char xij; // copy of extracted genotype
  for (i = 0; i < m_loci; i++) {
    
    // read whole row into buffer
    n_buf_read = fread( buffer, sizeof(unsigned char), n_buf, file_stream );
    
    // always check that file was not done too early
    if ( n_buf_read != n_buf ) {
      // wrap up everything properly
      free( buffer ); // free buffer memory
      fclose( file_stream ); // close file
      // now send error message to R
      char msg[100];
      sprintf(msg, "Truncated file: row %d terminated at %d bytes, expected %d.", i+1, (int) n_buf_read, (int) n_buf); // convert to 1-based coordinates
      stop(msg);
    }

    // process buffer now!

    // always reset these at start of row
    j = 0; // individuals

    // navigate buffer positions k (not individuals j)
    for (k = 0; k < n_buf; k++) {
      
      // copy down this value, which will be getting edited
      buf_k = buffer[k];
      
      // navigate the four positions
      // pos is just a dummy counter not really used except to know when to stop
      // update j too, accordingly
      for (pos = 0; pos < 4; pos++, j++) {

	if (j < n_ind) {
	  // extract current genotype using this mask
	  // (3 == 00000011 in binary)
	  xij = buf_k & 3;
	
	  // re-encode into proper values, store in R matrix
	  // for maximum speed, test for most common cases first: the homozygotes
	  // - this is because of the binomial expansion:
	  //   (p-q)^2 = p^2 + q^2 - 2pq > 0,
	  //   so `2pq` is always smaller than `p^2 + q^2`.
	  //   `2pq` becomes rarer under population structure!
	  // next most common ought to be the heterozygote, then NA, but as these are mutually exclusive then it doesn't matter
	  if (xij == 0) {
	    X(i, j) = 2; // 0 -> 2
	  } else if (xij == 2) {
	    X(i, j) = 1; // 2 -> 1
	  } else if (xij == 1) {
	    X(i, j) = NA_INTEGER; // 1 -> NA
	  } 
	  // there are no other values, so 3 -> 0 must be the case here
	  // R's IntegerMatrix are initialized to zeroes, so no edits are necessary!
	  
	  // shift packed data, throwing away genotype we just processed
	  buf_k = buf_k >> 2;
	} else {
	  // when j is out of range, we're in the padding data now
	  // as an extra sanity check, the remaining data should be all zero (that's how the encoding is supposed to work)
	  // non-zero values would strongly suggest that n_ind was not set correctly
	  if (buf_k != 0) {
	    // wrap up everything properly
	    free( buffer ); // free buffer memory
	    fclose( file_stream ); // close file
	    // now send error message to R
	    char msg[200];
	    sprintf(msg, "Row %d padding was non-zero.  Either the specified number of individuals is incorrect or the input file is corrupt!", i+1); // convert to 1-based coordinates
	    stop(msg);
	  }
	}
      }
      // finished byte
      
    }
    // finished row
    
  }
  // finished matrix!

  // let's check that file was indeed done
  n_buf_read = fread( buffer, sizeof(unsigned char), n_buf, file_stream );
  // wrap up regardless
  // and more troubleshooting messages (for windows)
  if ( fclose( file_stream ) != 0 )
    stop("Input BED file stream close failed!");
  free( buffer );
  if ( n_buf_read != 0 ) {
    // now send error message to R
    stop("Input BED file continued after all requested rows were read!  Either the specified the number of loci was too low or the input file is corrupt!");
  }

  // return genotype matrix
  return X;
}
