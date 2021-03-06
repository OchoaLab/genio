% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/write_snp.R
\name{write_snp}
\alias{write_snp}
\title{Write Eigenstrat *.snp files}
\usage{
write_snp(file, tib, verbose = TRUE)
}
\arguments{
\item{file}{Output file (whatever is accepted by \code{\link[readr:write_delim]{readr::write_tsv()}}).
If file is missing the expected *.snp extension, the function adds it.}

\item{tib}{The tibble or data.frame to write.
It must contain these columns: \code{id}, \code{chr}, \code{posg}, \code{pos}, \code{ref}, \code{alt}.
Throws an error if any of these columns are missing.
Additional columns are ignored.
Columns are automatically reordered in output as expected in format.}

\item{verbose}{If \code{TRUE} (default), function reports the path of the file being written (after autocompleting the extension).}
}
\value{
The output \code{tib} invisibly (what \code{\link[readr:write_delim]{readr::write_tsv()}} returns).
}
\description{
This function writes a tibble with the right columns into a standard Eigenstrat *.snp file.
It uses \code{\link[readr:write_delim]{readr::write_tsv()}} to do it efficiently.
}
\examples{
# to write an existing table `snp` into file "data.snp", run like this:
# write_snp("data", snp)
# this also works
# write_snp("data.snp", snp)

# The following example is more detailed but also more awkward
# because (only for these examples) the package must create the file in a *temporary* location

# create a dummy tibble with the right columns
library(tibble)
tib <- tibble(
    id = 1:3,
    chr = 1:3,
    posg = 0,
    pos = 1:3,
    ref = 'A',
    alt = 'B'
)
# a dummy file
file_out <- tempfile('delete-me-example', fileext = '.snp') # will also work without extension
# write the table out in *.snp format (no header, columns in right order)
write_snp(file_out, tib)
# delete output when done
file.remove(file_out)

}
\seealso{
Eigenstrat SNP format reference:
\url{https://github.com/DReichLab/EIG/tree/master/CONVERTF}
}
