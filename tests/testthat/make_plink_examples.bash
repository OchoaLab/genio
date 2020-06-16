# set path of executable to make examples
plink2=$HOME'/bin/plink2'
gcta=$HOME'/bin/gcta_1.93.2beta/gcta64'

# create random data

# choose odd dimensions to test edge cases in my code
n=33 # n %% 4 != 0 are good tests
m=101
miss=0.1 # missingness proportion, we need to make sure these cases are handled too!
# make bed/bim/fam
$plink2 --dummy $n $m $miss --make-bed --out dummy-$n-$m-$miss
# remove log when things are ok
rm dummy-$n-$m-$miss.log

# tiny examples to be extra sure every n %% 4 case is well handled
m=10
for n in {4..7}; do
    # make bed/bim/fam
    $plink2 --dummy $n $m $miss --make-bed --out dummy-$n-$m-$miss
    # remove log when things are ok
    rm dummy-$n-$m-$miss.log
done

# create GRM for tests
$gcta --bfile dummy-7-10-0.1 --make-grm --out dummy-7-10-0.1
# cleanup
rm dummy-7-10-0.1.log

# random 10x10 to go with "extdata" sample
n=10
m=10
$plink2 --dummy $n $m $miss --make-bed --out sample
# move only BED file
mv sample.bed ../../inst/extdata/
# remove rest
rm sample.{bim,fam,log}

# create GRM for sample
cd ../../inst/extdata/
# actually create GRM files
$gcta --bfile sample --make-grm --out sample
# cleanup
rm sample.log
