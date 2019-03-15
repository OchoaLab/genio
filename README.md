# genio

The `genio` (GENetics I/O) package provides easy and efficient table parsers for formats from statistical genetics research.
Currently targets plink and eigenstrat formats (more to come).
Consists of wrappers for `readr` functions that, depending on the target format, add missing extensions and add column names (often absent in these files).

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

Reading these tables is simple:

``` r
library(genio)

# read data into "tibbles"

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
```

