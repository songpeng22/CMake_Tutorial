#!/bin/bash
# CMake build
mkdir -p build
pushd build
cmake ../src 
make #or make VERBOSE=1
popd
#rm -rf build

# Makefile build
#pushd src
#make
#popd
#mv src/main . -v
#pwd
