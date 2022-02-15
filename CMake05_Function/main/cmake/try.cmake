CMAKE_MINIMUM_REQUIRED(VERSION 3.5 FATAL_ERROR)

macro(try_macro_param LIB_NAME APK_NAME)
    message(STATUS "LIB_NAME is:"${LIB_NAME})
    message(STATUS "APK_NAME is:"${APK_NAME})

    # parse the macro arguments
    cmake_parse_arguments(ARG "OPTION_1st" "PACKAGE_NAME" "" ${ARGN})

    message(STATUS "OPTION_1st is:"${ARG_OPTION_1st})
    message(STATUS "PACKAGE_NAME is:"${ARG_PACKAGE_NAME})
endmacro()