#Version
CMAKE_MINIMUM_REQUIRED(VERSION 3.2)

#Solutin
PROJECT(Solution)

function(add_component NAME)

    set(options "")
    set(oneValueArgs PACKAGE)
    set(multiValueArgs "SOURCES;INCLUDES")

    cmake_parse_arguments(COMP "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    # 通过 prefix_参数名: 例如 STUDENT_ADULT
    message("package  = ${COMP_PACKAGE}")
    message("sources  = ${COMP_SOURCES}")
    message("includes  = ${COMP_INCLUDES}")

endfunction()

add_component(TDI "" PACKAGE SPHINX 
    SOURCES 
      100 
      200 
      300
    INCLUDES 
      1 
      2 
      3)
