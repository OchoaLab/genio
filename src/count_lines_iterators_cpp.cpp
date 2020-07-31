#include <Rcpp.h>
#include <string>
#include <iostream>
#include <fstream>
#include <algorithm>

// [[Rcpp::export]]
size_t count_lines_iterators_cpp(const char* filepath) {
  // file must be full path (no missing extensions)

  // create input filestream
  std::ifstream file( filepath );

  // NOTE: file is verified to exist already (was checked in R)

  // count with iterators!
  size_t num_lines = std::count(
				std::istreambuf_iterator<char>(file),
				std::istreambuf_iterator<char>(),
				'\n'
				);
  // increment count once more if file didn't end with newline
  file.unget();
  if ( file.get() != '\n' )
    num_lines++;
  
  return num_lines;
}
