CMAKE_MINIMUM_REQUIRED(VERSION 3.2)

#Solution name
#project
SET ( PROJECT_NAME test_project )
#CMake include
#include("android_ndk_llvm.cmake")

ADD_EXECUTABLE ( ${PROJECT_NAME} "")

target_sources( ${PROJECT_NAME} 
	PRIVATE ${CMAKE_CURRENT_LIST_DIR}/../include/test.h

		${CMAKE_CURRENT_LIST_DIR}/test.cpp
)

target_include_directories( ${PROJECT_NAME} 
	PRIVATE ${CMAKE_CURRENT_LIST_DIR}/../include	
)

# Must After add_executable
target_link_libraries( ${PROJECT_NAME}
	""
)
