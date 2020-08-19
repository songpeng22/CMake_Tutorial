CMAKE_MINIMUM_REQUIRED(VERSION 3.2)
#Setting
SET (REMOTE_DEBUG 1)

#Solutin
#PROJECT(Solution)
#project
SET ( project_name library )

INCLUDE_DIRECTORIES(
./include
./src
)

SET (project_sources
./src/library.cpp
)

SET (project_headers
./include/include.h
./src/library.h
)

MESSAGE(STATUS "REMOTE_DEBUG: " ${REMOTE_DEBUG})
MESSAGE(STATUS "This is BINARY dir " ${Solution_BINARY_DIR})
MESSAGE(STATUS "This is SOURCE dir " ${Solution_SOURCE_DIR})
MESSAGE(STATUS "This is CMAKE_CURRENT_BINARY_DIR dir " ${CMAKE_CURRENT_BINARY_DIR})

#target
ADD_LIBRARY ( ${project_name} STATIC ${project_sources} ${project_headers})

#output directory
MESSAGE(STATUS "library output directory: " ${Solution_SOURCE_DIR}/main/lib)
SET_TARGET_PROPERTIES( ${project_name} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG   ${Solution_SOURCE_DIR}/main/lib )
#SET_TARGET_PROPERTIES( ${project_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG   ${Solution_SOURCE_DIR}/main/lib )
#SET_TARGET_PROPERTIES( ${project_name} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_DEBUG   ${Solution_SOURCE_DIR}/main/lib )