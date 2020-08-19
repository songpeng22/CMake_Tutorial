CMAKE_MINIMUM_REQUIRED(VERSION 3.2)
#Setting
SET (REMOTE_DEBUG 1)

#Solutin
#PROJECT(Solution)
#project
SET ( project_name main )

INCLUDE_DIRECTORIES(
./include
./src
)

link_directories(
./lib
)

SET (project_sources
./src/test.cpp
)

SET (project_headers
./include/include.h
./src/test.h
)

MESSAGE(STATUS "REMOTE_DEBUG: " ${REMOTE_DEBUG})
MESSAGE(STATUS "This is BINARY dir " ${Solution_BINARY_DIR})
MESSAGE(STATUS "This is SOURCE dir " ${Solution_SOURCE_DIR})
MESSAGE(STATUS "This is CMAKE_CURRENT_BINARY_DIR dir " ${CMAKE_CURRENT_BINARY_DIR})


ADD_EXECUTABLE ( ${project_name} ${project_sources} ${project_headers})
# Must After add_executable
target_link_libraries( ${project_name}
    library.lib
)