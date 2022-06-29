CMAKE_MINIMUM_REQUIRED(VERSION 3.2)
message( "****************************************break line****************************************" )
message( "****************************************rikposscale****************************************" )
MESSAGE(STATUS "CMAKE_GENERATOR: " ${CMAKE_GENERATOR})
MESSAGE(STATUS "CMAKE_SOURCE_DIR: " ${CMAKE_SOURCE_DIR})
MESSAGE(STATUS "CMAKE_CURRENT_BINARY_DIR: " ${CMAKE_CURRENT_BINARY_DIR})

# CMake predefine
#CMAKE_MODULE_PATH Test OK
#set( CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake )
#include(android_predefine)
# some predefines must be placed before PROJECT() section, in order to make right decision during cmake compiler choosing 
include("./cmake/android_predefine.cmake")

MESSAGE(STATUS "QT_HOME: " ${QT_ANDROID_QT_ROOT})
MESSAGE(STATUS "NDK_HOME: " ${QT_ANDROID_NDK_ROOT})
MESSAGE(STATUS "SDK_HOME: " ${QT_ANDROID_SDK_ROOT})

PROJECT(build_library)

set( CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/ )
message(STATUS "CMAKE_MODULE_PATH:${CMAKE_MODULE_PATH}")
include(CommonTools)

# enable DEBUG
set(_DEBUG ON)
set(_VERBOSE ON)
# tell CMake to search both host environment and target environment.
message(STATUS "CMAKE_FIND_ROOT_PATH_MODE_INCLUDE:${CMAKE_FIND_ROOT_PATH_MODE_INCLUDE}")
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
message(STATUS "CMAKE_FIND_ROOT_PATH_MODE_INCLUDE:${CMAKE_FIND_ROOT_PATH_MODE_INCLUDE}")
message(STATUS "CMAKE_FIND_ROOT_PATH:${CMAKE_FIND_ROOT_PATH}")

function( CheckHasModule Module )
        unset( __MODULE_LOCATION CACHE )
        unset( HAS_MODULE_${Module} CACHE )
		if( _DEBUG AND _VERBOSE )
                message( STATUS "MODULE_FILE : ${Module}.cmake" )
				message( STATUS "CMAKE_MODULE_PATH : ${CMAKE_MODULE_PATH}" )
        endif()
        find_file( __MODULE_LOCATION name ${Module}.cmake PATHS ${CMAKE_MODULE_PATH} CMAKE_FIND_ROOT_PATH_BOTH  ) # tell CMake to search both host environment and target environment in this find.
        if( _DEBUG AND _VERBOSE )
                message( STATUS "MODULE_LOCATION : ${Module} ----- ${__MODULE_LOCATION}" )
        endif()
        if( "${__MODULE_LOCATION}" STREQUAL "__MODULE_LOCATION-NOTFOUND" )
                set( HAS_MODULE_${Module} FALSE PARENT_SCOPE )
        else()
                set( HAS_MODULE_${Module} TRUE PARENT_SCOPE )
        endif()
endfunction()



CheckHasModule( CommonTools )
message(STATUS "HAS_MODULE_CommonTools:${HAS_MODULE_CommonTools}")
if( NOT ${HAS_MODULE_CommonTools} )
        message( FATAL_ERROR "Required custom CMake script CommonTools was not found.\r\nPlease check your CMAKE_MODULE_PATH?\n" )
else()
		message(STATUS "CommonTools Found.")
endif()


#ADD_SUBDIRECTORY(posscale/src)
ADD_SUBDIRECTORY(libJNITest/src)
