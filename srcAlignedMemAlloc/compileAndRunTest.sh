#!/bin/bash




progDir="src"
prog="mem_shell"
testFile="test"
outputTestFile="output"
testFileList=`ls $testFile/*.in`


cd $progDir
make clean
make
cd ../

cd $outputTestFile/test
rm -f *
cd ../../



for file in $testFileList
do
	./$progDir/$prog < $file > $outputTestFile/$file
done


echo "Différence between the expected and created output: alloc1:"
diff output/test/alloc1.in test/alloc1.out.expected
echo ""
echo ""
echo ""
echo ""

echo "Différence between the expected and created output: alloc2:"
diff output/test/alloc2.in test/alloc2.out.expected
echo ""
echo ""
echo ""
echo ""

echo "Différence between the expected and created output: alloc3:"
diff output/test/alloc3.in test/alloc3.out.expected
echo ""
echo ""
echo ""
echo ""

echo "Différence between the expected and created output: alloc4:"
diff output/test/alloc4.in test/alloc4.out.expected
echo ""
echo ""
echo ""
echo ""

echo "Différence between the expected and created output: alloc5:"
diff output/test/alloc5.in test/alloc5.out.expected
echo ""
echo ""
echo ""
echo ""

