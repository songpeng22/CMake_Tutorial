cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

# ENV
# check the JAVA_HOME environment variable
SET(JAVA_HOME $ENV{JAVA_HOME})
IF(NOT JAVA_HOME)
    MESSAGE(FATAL_ERROR "The JAVA_HOME environment variable is not set. Please set it to the root directory of the JDK.")
ELSE()
    MESSAGE(STATUS "JAVA_HOME: " ${JAVA_HOME})
ENDIF()

SET(QT_ANDROID_QT_ROOT C:/Qt/Qt5.12.4/5.12.4/android_arm64_v8a/ )
SET(QT_ANDROID_NDK_ROOT C:/Android_NDK/android-ndk-r19c )
SET(QT_ANDROID_SDK_ROOT C:/Android_SDK_CommandLine )

MESSAGE(STATUS "QT_HOME: " ${QT_ANDROID_QT_ROOT})
MESSAGE(STATUS "NDK_HOME: " ${QT_ANDROID_NDK_ROOT})
MESSAGE(STATUS "SDK_HOME: " ${QT_ANDROID_SDK_ROOT})

set(CMAKE_SYSTEM_NAME Android)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

SET(CMAKE_ANDROID_NDK ${QT_ANDROID_NDK_ROOT})
SET(ANDROID_NDK ${QT_ANDROID_NDK_ROOT})
SET(CMAKE_ANDROID_STANDALONE_TOOLCHAIN C:/Android_NDK/android-ndk-r19c )
SET(CMAKE_SYSTEM_VERSION 21)
SET(ANDROID_PLATFORM 21)
SET(ANDROID_API 21)
SET(CMAKE_ANDROID_ARCH_ABI arm64-v8a)
SET(ANDROID_ABI arm64-v8a)
#set ANDROID_STL in cmd file
#SET(ANDROID_STL none)
#set(ANDROID_STL_PREFIX llvm-libc++)
#set(QT_ANDROID_STL_PATH "${QT_ANDROID_NDK_ROOT}/sources/cxx-stl/${ANDROID_STL_PREFIX}/libs/${ANDROID_ABI}/lib${ANDROID_STL}.so")
#SET(CMAKE_ANDROID_NDK_TOOLCHAIN_VERSION clang)
SET(CMAKE_TOOLCHAIN_FILE ${QT_ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake)
#set(tool_chain /opt/android-ndk/ndk/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64)
#set( CMAKE_SYSROOT C:/Android_NDK/android-ndk-r19c/sysroot )
SET(CMAKE_BUILD_RPATH C:/Android_NDK/android-ndk-r19c/platforms/android-21/arch-arm64/usr/lib/)
SET(CMAKE_INSTALL_RPATH C:/Android_NDK/android-ndk-r19c/toolchains/llvm/prebuilt/windows/sysroot/usr/lib/aarch64-linux-android/21)
SET(CMAKE_BUILD_TYPE Debug)
add_compile_options(-Wall)

MESSAGE(STATUS "ANDROID_NDK: " ${ANDROID_NDK})




SET(CMAKE_MAKE_PROGRAM C:/Qt/Qt5.12.4/Tools/mingw730_32/bin/mingw32-make.exe)
#SET(CMAKE_MAKE_PROGRAM C:/Ninja/ninja.exe)

#MESSAGE(STATUS "CMAKE_TOOLCHAIN_FILE: " ${CMAKE_TOOLCHAIN_FILE})
#MESSAGE(STATUS "CMAKE_MAKE_PROGRAM: " ${CMAKE_MAKE_PROGRAM})

# make sure that the Android toolchain is used
IF(NOT ANDROID)
    MESSAGE(STATUS "ANDROID: " ${ANDROID})
ELSE()
    MESSAGE(STATUS "ANDROID: " ${ANDROID})
ENDIF()



