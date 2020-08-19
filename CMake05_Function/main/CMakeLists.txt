CMAKE_MINIMUM_REQUIRED(VERSION 3.2)
#Setting
SET (REMOTE_DEBUG 1)
# CMake Include
include("./cmake/recursive_search.cmake")
include("./cmake/force_mtd.cmake")
# force to use mtd
configureMsvcRuntime()

#Solutin
#PROJECT(Solution)
#project
SET ( project_name main )

INCLUDE_DIRECTORIES(
./include
./src
./cmake
)

SET (project_sources
./src/test.cpp
)

SET (project_headers
./include/include.h
./src/test.h
)

SET (project_resources
./cmake/force_mtd.cmake
./cmake/recursive_search.cmake
)


MESSAGE(STATUS "REMOTE_DEBUG: " ${REMOTE_DEBUG})
MESSAGE(STATUS "This is BINARY dir " ${Solution_BINARY_DIR})
MESSAGE(STATUS "This is SOURCE dir " ${Solution_SOURCE_DIR})
MESSAGE(STATUS "This is CMAKE_CURRENT_BINARY_DIR dir " ${CMAKE_CURRENT_BINARY_DIR})


ADD_EXECUTABLE ( ${project_name} ${project_sources} ${project_headers} ${project_resources} )
