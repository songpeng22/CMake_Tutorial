#!/bin/bash
# clean
rm -rf build
mkdir -p build

#x86 )
#export CFLAGS=-m32
#export CXXFLAGS=-m32

#x64 | x86-64 | AMD64 | m64 )
#export CFLAGS=-m64
#export CXXFLAGS=-m64

#armhf )
#export CC=`ls /usr/bin/arm-linux-gnueabihf-gcc-[0-9]* | head -1`
#export CXX=`ls /usr/bin/arm-linux-gnueabihf-g++-[0-9]* | head -1`
#export HOST_CC=`ls /usr/bin/gcc-[0-9]* | head -1`
#export HOST_CXX=`ls /usr/bin/g++-[0-9]* | head -1`
#export PKG_CONFIG=/usr/bin/arm-linux-gnueabihf-pkg-config
#export OBJCOPY=/usr/bin/arm-linux-gnueabihf-objcopy

#arm64 )
#export CC=`ls /usr/bin/aarch64-linux-gnu-gcc-[0-9]* | head -1`
#export CXX=`ls /usr/bin/aarch64-linux-gnu-g++-[0-9]* | head -1`
#export HOST_CC=`ls /usr/bin/gcc-[0-9]* | head -1`
#export HOST_CXX=`ls /usr/bin/g++-[0-9]* | head -1`
#export PKG_CONFIG=/usr/bin/aarch64-linux-gnu-pkg-config
#export OBJCOPY=/usr/bin/aarch64-linux-gnu-objcopy

# build
cmake -H. -Bbuild
cmake --build build

# clean
rm -rf build
