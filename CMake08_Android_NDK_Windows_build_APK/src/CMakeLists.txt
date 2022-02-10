CMAKE_MINIMUM_REQUIRED(VERSION 3.2)
message( "***************************break line**********************************" )

#Solution name
PROJECT(qtTest)
#project
SET ( project_name qtTest )

# CMake include 
include("choose_qt_sdk.cmake")
CHOOSE_QT_SDK(QT_ANDROID)
CMAKE_QT_CONFIG()
include("choose_android_sdk.cmake")
# CMake QT config(Find package etc.)

# CMake flags
MESSAGE(STATUS "CMAKE_C_FLAGS: " ${CMAKE_C_FLAGS})
MESSAGE(STATUS "CMAKE_CXX_FLAGS: " ${CMAKE_CXX_FLAGS})
MESSAGE(STATUS "CMAKE_CXX_FLAGS_DEBUG: " ${CMAKE_C_FLAGS_DEBUG})
MESSAGE(STATUS "CMAKE_CXX_FLAGS_DEBUG: " ${CMAKE_CXX_FLAGS_DEBUG})
SET(CMAKE_CXX_FLAGS_DEBUG "-std=c++11")	#/MTd


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
FILE (GLOB project_sources
	*.cpp
    *.qml
    qml.qrc
)

SET (project_headers

)

ADD_DEFINITIONS(
-DZMQ_STATIC
)

ADD_EXECUTABLE ( ${project_name} ${project_sources} ${project_headers})



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
target_link_libraries( ${project_name}
    ${PLIBS}
    ${Qt5Core_LIBRARIES}
    ${Qt5Gui_LIBRARIES}
    ${Qt5Widgets_LIBRARIES}
    ${Qt5Qml_LIBRARIES}
    ${Qt5Quick_LIBRARIES}
    ${Qt5QuickWidgets_LIBRARIES}
    ${Qt5QuickControls2_LIBRARIES}
)

