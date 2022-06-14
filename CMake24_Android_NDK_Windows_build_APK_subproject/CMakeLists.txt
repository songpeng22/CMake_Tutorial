CMAKE_MINIMUM_REQUIRED(VERSION 3.2)
message( "****************************************break line****************************************" )
message( "****************************************rikposscale****************************************" )
MESSAGE(STATUS "CMAKE_GENERATOR: " ${CMAKE_GENERATOR})
MESSAGE(STATUS "CMAKE_SOURCE_DIR: " ${CMAKE_SOURCE_DIR})
MESSAGE(STATUS "CMAKE_CURRENT_BINARY_DIR: " ${CMAKE_CURRENT_BINARY_DIR})

# CMake predefine
# some predefines must be placed before PROJECT() section, in order to make right decision during cmake compiler choosing 
include("./cmake/android_predefine.cmake")
MESSAGE(STATUS "QT_HOME: " ${QT_ANDROID_QT_ROOT})
MESSAGE(STATUS "NDK_HOME: " ${QT_ANDROID_NDK_ROOT})
MESSAGE(STATUS "SDK_HOME: " ${QT_ANDROID_SDK_ROOT})

PROJECT(rikposscale)

ADD_SUBDIRECTORY(posscale/src)
