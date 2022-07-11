CMAKE_MINIMUM_REQUIRED(VERSION 3.2)
message( "****************************************break line****************************************" )
message( "****************************************rikposscale****************************************" )
MESSAGE(STATUS "CMAKE_GENERATOR: " ${CMAKE_GENERATOR})
MESSAGE(STATUS "CMAKE_SOURCE_DIR: " ${CMAKE_SOURCE_DIR})
MESSAGE(STATUS "CMAKE_CURRENT_BINARY_DIR: " ${CMAKE_CURRENT_BINARY_DIR})

# CMake predefine
# some predefines must be placed before PROJECT() section, in order to make right decision during cmake compiler choosing 
#include("android_ndk_llvm.cmake")
include("./cmake/linux_predefine.cmake")
#include("./cmake/android_predefine.cmake")
IF(ANDROID)
    MESSAGE(STATUS "QT_HOME: " ${QT_ANDROID_QT_ROOT})
    MESSAGE(STATUS "NDK_HOME: " ${QT_ANDROID_NDK_ROOT})
    MESSAGE(STATUS "SDK_HOME: " ${QT_ANDROID_SDK_ROOT})
ENDIF(ANDROID)


PROJECT(build_library)

# CMake config
# CMAKE_VERBOSE_MAKEFILE -> enable make output verbose
set(CMAKE_VERBOSE_MAKEFILE ON) # or make VERBOSE=1

#ADD_SUBDIRECTORY(posscale/src)
#ADD_SUBDIRECTORY(libJNITest/src)
ADD_SUBDIRECTORY(project/src)
