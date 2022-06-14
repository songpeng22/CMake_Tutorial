#!/bin/bash
# clean
rm -rf build
mkdir -p build

# build
pushd build
cmake ../src
make
popd
