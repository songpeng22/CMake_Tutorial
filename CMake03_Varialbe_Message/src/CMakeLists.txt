CMAKE_MINIMUM_REQUIRED(VERSION 3.2)
#Setting
SET (REMOTE_DEBUG 1)

#Solutin
PROJECT(Solution)

INCLUDE_DIRECTORIES(
../include
)

SET (project_sources
test.cpp
)

SET (project_headers
../include/include.h
test.h
)

MESSAGE(STATUS "REMOTE_DEBUG: " ${REMOTE_DEBUG})
MESSAGE(STATUS "This is BINARY dir " ${Solution_BINARY_DIR})
MESSAGE(STATUS "This is SOURCE dir " ${Solution_SOURCE_DIR})
MESSAGE(STATUS "This is CMAKE_CURRENT_BINARY_DIR dir " ${CMAKE_CURRENT_BINARY_DIR})


ADD_EXECUTABLE (Solution ${project_sources} ${project_headers})
