#include <Rcpp.h>
#include <string>
#include <iostream>
#include <fstream>

// [[Rcpp::export]]
size_t count_lines_cpp(const char* filepath) {
  // file must be full path (no missing extensions)

  // desired number of lines
  size_t num_lines = 0;

  // current line (throwaway)
  std::string line;

  // create input filestream
  std::ifstream file( filepath );

  // NOTE: file is verified to exist already (was checked in R)

  // start counting
  while( std::getline( file, line ) )
    num_lines++;

  return num_lines;
}
