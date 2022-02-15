CMAKE_MINIMUM_REQUIRED(VERSION 3.2)
message( "****************************************break line****************************************" )
MESSAGE(STATUS "CMAKE_GENERATOR: " ${CMAKE_GENERATOR})
MESSAGE(STATUS "CMAKE_SOURCE_DIR: " ${CMAKE_SOURCE_DIR})
MESSAGE(STATUS "CMAKE_CURRENT_BINARY_DIR: " ${CMAKE_CURRENT_BINARY_DIR})


# CMake predefine
# some predefines must be placed before PROJECT() section, in order to make right decision during cmake compiler choosing 
include("android_predefine.cmake")
MESSAGE(STATUS "QT_HOME: " ${QT_ANDROID_QT_ROOT})
MESSAGE(STATUS "NDK_HOME: " ${QT_ANDROID_NDK_ROOT})
MESSAGE(STATUS "SDK_HOME: " ${QT_ANDROID_SDK_ROOT})

#Solution name
PROJECT(Android_Solution)
#project
SET ( PROJECT_NAME qtTest )

# CMake include 
include("choose_qt_sdk.cmake")
CHOOSE_QT_SDK(QT_ANDROID)
# CMake QT config(Find package etc.)
CMAKE_QT_CONFIG()
include("add_qt_lib_to_apk.cmake")

# make sure that the Android toolchain is used
IF(NOT ANDROID)
    MESSAGE(STATUS "ANDROID not exist.")
ELSE()
    MESSAGE(STATUS "ANDROID: " ${ANDROID})
ENDIF()

# CMake flags
SET(CMAKE_BUILD_TYPE Debug)
#SET(CMAKE_CXX_FLAGS_DEBUG "-std=c++11")	#/MTd
add_compile_options(-Wall)
MESSAGE(STATUS "CMAKE_C_FLAGS: " ${CMAKE_C_FLAGS})
MESSAGE(STATUS "CMAKE_CXX_FLAGS: " ${CMAKE_CXX_FLAGS})
MESSAGE(STATUS "CMAKE_C_FLAGS_DEBUG: " ${CMAKE_C_FLAGS_DEBUG})
MESSAGE(STATUS "CMAKE_CXX_FLAGS_DEBUG: " ${CMAKE_CXX_FLAGS_DEBUG})


INCLUDE_DIRECTORIES(
# Qt5::Core means there is "./include/QtCore""
    C:/Android_NDK/android-ndk-r19c/sources/cxx-stl/llvm-libc++/include
    C:/Android_NDK/android-ndk-r19c/sources/cxx-stl/llvm-libc++abi/include
    Qt5::Core   
    Qt5::Gui
    Qt5::Widgets
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickWidgets
    Qt5::QuickControls2
)

link_directories(
    # QT .so
    C:/Qt/Qt5.12.4/5.12.4/android_arm64_v8a/lib/
    # libc++
    C:/Android_NDK/android-ndk-r19c/sources/cxx-stl/llvm-libc++/libs/arm64-v8a/
    # libstdc++ 
    C:/Android_NDK/android-ndk-r19c/toolchains/llvm/prebuilt/windows/sysroot/usr/lib/aarch64-linux-android/21
    #C:/Android_NDK/android-ndk-r19c/platforms/android-21/arch-arm64/usr/lib/
)

#project
FILE (GLOB PROJECT_SOURCES
	*.cpp
    *.qml
    qml.qrc
)

SET (PROJECT_HEADERS

)

ADD_DEFINITIONS(
-DZMQ_STATIC
)

IF(ANDROID)
    ADD_LIBRARY( ${PROJECT_NAME} SHARED ${PROJECT_SOURCES} ${PROJECT_HEADERS} )
ELSE()
    ADD_EXECUTABLE ( ${PROJECT_NAME} ${PROJECT_SOURCES} ${PROJECT_HEADERS} )
ENDIF()

# Platform libs
set(PLIBS
    liblog.so
    libz.so
    libc++_shared.so
    libstdc++.so
    libGLESv2.so
    libQt5QuickTemplates2.so
)

# Must After add_executable
target_link_libraries( ${PROJECT_NAME}
    ${PLIBS}
    ${Qt5Core_LIBRARIES}
    ${Qt5Gui_LIBRARIES}
    ${Qt5Widgets_LIBRARIES}
    ${Qt5Qml_LIBRARIES}
    ${Qt5Quick_LIBRARIES}
    ${Qt5QuickWidgets_LIBRARIES}
    ${Qt5QuickControls2_LIBRARIES}
)

# APK generator
if(ANDROID)
    set(LIB_NAME ${PROJECT_NAME})
    set(APK_NAME ${LIB_NAME})
    message(STATUS "PROJECT_NAME is:" ${PROJECT_NAME})

    add_qt_android_apk( ${LIB_NAME} ${APK_NAME} )
endif()

