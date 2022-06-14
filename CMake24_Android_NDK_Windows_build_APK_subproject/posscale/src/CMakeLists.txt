CMAKE_MINIMUM_REQUIRED(VERSION 3.2)
message( "****************************************break line****************************************" )
message( "****************************************posscale/src****************************************" )
MESSAGE(STATUS "CMAKE_GENERATOR: " ${CMAKE_GENERATOR})
MESSAGE(STATUS "CMAKE_SOURCE_DIR: " ${CMAKE_SOURCE_DIR})
MESSAGE(STATUS "CMAKE_CURRENT_BINARY_DIR: " ${CMAKE_CURRENT_BINARY_DIR})

#Solution name
PROJECT(posscale)
#project
#SET ( PROJECT_NAME qtTest )

# CMake include 
# CMake include QT
include("../../cmake/qt.cmake")
CHOOSE_QT_SDK(QT_ANDROID)
useQtModule(Core)
useQtModule(Gui)
useQtModule(Widgets)
useQtModule(Quick)
useQtModule(QuickWidgets)
useQtModule(QuickControls2)
useQtModule(Qml)
useQtModule(Network)
message(STATUS "QT_INCLUDES is:" ${QT_INCLUDES})
message(STATUS "QT_LIBS is:" ${QT_LIBS})
# CMake include android
include(../../cmake/add_qt_lib_to_apk.cmake)



# make sure that the Android toolchain is used
IF(NOT ANDROID)
    MESSAGE(STATUS "ANDROID not exist.")
ELSE()
    MESSAGE(STATUS "ANDROID: " ${ANDROID})
ENDIF()

# CMake flags
SET(CMAKE_BUILD_TYPE Debug)
SET(CMAKE_CXX_FLAGS_DEBUG "-stdlib=libc++ -std=c++11")
add_compile_options(-Wall)
MESSAGE(STATUS "CMAKE_C_FLAGS: " ${CMAKE_C_FLAGS})
MESSAGE(STATUS "CMAKE_CXX_FLAGS: " ${CMAKE_CXX_FLAGS})
MESSAGE(STATUS "CMAKE_C_FLAGS_DEBUG: " ${CMAKE_C_FLAGS_DEBUG})
MESSAGE(STATUS "CMAKE_CXX_FLAGS_DEBUG: " ${CMAKE_CXX_FLAGS_DEBUG})


INCLUDE_DIRECTORIES(
# Qt5::Core means there is "./include/QtCore""
    ${CXX_INCLUDES}
    #C:/Android_NDK/android-ndk-r19c/sources/cxx-stl/llvm-libc++abi/include
    ${QT_INCLUDES}
)

link_directories(
    # QT .so
    C:/Qt/Qt5.12.4/5.12.4/android_arm64_v8a/lib/
    # libc++
    #${CXX_LIBS_DIR}
    # libstdc++ 
    #C:/Android_NDK/android-ndk-r19c/toolchains/llvm/prebuilt/windows/sysroot/usr/lib/aarch64-linux-android/21
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
    ${CXX_LIBS}
    #libstdc++.so
    libGLESv2.so
    libQt5QuickTemplates2.so
)

# Must After add_executable
target_link_libraries( ${PROJECT_NAME}
    ${PLIBS}
    ${QT_LIBS}
)

# APK generator
if(ANDROID)
    set(LIB_NAME ${PROJECT_NAME})
    set(APK_NAME ${LIB_NAME})
    message(STATUS "PROJECT_NAME is:" ${PROJECT_NAME})

    add_qt_android_apk( ${LIB_NAME} ${APK_NAME} )
endif()

