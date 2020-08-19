CMAKE_MINIMUM_REQUIRED(VERSION 3.2)

#Solution name
PROJECT(Solution)
#project
SET ( project_name test_project )

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
    libcmtd.lib#libcmtd.lib#legacy_stdio_definitions.lib
    Dwmapi.lib
    imm32.lib
    iphlpapi.lib
    Netapi32.lib
    opengl32.lib
    Winmm.lib
    ws2_32.lib
    version.lib#Mincore.lib
    userenv.lib
    libzmq.lib
    libprotobuf.lib
    comctl32.lib
    rpcrt4.lib
    wsock32.lib
    odbc32.lib
)

# Must After add_executable
target_link_libraries( ${project_name}
    ${PLIBS}
)