#!/bin/bash
rm -r ./build
mkdir -p build
pushd build
cmake -DCMAKE_PREFIX_PATH=/home/peng/qt/5.12.4/gcc_64 ../src
popd

