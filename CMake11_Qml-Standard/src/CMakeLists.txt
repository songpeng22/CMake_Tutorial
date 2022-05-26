# CMake Settings
cmake_minimum_required(VERSION 3.1.0)
message( "***************************break line**********************************" )

# Solution Setting
# must be set before find_package( Qt5 ), or will cause link error
project(Solution)
# Project Setting
set( project_name QmlStandard )
message( "Project name is: " ${project_name} )

# CMake Check OS
if (WIN32)
    set( WINDOWS 1 )
    message( "this is windows." )
elseif(UNIX)
    set( LINUX 1 )
    message( "this is linux." )
else()
    message( "this is unknown OS." )
endif()
# CMake Include
include("recursive_search.cmake")
if(WINDOWS)
    include("choose_qt_sdk.cmake")
elseif(LINUX)
    include("choose_qt_sdk_linux.cmake")
endif()

# CMake Find Package Path
if( NOT DEFINED CMAKE_PREFIX_PATH )
    if( WINDOWS )
        CHOOSE_QT_SDK( QT_MSVC2015_32 )
    elseif( LINUX )
        CHOOSE_QT_SDK( QT_LINUX )
    else()
	message( "fail to choose sdk." )
    endif()
else()
    message( "CMAKE_PREFIX_PATH from env: " ${CMAKE_PREFIX_PATH} )
endif( NOT DEFINED CMAKE_PREFIX_PATH )
# CMake QT Find Package etc.
CMAKE_QT_CONFIG()

# Definitions
set(CMAKE_BUILD_TYPE Debug)
IF(WINDOWS)
    message( "WIN32." )
    SET(OS_PREFIX winnt_x86)
    IF(WIN32 AND MSVC)
      set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DQT_QML_DEBUG ")
      set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DCMAKE_BUILD_TYPE=Debug ")

      add_compile_options("$<$<C_COMPILER_ID:MSVC>:/utf-8>")
      add_compile_options("$<$<CXX_COMPILER_ID:MSVC>:/utf-8>")
    ENDIF()
ELSE()

ENDIF()

IF(WIN64)
  message( "WIN64." )
ENDIF()

include_directories(
# Qt5::Core means there is ".\include\QtCore""
    Qt5::Core   
    Qt5::Gui
    Qt5::Widgets
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickWidgets
    Qt5::QuickControls2
    Qt5::VirtualKeyboard
    Qt5::Network
)

# Populate a CMake variable with the sources
FILE(GLOB project_sources
    main.cpp
    EngineReloader.cpp
    EngineReloaderWrapper.cpp
    QuickViewReloader.cpp
    QuickViewReloaderWrapper.cpp
)

FILE(GLOB project_headers
    *.h
)

SET( project_resources 
    choose_qt_sdk.cmake
    recursive_search.cmake
    utils.js
    main.qrc
    ./base/Config.qml
    main.qml
    method2.qml
)

#Same type together
SOURCE_GROUP("Source Files" FILES ${project_sources})
SOURCE_GROUP("Header Files" FILES ${project_headers})
SOURCE_GROUP("Resource Files" FILES ${project_resources})

# mark as startup project
IF(WIN32 AND MSVC)
    set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${project_name})
ELSE()
    
ENDIF()

# Tell CMake to create the project executable
if(WINDOWS)
    add_executable( ${project_name} WIN32 ${project_sources} ${project_headers} ${project_resources})
elseif(LINUX)
    add_executable( ${project_name} ${project_sources} ${project_headers} ${project_resources})
endif()


# set_target_properties(target1 target2 ...PROPERTIES prop1 value1 prop2 value2 ...)
# Output Path
set_target_properties( ${project_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/../bin )
set_target_properties( ${project_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/../bin )
# Output Name
SET_TARGET_PROPERTIES( ${project_name} PROPERTIES OUTPUT_NAME_DEBUG "${project_name}_d")
SET_TARGET_PROPERTIES( ${project_name} PROPERTIES OUTPUT_NAME_RELEASE "${project_name}")
# get_target_property
get_target_property(QtCore_location Qt5::Core LOCATION)
MESSAGE(STATUS "This is QtCore_location " ${QtCore_location})

# Must After add_executable
target_link_libraries( ${project_name}
    ${Qt5Core_LIBRARIES}
    ${Qt5Gui_LIBRARIES}
    ${Qt5Widgets_LIBRARIES}
    ${Qt5Qml_LIBRARIES}
    ${Qt5Quick_LIBRARIES}
    ${Qt5QuickWidgets_LIBRARIES}
    ${Qt5QuickControls2_LIBRARIES}
    ${Qt5VirtualKeyboard_LIBRARIES}
    ${Qt5Network_LIBRARIES}
)

#Message Sln Path
MESSAGE(STATUS "Message:" )
MESSAGE(STATUS "This is BINARY dir " ${Solution_BINARY_DIR})
MESSAGE(STATUS "This is SOURCE dir " ${Solution_SOURCE_DIR})
#Message Qt Path
MESSAGE(STATUS "Message:" )
MESSAGE(STATUS "This is Qt5Widgets_INCLUDE_DIRS " ${Qt5Widgets_INCLUDE_DIRS})
MESSAGE(STATUS "This is Qt5Widgets_LIBRARIES " ${Qt5Widgets_LIBRARIES})
MESSAGE(STATUS "This is Qt5Qml_INCLUDE_DIRS " ${Qt5Qml_INCLUDE_DIRS})
