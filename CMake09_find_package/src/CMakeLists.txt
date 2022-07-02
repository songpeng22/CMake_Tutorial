CMAKE_MINIMUM_REQUIRED(VERSION 3.2)
message( "****************************************break line****************************************" )
message( "****************************************APITest/src****************************************" )
MESSAGE(STATUS "CMAKE_GENERATOR: " ${CMAKE_GENERATOR})
MESSAGE(STATUS "CMAKE_SOURCE_DIR: " ${CMAKE_SOURCE_DIR})
MESSAGE(STATUS "CMAKE_CURRENT_BINARY_DIR: " ${CMAKE_CURRENT_BINARY_DIR})

#Solution name
PROJECT(build_APITest)
#project name/target name
SET ( TARGET_NAME APITest )

# CMake config
# CMAKE_VERBOSE_MAKEFILE -> enable make output verbose
set(CMAKE_VERBOSE_MAKEFILE ON) # or make VERBOSE=1
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake;${CMAKE_MODULE_PATH}")
message(STATUS "CMAKE_MODULE_PATH:${CMAKE_MODULE_PATH}")


add_executable(${TARGET_NAME})
find_package(logTest REQUIRED)
if(LOGTEST_FOUND)
	target_include_directories(${TARGET_NAME}
		PRIVATE ${LOGTEST_INCLUDE_DIR}
  	)
  	target_link_libraries(${TARGET_NAME}
		${LOGTEST_LIBRARY}
  	)
else()
    message(STATUS "LOGTEST NOT FOUND.")
endif()
target_sources(${TARGET_NAME}
	PRIVATE ${CMAKE_CURRENT_LIST_DIR}/main.cpp
		${LOGTEST_INCLUDE_DIR}/logTest.h
)

#add_custom_command(TARGET <target>
#               PRE_BUILD | PRE_LINK | POST_BUILD
#               COMMAND command1 [ARGS] [args1...]
#               [COMMAND command2 [ARGS] [args2...] ...]
#               [BYPRODUCTS [files...]]
#               [WORKING_DIRECTORY dir]
#               [COMMENT comment]
#               [VERBATIM] [USES_TERMINAL]
#               [COMMAND_EXPAND_LISTS])
add_custom_command(
    # after the target has been created, this custom command will start to run
    TARGET ${TARGET_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E echo "post build of build_library:.............................................................................1"
    #COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/../../lib${TARGET_NAME}/src/lib${TARGET_NAME}.so ${CMAKE_SOURCE_DIR}/android/libs/
    #COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/libTest1/src/libTest1.h ${CMAKE_SOURCE_DIR}/android/include/
)


