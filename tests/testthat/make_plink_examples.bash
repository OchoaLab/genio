# set path of executable to make examples
plink2=$HOME'/bin/plink2'

# create random data
# choose odd dimensions to test edge cases in my code
n=33 # n %% 4 != 0 are good tests
m=101
miss=0.1 # missingness proportion, we need to make sure these cases are handled too!
# make bed/bim/fam
$plink2 --dummy $n $m $miss --make-bed --out dummy-$n-$m-$miss
# remove log when things are ok
rm dummy-$n-$m-$miss.log

# tiny case with n %% 4 == 0 example (to be extra sure that case is well handled
n=4
m=10
# make bed/bim/fam
$plink2 --dummy $n $m $miss --make-bed --out dummy-$n-$m-$miss
# remove log when things are ok
rm dummy-$n-$m-$miss.log
