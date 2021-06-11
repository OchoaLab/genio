## Test environments
* local R:             x86_64-redhat-linux-gnu R 4.0.5 (2021-03-31)
* local R-devel:       x86_64-pc-linux-gnu     R Under development (unstable) (2021-06-10 r80479)
* rhub (ubuntu):       x86_64-pc-linux-gnu     R 4.1.0 (2021-05-18)
* rhub (fedora):       x86_64-pc-linux-gnu     R Under development (unstable) (2021-06-09 r80471)
* rhub (debian):       x86_64-pc-linux-gnu     R Under development (unstable) (2020-07-31 r78945)
* rhub (windows):      x86_64-w64-mingw32      R Under development (unstable)
* win-builder devel:   x86_64-w64-mingw32      R Under development (unstable) (2021-06-07 r80458)
* win-builder release: x86_64-w64-mingw32      R 4.1.0 (2021-05-18)

## R CMD check results
I encountered two variants of the same ERROR on some RHub R-devel environments only, a false positive due to Bioconductor not installing on R-devel.  `snpStats` is a Bioconductor package.  I encountered no errors on WinBuilder R-devel and on my local R-devel with `snpStats` installed from github.

- Error: Bioconductor does not yet build and check packages for R version 4.2; see https://bioconductor.org/install
- ERROR: Package suggested but not available: ‘snpStats’

There were no WARNINGs.

There was one NOTE, also a false positive:

- NOTE: Possibly mis-spelled words in DESCRIPTION:
  Eigenstrat (10:393)
  GCTA (10:136)
  GRM (10:148)
  Plink (10:114, 10:383)
  - These are not misspelled.

## Downstream dependencies
There are currently no downstream dependencies for this package.
