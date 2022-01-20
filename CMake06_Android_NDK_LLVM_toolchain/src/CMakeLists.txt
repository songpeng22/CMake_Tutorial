CMAKE_MINIMUM_REQUIRED(VERSION 3.2)

#Solution name
PROJECT(Solution)
#project
SET ( project_name test_project )

set(CMAKE_SYSTEM_NAME Android)
set(CMAKE_SYSTEM_PROCESSOR arm64)

set(tool_chain /opt/android-ndk/ndk/toolchains/llvm/prebuilt/linux-x86_64)
set(CMAKE_C_COMPILER ${tool_chain}/bin/aarch64-linux-android26-clang)
set(CMAKE_CXX_COMPILER ${tool_chain}/bin/aarch64-linux-android26-clang++)

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
