#include <iostream>
#include <fstream>
#include <vector>
#include <Rcpp.h>
#include "constants.h"
using namespace Rcpp;

// [[Rcpp::export]]
IntegerMatrix read_bed_cpp(const char* file, size_t m_loci, size_t n_ind) {
  // - file assumed to be full path (no missing extensions)
  // unfortunately BED format requires dimensions to be known
  // (so outside this function, the BIM and FAM files must be parsed first)

  // open input file in "binary" mode
  std::ifstream file_in_stream( file, std::ios::binary );
  if ( !file_in_stream.is_open() )
    stop( "Could not open BED file `%s` for reading!", file );
  
  // number of columns (bytes) in input (for buffer), after byte compression
  // size set for full row, but overloaded used first for this header comparison
  // chose size_t to have it match n_buf_read value returned by fread
  size_t n_buf = ( n_ind + 3 ) / 4;
  // initialize row buffer
  // NOTE: if n_buf is less than 3, as it does in a toy unit test, insist on at least 3!
  std::vector<char> buffer_in( n_buf > 3 ? n_buf : 3 );

  /////////////////////////
  // check magic numbers //
  /////////////////////////

  // read header bytes (magic numbers)
  if ( ! file_in_stream.read( buffer_in.data(), 3 ) )
    stop("Input BED file did not have a complete header (3-byte magic numbers)!");
  
  // require that they match our only supported specification of locus-major order and latest format
  size_t pos;
  for (pos = 0; pos < 3; pos++) {
    if ( plink_bed_byte_header[pos] != buffer_in[pos] )
      stop("Input BED file is not in supported format.  Either magic numbers do not match, or requested sample-major format is not supported.  Only latest locus-major format is supported!");
  }

  ////////////////////
  // read genotypes //
  ////////////////////

  // initialize our genotype matrix
  IntegerMatrix X(m_loci, n_ind);
  
  // navigate data and process
  size_t i, j, k;
  unsigned char buf_k; // working of buffer at k'th position
  unsigned char xij; // copy of extracted genotype
  for (i = 0; i < m_loci; i++) {
    // read whole row into buffer
    if ( ! file_in_stream.read( buffer_in.data(), n_buf ) )
      stop( "Truncated file: row %d terminated at %u bytes, expected %u.", i+1, file_in_stream.gcount(), n_buf); // convert to 1-based coordinates
    
    // process buffer now!
    // always reset these at start of row
    j = 0; // individuals

    // navigate buffer positions k (not individuals j)
    for (k = 0; k < n_buf; k++) {
      
      // copy down this value, which will be getting edited
      buf_k = buffer_in[k];
      
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
	}
      }
      // finished byte
      
    }
    // finished row
    
  }
  // finished matrix!

  // let's check that file was indeed done
  // apparently we just have to try to read more, and test that it didn't
  if ( file_in_stream.read( buffer_in.data(), 1 ) )
    stop("Input BED file continued unexpectedly!  Either the specified dimensions are incorrect or the input file is corrupt!");
  file_in_stream.close();
  
  // return genotype matrix
  return X;
}
