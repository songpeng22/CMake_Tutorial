#Version
CMAKE_MINIMUM_REQUIRED(VERSION 3.17)

#Solutin
PROJECT(Solution)
#project
SET ( project_name test_project )

function(add_component NAME)
  set(options "")
  set(oneValueArgs PACKAGE)
  set(multiValueArgs "SOURCES;INCLUDES")

  cmake_parse_arguments(COMP "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

  # prefix PACKAGE_SPHINX
  message("package  = ${COMP_PACKAGE}")
  message("sources  = ${COMP_SOURCES}")
  message("includes  = ${COMP_INCLUDES}")
endfunction()

# 必须包含模块
include(FetchContent)  
# 声明要获取的内容
FetchContent_Declare(
  googletest          # 自定义名称
  GIT_REPOSITORY https://github.com/google/googletest.git
  GIT_TAG main
)
# 执行下载并引入项目
FetchContent_MakeAvailable(googletest)

add_component(TDI "" PACKAGE SPHINX 
    SOURCES 
      100 
      200 
      300
    INCLUDES 
      1 
      2 
      3)

#project
FILE (GLOB project_sources
	*.cpp
)

# 使用依赖项
add_executable(${project_name} ${project_sources})
target_link_libraries(${project_name} PRIVATE gtest_main)
