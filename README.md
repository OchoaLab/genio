# genio

The `genio` (GENetics I/O) package provides easy-to-use and efficient writers and parsers for formats from statistical genetics research.
Currently targets plink and eigenstrat formats (more to come).
Lightning fast `write_bed` (written in Rcpp) writes genotypes (in native R matrices) into plink BED format.
`make_*` functions create default FAM and BIM files to go with simulated genotype data.
Otherwise, the package consists of wrappers for `readr` functions that add missing extensions and column names (often absent in these files).

## Installation

<!--
You can install the released version of genio from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("genio")
```
-->

Install the latest development version from GitHub:
``` r
install.packages("devtools") # if needed
library(devtools)
devtools::install_github("OchoaLab/genio", build_opts=c())
```

## Example

Load library:

``` r
library(genio)
```

### Make a BED/BIM/FAM file set for simulated data

``` r
# write your genotype matrix stored in an R native matrix

# (here we create a small example with random data)
# create 10 random genotypes
X <- rbinom(10, 2, 0.5)
# replace 3 random genotypes with missing values
X[sample(10, 3)] <- NA
# turn into 5x2 matrix
X <- matrix(X, nrow=5, ncol=2)

# create default tables to go with simulated genotype data
fam <- make_fam(n = 2)
bim <- make_bim(n = 5)

# write simulated data to BED/BIM/FAM (one command each)
# extension can be omitted and it still works!
write_bed('random', X)
write_fam('random', fam)
write_bim('random', bim)
```

### Reading and writing existing data

``` r
# read individual and locus data into "tibbles"

# plink formats
fam <- read_fam('sample.fam')
bim <- read_bim('sample.bim')

# eigenstrat formats
ind <- read_ind('sample.ind')
snp <- read_snp('sample.snp')

# in all cases extension can be omitted and it still works!
fam <- read_fam('sample')
bim <- read_bim('sample')
ind <- read_ind('sample')
snp <- read_snp('sample')

# write these data to other files
# here extensions are also added automatically
write_fam('new', fam)
write_bim('new', bim)
write_ind('new', ind)
write_snp('new', snp)

```

NOTE:
To read BED files I recommend the `BEDMatrix` package, which offers low-memory functionality I do not aim to reproduce in this package.
