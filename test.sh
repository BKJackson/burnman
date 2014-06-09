#!/bin/bash

function testit {
t=$1
#echo "*** testing $t ..."
(python <<EOF
import matplotlib as m
m.use('Cairo')
VERBOSE=1
RUNNING_TESTS=1
execfile('$t')
EOF
)  >$t.tmp 2>&1 || { echo "test $t failed!!!!!!!!"; cat $t.tmp; } #exit 1; } 
#echo "diff $t.tmp misc/ref/$t.out"
(diff $t.tmp ../misc/ref/$t.out && rm $t.tmp) || { echo "diff failed!!!!!"; echo "Check `readlink -f $t.tmp` `readlink -f ../misc/ref/$t.out`"; } #exit 1; } 
}




echo "*** running test suite..."
cd tests
python tests.py || exit 1
testit "benchmark.py"
cd ..

python burnman/partitioning.py || exit 1

cd misc
echo "gen_doc..."
python gen_doc.py >/dev/null || exit 1
cd ..




echo "checking examples/ ..."
cd examples
for test in `ls example*.py`
do
    [ $test == "example_inv_murakami.py" ] && echo "*** skipping $test !" && continue
    [ $test == "example_premite_isothermal.py" ] && echo "*** skipping $test !" && continue

    testit $test
done
cd ..

echo "   done"


echo "checking misc/ ..."
cd misc
for test in `ls paper*.py`
do
    [ $test == "paper_opt_pv_old.py" ] && echo "*** skipping $test !" && continue

    testit $test
done
cd ..

echo "   done"



echo ""
echo "*** tests done"
