#' genio (GENetics I/O): A package for reading and writing genetics data
#'
#' This package fully supports reading and writing Plink BED/BIM/FAM and GCTA GRM files, as illustrated below.
#' These functions make it easy to create dummy annotation tables to go with simulated genotype data too.
#' Lastly, there is functionality to read and write Eigenstrat tables.
#' 
#' @examples
#' # read existing BED/BIM/FAM files
#' 
#' # first get path to BED file
#' file <- system.file( "extdata", 'sample.bed', package = "genio", mustWork = TRUE )
#'
#' # read genotypes and annotation tables
#' plink_data <- read_plink( file )
#' # genotypes
#' X <- plink_data$X
#' # locus annotations
#' bim <- plink_data$bim
#' # individual annotations
#' fam <- plink_data$fam
#' 
#' # the same works without .bed extension
#' file <- sub( '\\.bed$', '', file ) # remove extension
#' plink_data <- read_plink( file )
#'
#' # write data into new BED/BIM/FAM files
#' file_out <- tempfile( 'delete-me-example' )
#' write_plink( file_out, X, bim, fam )
#'
#' # delete example files when done
#' delete_files_plink( file_out )
#'
#' # read sample GRM files
#' file <- system.file( "extdata", 'sample.grm.bin', package = "genio", mustWork = TRUE )
#' file <- sub( '\\.grm\\.bin$', '', file ) # remove extension from this path on purpose
#' obj <- read_grm( file )
#' # the kinship matrix
#' kinship <- obj$kinship
#' # the pair sample sizes matrix
#' M <- obj$M
#' # the fam and ID tibble
#' fam <- obj$fam
#'
#' # write data into new GRM files
#' write_grm( file_out, kinship, M = M, fam = fam )
#'
#' # delete example files when done
#' delete_files_grm( file_out )
#'
#' # other functions not shown here allow reading and writing individual files,
#' # creating dummy tables to go with simulated genotypes,
#' # requiring the existence of these files,
#' # and reading and writing of Eigenstrat tables too.
#'
#' @docType package
#' @name genio
"_PACKAGE"
