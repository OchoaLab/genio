# have plink1, plink2, gcta on path

# create random data

# choose odd dimensions to test edge cases in my code
n=33 # n %% 4 != 0 are good tests
m=101
miss=0.1 # missingness proportion, we need to make sure these cases are handled too!
# make bed/bim/fam
plink2 --dummy $n $m $miss --make-bed --out dummy-$n-$m-$miss
# remove log when things are ok
rm dummy-$n-$m-$miss.log

# tiny examples to be extra sure every n %% 4 case is well handled
m=10
for n in {4..7}; do
    # make bed/bim/fam
    plink2 --dummy $n $m $miss --make-bed --out dummy-$n-$m-$miss
    # remove log when things are ok
    rm dummy-$n-$m-$miss.log
done

# for making sure text version of alleles in my converter function agrees with plink
# NOTE: plink2 doesn't support this format yet/anymore, must use plink1!
# makes *.ped and *.map
plink1 --bfile dummy-4-10-0.1 --recode --out dummy-4-10-0.1
rm dummy-4-10-0.1.log

# create GRM for tests
gcta --bfile dummy-7-10-0.1 --make-grm --out dummy-7-10-0.1
# cleanup
rm dummy-7-10-0.1.log

# random 10x10 to go with "extdata" sample
n=10
m=10
plink2 --dummy $n $m $miss --make-bed --out sample
# move only BED file
mv sample.bed ../../inst/extdata/
# remove rest
rm sample.{bim,fam,log}

# create GRM for sample
cd ../../inst/extdata/
# actually create GRM files
gcta --bfile sample --make-grm --out sample
# cleanup
rm sample.log
# make PCs using GCTA
gcta --grm sample --pca 3 --out sample-gcta
# cleanup
rm sample-gcta.log

# make PCs using plink2 (diff example with header; GCTA's has no header)
#plink2 --bfile sample --pca 3 --out sample-plink2
# stupid thing complains about small sample size, this is a workaround
plink2 --bfile sample --freq --out sample-plink2
plink2 --bfile sample --read-freq sample-plink2.afreq --pca 3 --out sample-plink2
# cleanup
rm sample-plink2.{afreq,log}

# KING-robust examples calculated with plink2 (various formats)
plink2 --bfile sample --make-king square --out sample-king-sq
# turns out bin/bin4 default to square
plink2 --bfile sample --make-king bin --out sample-king-sq-bin
plink2 --bfile sample --make-king bin4 --out sample-king-sq-bin4
# triangles, presumably the most compact!
plink2 --bfile sample --make-king triangle bin --out sample-king-tr-bin
plink2 --bfile sample --make-king triangle bin4 --out sample-king-tr-bin4
# cleanup
rm sample-king-{sq,sq-bin,sq-bin4,tr-bin,tr-bin4}.log
