CMAKE_MINIMUM_REQUIRED(VERSION 3.2)

#Solution name
PROJECT(Solution)
#project
SET ( project_name test_project )
#CMake include
include("android_ndk_llvm.cmake")

INCLUDE_DIRECTORIES(
../include
)

#project
FILE (GLOB project_sources
	*.cpp
)

SET (project_headers
../include/include.h
test.h
)

ADD_DEFINITIONS(
-DZMQ_STATIC
)

ADD_EXECUTABLE ( ${project_name} ${project_sources} ${project_headers})

# Platform libs
set(PLIBS
)

# Must After add_executable
target_link_libraries( ${project_name}
#    ${PLIBS}
)
