// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

#ifdef RCPP_USE_GLOBAL_ROSTREAM
Rcpp::Rostream<true>&  Rcpp::Rcout = Rcpp::Rcpp_cout_get();
Rcpp::Rostream<false>& Rcpp::Rcerr = Rcpp::Rcpp_cerr_get();
#endif

// count_lines_cpp
size_t count_lines_cpp(const char* filepath);
RcppExport SEXP _genio_count_lines_cpp(SEXP filepathSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const char* >::type filepath(filepathSEXP);
    rcpp_result_gen = Rcpp::wrap(count_lines_cpp(filepath));
    return rcpp_result_gen;
END_RCPP
}
// het_reencode_bed_cpp
void het_reencode_bed_cpp(const char* file_in, const char* file_out, int m_loci, int n_ind);
RcppExport SEXP _genio_het_reencode_bed_cpp(SEXP file_inSEXP, SEXP file_outSEXP, SEXP m_lociSEXP, SEXP n_indSEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const char* >::type file_in(file_inSEXP);
    Rcpp::traits::input_parameter< const char* >::type file_out(file_outSEXP);
    Rcpp::traits::input_parameter< int >::type m_loci(m_lociSEXP);
    Rcpp::traits::input_parameter< int >::type n_ind(n_indSEXP);
    het_reencode_bed_cpp(file_in, file_out, m_loci, n_ind);
    return R_NilValue;
END_RCPP
}
// read_bed_cpp
IntegerMatrix read_bed_cpp(const char* file, int m_loci, int n_ind);
RcppExport SEXP _genio_read_bed_cpp(SEXP fileSEXP, SEXP m_lociSEXP, SEXP n_indSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const char* >::type file(fileSEXP);
    Rcpp::traits::input_parameter< int >::type m_loci(m_lociSEXP);
    Rcpp::traits::input_parameter< int >::type n_ind(n_indSEXP);
    rcpp_result_gen = Rcpp::wrap(read_bed_cpp(file, m_loci, n_ind));
    return rcpp_result_gen;
END_RCPP
}
// write_bed_cpp
void write_bed_cpp(const char* file, IntegerMatrix X, bool append);
RcppExport SEXP _genio_write_bed_cpp(SEXP fileSEXP, SEXP XSEXP, SEXP appendSEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const char* >::type file(fileSEXP);
    Rcpp::traits::input_parameter< IntegerMatrix >::type X(XSEXP);
    Rcpp::traits::input_parameter< bool >::type append(appendSEXP);
    write_bed_cpp(file, X, append);
    return R_NilValue;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_genio_count_lines_cpp", (DL_FUNC) &_genio_count_lines_cpp, 1},
    {"_genio_het_reencode_bed_cpp", (DL_FUNC) &_genio_het_reencode_bed_cpp, 4},
    {"_genio_read_bed_cpp", (DL_FUNC) &_genio_read_bed_cpp, 3},
    {"_genio_write_bed_cpp", (DL_FUNC) &_genio_write_bed_cpp, 3},
    {NULL, NULL, 0}
};

RcppExport void R_init_genio(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
