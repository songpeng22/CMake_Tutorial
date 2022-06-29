@echo off
REM # ndk cmake build on windows

REM # viariables
setlocal
REM ~dpnx0 will give the same as ~f0, but this shows you that you can break it down into parts: d=drive p=path n=name x=extension
set FILE_PATH="%~dpnx0"
set FILE_DIR="%~dp0"
set FILE_DIR=%cd%
echo FILE_PATH is %FILE_PATH%
echo FILE_DIR is %FILE_DIR%

REM # NDK
REM QT5.12.4 work with ndk 19c
set "NDK_PATH=C:\Android_NDK\android-ndk-r19c"
REM NDK 21e work with cmake 3.17
REM set "NDK_PATH=C:\Android_NDK\android-ndk-r21e"
REM NDK 23b will ask you to install cmake 3.19
REM set "NDK_PATH=C:\Android_NDK\android-ndk-r23b"
echo "NDK_PATH is %NDK_PATH%"

REM # tool chain
set TOOL_CHAIN_FILE="%NDK_PATH%\build\cmake\android.toolchain.cmake"
echo "TOOL_CHAIN_FILE is %TOOL_CHAIN_FILE%"

REM # make
set MAKE_PATH="C:\Qt\Qt5.12.4\Tools\mingw730_32\bin\mingw32-make.exe"
echo "MAKE_PATH is %MAKE_PATH%"

REM # clean
rm -r build_mingw_ndk_on_windows
mkdir build_mingw_ndk_on_windows

pushd build_mingw_ndk_on_windows
REM # generate makefile
REM # option 1, predefine.cmake must be include before PROJECT() section
cmake -G "MinGW Makefiles" .. 
REM # option 2
REM cmake -G "MinGW Makefiles" ../src -DANDROID_NDK="%NDK_PATH%" -DCMAKE_TOOLCHAIN_FILE=%TOOL_CHAIN_FILE% -DANDROID_ABI="arm64-v8a" -DANDROID_STL="none" -DCMAKE_MAKE_PROGRAM=%MAKE_PATH%

REM # build
cmake --build . --verbose
popd
