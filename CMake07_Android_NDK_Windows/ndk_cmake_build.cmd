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
REM NDK 21e work with cmake 3.17
set "NDK_PATH=C:\Android_NDK\android-ndk-r21e"
REM NDK 23b will ask you to install cmake 3.19
REM set "NDK_PATH=C:\Android_NDK\android-ndk-r23b"
echo "NDK_PATH is %NDK_PATH%"

REM # tool chain
set TOOL_CHAIN_FILE="%NDK_PATH%\build\cmake\android.toolchain.cmake"
echo "TOOL_CHAIN_FILE is %TOOL_CHAIN_FILE%"

REM # make
set MAKE_PATH="%FILE_DIR%\tool\ninja\ninja.exe"
echo "MAKE_PATH is %MAKE_PATH%"

REM # clean
rm -r build_ndk_on_windows
mkdir build_ndk_on_windows

REM # build
pushd build_ndk_on_windows
cmake -G "Ninja" ../src -DANDROID_NDK="%NDK_PATH%" -DCMAKE_TOOLCHAIN_FILE=%TOOL_CHAIN_FILE% -DANDROID_PLATFORM=android-24  -DCMAKE_BUILD_TYPE=Release  -DANDROID_ABI="arm64-v8a" -DCMAKE_MAKE_PROGRAM=%MAKE_PATH%
cmake --build .
popd
