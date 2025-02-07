#include <iostream>
#include <fstream>
#include <vector>
#include <Rcpp.h>
#include "constants.h"
using namespace Rcpp;

// [[Rcpp::export]]
void het_reencode_bed_cpp(const char* file_in, const char* file_out, size_t m_loci, size_t n_ind) {
  // - files assumed to be full path (no missing extensions)
  // unfortunately BED format requires dimensions to be known
  // (so outside this function, the BIM and FAM files must be parsed first)

  ////////////////
  // OPEN INPUT //
  ////////////////

  // open input file in "binary" mode
  std::ifstream file_in_stream( file_in, std::ios::binary );
  if ( !file_in_stream.is_open() )
    stop( "Could not open BED file `%s` for reading!", file_in );

  /////////////////////////////////////
  // OPEN INPUT: check magic numbers //
  /////////////////////////////////////

  // number of columns (bytes) in input (for buffer), after byte compression
  // size set for full row, but overloaded used first for this header comparison
  // chose size_t to have it match n_buf_read value returned by fread
  size_t n_buf = ( n_ind + 3 ) / 4;
  // initialize row buffer
  // NOTE: if n_buf is less than 3, as it does in a toy unit test, insist on at least 3 for input, because that's how big the header is!
  std::vector<char> buffer_in( n_buf > 3 ? n_buf : 3 );
  std::vector<char> buffer_out( n_buf );

  // read header bytes (magic numbers)
  if ( ! file_in_stream.read( buffer_in.data(), 3 ) )
    stop("Input BED file did not have a complete header (3-byte magic numbers)!");
  
  // require that they match our only supported specification of locus-major order and latest format
  size_t pos;
  for (pos = 0; pos < 3; pos++) {
    if ( plink_bed_byte_header[pos] != buffer_in[pos] )
      stop("Input BED file is not in supported format.  Either magic numbers do not match, or requested sample-major format is not supported.  Only latest locus-major format is supported!");
  }

  /////////////////
  // OPEN OUTPUT //
  /////////////////

  // open output file
  std::ofstream file_out_stream( file_out, std::ios::binary );
  if ( !file_out_stream.is_open() )
    stop( "Could not open BED file `%s` for writing!", file_out );
  
  // write header
  // assume standard locus-major order and latest format
  file_out_stream.write( (char *)plink_bed_byte_header, 3 );

  //////////////////////////////
  // read and write genotypes //
  //////////////////////////////
  
  // navigate data and process
  size_t i, j, k, rem;
  unsigned char buf_in_k; // working of buffer at k'th position
  unsigned char xij; // copy of extracted genotype
  for (i = 0; i < m_loci; i++) {
    
    // read whole row into buffer
    if ( ! file_in_stream.read( buffer_in.data(), n_buf ) )
      stop( "Truncated file: row %d terminated at %u bytes, expected %u.", i+1, file_in_stream.gcount(), n_buf); // convert to 1-based coordinates
    
    // zero out output buffer for new row
    std::fill( buffer_out.begin(), buffer_out.end(), 0 );

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
    file_out_stream.write( buffer_out.data(), n_buf );
  }
  // finished matrix/file!

  /////////////////
  // CLOSE FILES //
  /////////////////

  // let's check that file was indeed done
  // apparently we just have to try to read more, and test that it didn't
  if ( file_in_stream.read( buffer_in.data(), 1 ) )
    stop("Input BED file continued unexpectedly!  Either the specified dimensions are incorrect or the input file is corrupt!");
  file_in_stream.close();
  
  file_out_stream.close();
}
