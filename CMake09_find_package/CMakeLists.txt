CMAKE_MINIMUM_REQUIRED(VERSION 3.2)
message( "****************************************break line****************************************" )
message( "****************************************rikposscale****************************************" )
MESSAGE(STATUS "CMAKE_GENERATOR: " ${CMAKE_GENERATOR})
MESSAGE(STATUS "CMAKE_SOURCE_DIR: " ${CMAKE_SOURCE_DIR})
MESSAGE(STATUS "CMAKE_CURRENT_BINARY_DIR: " ${CMAKE_CURRENT_BINARY_DIR})
MESSAGE(STATUS "CMAKE_INSTALL_PREFIX: " ${CMAKE_INSTALL_PREFIX})

# CMake Solution
PROJECT(Solution)

# CMake Config
set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/install) 

ADD_SUBDIRECTORY(src)
