# Path define
SET(JAVA_HOME $ENV{JAVA_HOME})
IF(NOT JAVA_HOME)
    MESSAGE(FATAL_ERROR "The JAVA_HOME environment variable is not set. Please set it to the root directory of the JDK.")
ELSE()
    MESSAGE(STATUS "JAVA_HOME: " ${JAVA_HOME})
ENDIF()

IF(UNIX)
    #SET(QT_ANDROID_QT_ROOT C:/Qt/Qt5.12.4/5.12.4/android_arm64_v8a )
    SET(QT_ANDROID_SDK_ROOT /opt/android-sdk )
    SET(QT_ANDROID_NDK_ROOT /opt/android-sdk/ndk/19.2.5345600/ )
ELSEIF(WIN32)
    SET(QT_ANDROID_QT_ROOT C:/Qt/Qt5.12.4/5.12.4/android_arm64_v8a )
    SET(QT_ANDROID_NDK_ROOT C:/Android_NDK/android-ndk-r19c )
    SET(QT_ANDROID_SDK_ROOT C:/Android_SDK_CommandLine )
ENDIF()
# predefines
set(CMAKE_SYSTEM_NAME Android CACHE STRING "CMake flags" FORCE)
set(CMAKE_SYSTEM_PROCESSOR aarch64 CACHE STRING "CMake flags" FORCE)
SET(CMAKE_ANDROID_NDK ${QT_ANDROID_NDK_ROOT} CACHE PATH "CMake flags" FORCE)
SET(ANDROID_NDK ${QT_ANDROID_NDK_ROOT} CACHE PATH "CMake flags" FORCE)
SET(CMAKE_SYSTEM_VERSION 21 CACHE STRING "CMake flags" FORCE)
SET(ANDROID_API 21 CACHE STRING "CMake flags" FORCE)
SET(ANDROID_PLATFORM 21 CACHE STRING "CMake flags" FORCE)
SET(CMAKE_ANDROID_ARCH_ABI arm64-v8a CACHE STRING "CMake flags" FORCE)
SET(ANDROID_ABI arm64-v8a CACHE STRING "CMake flags" FORCE)
SET(ARM64_V8A TRUE CACHE BOOL "CMake flags" FORCE)
#SET(CMAKE_ANDROID_NDK_TOOLCHAIN_VERSION clang)
SET(ANDROID_STL none CACHE STRING "CMake flags" FORCE)
#set(ANDROID_STL_PREFIX llvm-libc++)
#set(QT_ANDROID_STL_PATH "${QT_ANDROID_NDK_ROOT}/sources/cxx-stl/${ANDROID_STL_PREFIX}/libs/${ANDROID_ABI}/lib${ANDROID_STL}.so")
# define Debug and Debug flags
SET(CMAKE_BUILD_TYPE Debug)
SET(CMAKE_CXX_FLAGS_DEBUG "-nostdinc++" ) #ignores standard C++ include directories
SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -nostdlib++") #not linking c++ standard library
SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -std=c++11") #c++11 to fit QT
SET(CMAKE_CXX_FLAGS_RELEASE "-nostdinc++" ) #ignores standard C++ include directories
SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_DEBUG} -nostdlib++") #not linking c++ standard library
SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_DEBUG} -std=c++11") #c++11 to fit QT
MESSAGE(STATUS "CMAKE_CXX_FLAGS_DEBUG: " ${CMAKE_CXX_FLAGS_DEBUG})
MESSAGE(STATUS "CMAKE_CXX_FLAGS_RELEASE: " ${CMAKE_CXX_FLAGS_RELEASE})

# CMAKE_MAKE_PROGRAM must be defined before CMAKE_TOOLCHAIN_FILE
IF(UNIX)
ELSEIF(WIN32)
    IF(CMAKE_GENERATOR STREQUAL "MinGW Makefiles")
        SET(CMAKE_MAKE_PROGRAM C:/Qt/Qt5.12.4/Tools/mingw730_32/bin/mingw32-make.exe CACHE PATH "CMake flags" FORCE)
    ELSEIF(CMAKE_GENERATOR STREQUAL "Ninja")
        SET(CMAKE_MAKE_PROGRAM C:/Ninja/ninja.exe CACHE PATH "CMake flags" FORCE)
    ELSE()
        MESSAGE(STATUS "CMAKE_GENERATOR: " ${CMAKE_GENERATOR})
    ENDIF()
ENDIF()
SET(CMAKE_TOOLCHAIN_FILE ${QT_ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake)
#MESSAGE(STATUS "CMAKE_TOOLCHAIN_FILE: " ${CMAKE_TOOLCHAIN_FILE})
#MESSAGE(STATUS "CMAKE_MAKE_PROGRAM: " ${CMAKE_MAKE_PROGRAM})

# output variable
SET(ANDROID_INCLUDE ${ANDROID_INCLUDE} ${QT_ANDROID_NDK_ROOT}/sources/cxx-stl/llvm-libc++/include )
SET(ANDROID_LIBS ${ANDROID_LIBS} ${QT_ANDROID_NDK_ROOT}/sources/cxx-stl/llvm-libc++/libs/arm64-v8a/libc++_shared.so )
SET(ANDROID_LIBS ${ANDROID_LIBS} ${QT_ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/aarch64-linux-android/${ANDROID_API}/libstdc++.so  )
SET(ANDROID_LIB_DIR ${ANDROID_LIB_DIR} ${QT_ANDROID_NDK_ROOT}/sources/cxx-stl/llvm-libc++/libs/arm64-v8a/ )
