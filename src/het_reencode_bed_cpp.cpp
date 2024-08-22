#include <Rcpp.h>
#include <cerrno>
using namespace Rcpp;

// NOTE: redundant (copied in all BED CPP functions), should define it once and share it!!!
// expected header (magic numbers)
// assume standard locus-major order and latest format
const unsigned char plink_bed_byte_header[3] = {0x6c, 0x1b, 1};

// [[Rcpp::export]]
void het_reencode_bed_cpp(const char* file_in, const char* file_out, int m_loci, int n_ind) {
  // - files assumed to be full path (no missing extensions)
  // unfortunately BED format requires dimensions to be known
  // (so outside this function, the BIM and FAM files must be parsed first)

  ////////////////
  // OPEN INPUT //
  ////////////////

  // open file_in in "binary" mode
  FILE *file_in_stream = fopen( file_in, "rb" );
  // die right away if needed, before initializing buffers etc
  if ( file_in_stream == NULL ) {
    // send error message to R
    stop( "Could not open BED file `%s` for reading: %s", file_in, strerror( errno ) );
  }

  /////////////////////////////////////
  // OPEN INPUT: check magic numbers //
  /////////////////////////////////////

  // for header only
  unsigned char *buffer_header = (unsigned char *) malloc( 3 );
  // for extra sanity checks, keep track of bytes actually read (to recognize truncated files)
  // reuse this one for genotypes below
  size_t n_buf_read;
  
  // read header bytes (magic numbers)
  n_buf_read = fread( buffer_header, sizeof(unsigned char), 3, file_in_stream );
  // this might just indicate an empty file
  if ( n_buf_read != 3 ) {
    // wrap up everything properly
    free( buffer_header ); // free buffer memory
    fclose( file_in_stream ); // close file
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
      fclose( file_in_stream ); // close file
      // now send error message to R
      stop("Input BED file is not in supported format.  Either magic numbers do not match, or requested sample-major format is not supported.  Only latest locus-major format is supported!");
    }
  }

  // free header buffer, completely done with it
  free( buffer_header );

  /////////////////
  // OPEN OUTPUT //
  /////////////////

  // open output file
  FILE *file_out_stream = fopen( file_out, "wb" );
  if ( file_out_stream == NULL ) {
    // send error message to R
    stop( "Could not open BED file `%s` for writing: %s", file_out, strerror( errno ) );
  }

  // write header
  // assume standard locus-major order and latest format
  fwrite( plink_bed_byte_header, sizeof(unsigned char), 3, file_out_stream );

  //////////////////////////////
  // read and write genotypes //
  //////////////////////////////
  
  // number of columns (bytes) in input (for buffer), after byte compression
  // size set for full row, but overloaded used first for this header comparison
  // chose size_t to have it match n_buf_read value returned by fread
  // NOTE: though here it might seem odd to process rows (rather than individual values), the fact that there's padding means this sort of makes more sense
  size_t n_buf = ( n_ind + 3 ) / 4;
  // initialize input and output row buffers
  unsigned char *buffer_in = (unsigned char *) malloc( n_buf );
  unsigned char *buffer_out = (unsigned char *) malloc( n_buf );

  // navigate data and process
  int i, j, rem;
  size_t k; // to match n_buf type
  unsigned char buf_in_k; // working of buffer at k'th position
  unsigned char xij; // copy of extracted genotype
  for (i = 0; i < m_loci; i++) {
    
    // read whole row into buffer
    n_buf_read = fread( buffer_in, sizeof(unsigned char), n_buf, file_in_stream );
    
    // always check that file was not done too early
    if ( n_buf_read != n_buf ) {
      // wrap up everything properly
      free( buffer_in ); // free buffer memory
      fclose( file_in_stream ); // close file
      // now send error message to R
      stop( "Truncated file: row %d terminated at %d bytes, expected %d.", i+1, (int) n_buf_read, (int) n_buf); // convert to 1-based coordinates
    }

    // zero out output buffer for new row
    memset( buffer_out, 0, n_buf );

    // process buffer now!

    // always reset these at start of row
    j = 0; // individuals
    rem = 0; // to map bit position within byte

    // navigate buffer positions k (not individuals j)
    for (k = 0; k < n_buf; k++) {
      
      // copy down this value, which will be getting edited
      buf_in_k = buffer_in[k];
      
      // navigate the four positions
      // pos is just a dummy counter not really used except to know when to stop
      // update j too, accordingly
      for (pos = 0; pos < 4; pos++, j++) {

	if (j < n_ind) {
	  // extract current genotype using this mask
	  // (3 == 00000011 in binary)
	  xij = buf_in_k & 3;
	
	  // re-encode from genotypes to (2x) heterozygote indicators in BED encoding (not paper encoding), overwriting value
	  // two values are fixed (in paper encoding, 0 and NA), and the other two can conflict if performed in the opposite order than this one:
	  if (xij == 0) {
	    xij = 3; // in paper encoding, this maps 2 to 0
	  } else if (xij == 2) {
	    xij = 0; // in paper encoding, this maps 1 to 2
	  } 
	  
	  // shift input packed data, throwing away genotype we just processed
	  buf_in_k = buf_in_k >> 2;
	  // and push to output
	  buffer_out[k] |= (xij << rem);

	  // update these variables for next round
	  if (rem == 6) {
	    rem = 0; // start a new round
	  } else {
	    rem += 2; // increment as usual (always factors of two)
	  }
	}
      }
      // finished byte
      
    }
    // finished row

    // write buffer (row) out 
    fwrite( buffer_out, 1, n_buf, file_out_stream );
  }
  // finished matrix/file!

  /////////////////
  // CLOSE INPUT //
  /////////////////

  // let's check that file was indeed done
  n_buf_read = fread( buffer_in, sizeof(unsigned char), n_buf, file_in_stream );
  // wrap up regardless
  // and more troubleshooting messages (for windows)
  if ( fclose( file_in_stream ) != 0 )
    stop("Input BED file stream close failed!");
  free( buffer_in );
  if ( n_buf_read != 0 ) {
    // now send error message to R
    stop("Input BED file continued after all requested rows were read!  Either the specified the number of loci was too low or the input file is corrupt!");
  }

  //////////////////
  // CLOSE OUTPUT //
  //////////////////

  if ( fclose( file_out_stream ) != 0 )
    stop("Output BED file stream close failed!");

  // done with buffer
  free( buffer_out );
}
