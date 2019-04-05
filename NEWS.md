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
