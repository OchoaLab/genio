# 2019-03-15 - genio 1.0.0.9000

* First GitHub release!  Includes `read_bim`, `read_fam`, `read_ind`, and `read_snp` functions.

# 2019-03-31 - genio 1.0.1.9000

* Added an efficient `write_bed` written in Rcpp and thoroughly tested against `BEDMatrix` package.

# 2019-04-01 - genio 1.0.2.9000

* Improved `write_bed` error message for invalid data, documentation.
* Extended `write_bed` tests.

# 2019-04-01 - genio 1.0.3.9000

* Added `write_fam`, `write_bim`, `write_ind`, `write_snp` functions.
* Refactored `read_*` code, updated docs and tests.

# 2019-04-02 - genio 1.0.4.9000

* Added `make_fam`, `make_bim`, and `write_plink` functions.
* Fixed `read_fam` bug (used to require phenotypes to be integers, now can be double numbers).
* Added `verbose` option to `write_bed`.

# 2019-04-05 - genio 1.0.5.9000

* `write_plink` now returns `NULL` **invisibly**.
* Added `require_files_plink`, `delete_files_plink`.
* Removed "Fatal: " prefix from stop messages.

# 2019-04-08 - genio 1.0.6.9000

* Added `ind_to_fam`, `sex_to_int`, `sex_to_char`.
* 2019-05-13: added ORCID to author info

# 2019-05-16 - genio 1.0.7.9000

* Added `read_bed` and `read_plink`!
  Now all plink reading and writing operations are supported.
* Added package documentation summarizing main read and write functions.
* Added vignette comparing our BED reader and writer to those of `BEDMatrix`, `snpStats`, and `lfa`.

# 2019-05-21 - genio 1.0.8

* First CRAN submission
* Genotype matrix row and column names from BIM/FAM files
  * `read_plink` now includes row and column names automatically.
  * `read_bed` accepts either row and column names or just their numbers.
  * `write_plink` checks these row and column names against the BIM and FAM tables for consistency, if these are all present.
* Added memory estimation and comparisons sections to vignette.
* Windows debugging
  * Now BED writing is in binary mode, like reading already was.
  * Reduced comparisons to `BEDMatrix` in testing, since it leaves temporary files open and on Windows they do not get deleted and leave confusing error messages behind.

# 2019-05-24 - genio 1.0.9

* CRAN-requested edits, resubmission
  * DESCRIPTION edits
  * Changed examples, vignettes, and tests to write files to the default temporary directory.

# 2019-05-28 - genio 1.0.10

* CRAN submission follow ups, fixing issues that arose on other systems:
  * Added `include <cerrno>` to my cpp code.
  * Fixed a "heap buffer overflow" detected by valgrind that only occurred for data with fewer than 9 individuals (included many of my toy tests).
  * Edited a test within vignette to allow for small machine precision-level errors.

# 2019-07-22 - genio 1.0.11

* Added `read_phen` and `write_phen`, a phenotype format (very similar to plink's FAM) used by GCTA and EMMAX.
* Now `write_plink` returns the data it wrote, invisibly as a list.
  Most useful for auto-generated data.

# 2019-08-05 - genio 1.0.11.9000

* Fixed a "buffer overflow" bug that occurred when input files started with "~/" on Unix systems.

# 2019-12-17 - genio 1.0.12

* Second CRAN submission
* Moved logo to `man/figures/`
* Minor Roxygen-related updates.
