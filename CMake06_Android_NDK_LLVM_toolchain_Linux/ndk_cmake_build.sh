#!/bin/bash
FILE_PATH=`realpath $0`
FILE_DIR=`dirname $FILE_PATH`
echo "FILE_PATH=$FILE_PATH"
echo "FILE_DIR=$FILE_DIR"

# clean
rm -rf build_ndk
mkdir -p build_ndk

# build
pushd build_ndk
cmake ../src -DCMAKE_TOOLCHAIN_FILE=$FILE_DIR/src/android_ndk_18.cmake
make
popd
