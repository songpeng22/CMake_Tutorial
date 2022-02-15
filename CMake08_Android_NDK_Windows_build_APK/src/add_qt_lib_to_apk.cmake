CMAKE_MINIMUM_REQUIRED(VERSION 3.2 FATAL_ERROR)

## 
 # Decide PATHs and DEFINEs
##
set(QT_ANDROID_APP_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/android-build)
file(MAKE_DIRECTORY ${QT_ANDROID_APP_BINARY_DIR}/libs/${ANDROID_ABI})
set(QT_ANDROID_APP_PATH ${CMAKE_CURRENT_BINARY_DIR}/${LIB_FULL_NAME})
set(QT_ANDROID_APPLICATION_BINARY ${QT_ANDROID_APP_PATH})
set(QT_ANDROID_APP_NAME ${APK_NAME})
set(QT_ANDROID_APP_PACKAGE_NAME com.example.${LIB_NAME})

set(ANDROID_STL_PREFIX llvm-libc++)
set(QT_ANDROID_STL_PATH "${QT_ANDROID_NDK_ROOT}/sources/cxx-stl/${ANDROID_STL_PREFIX}/libs/${ANDROID_ABI}/libc++_shared.so")

#set(QT_ANDROID_APP_EXTRA_LIBS "\"android-extra-libs\": \"${EXTRA_LIBS}\",")
# create our own configured package directory in build dir
set(QT_ANDROID_APP_PACKAGE_SOURCE_ROOT "${CMAKE_CURRENT_BINARY_DIR}/package")

set(QT_ANDROID_BUILD_TYPE --debug)

## 
 # Decide JSON file related setting
##
# detect latest Android SDK build-tools revision
set(QT_ANDROID_SDK_BUILDTOOLS_REVISION "0.0.0")
file(GLOB ALL_BUILD_TOOLS_VERSIONS RELATIVE ${QT_ANDROID_SDK_ROOT}/build-tools ${QT_ANDROID_SDK_ROOT}/build-tools/*)
foreach(BUILD_TOOLS_VERSION ${ALL_BUILD_TOOLS_VERSIONS})
    # find subfolder with greatest version
    if (${BUILD_TOOLS_VERSION} VERSION_GREATER ${QT_ANDROID_SDK_BUILDTOOLS_REVISION})
        set(QT_ANDROID_SDK_BUILDTOOLS_REVISION ${BUILD_TOOLS_VERSION})
    endif()
endforeach()
message(STATUS "Found Android SDK build tools version: ${QT_ANDROID_SDK_BUILDTOOLS_REVISION}")

# From Qt 5.14 qtandroideploy "target-architecture" is no longer valid in input file
# It have been replaced by "architectures": { "${ANDROID_ABI}": "${ANDROID_ABI}" }
# This allow to package multiple ABI in a single apk
# For now we only support single ABI build with this script (to ensure it work with Qt5.14 & Qt5.15)
if(QT_ANDROID_SUPPORT_MULTI_ABI)
    set(QT_ANDROID_ARCHITECTURES "\"${ANDROID_ABI}\":\"${ANDROID_ABI}\"")
endif()

# determine whether to use the gcc- or llvm/clang- toolchain;
# if ANDROID_USE_LLVM was explicitly set, use its value directly,
# otherwise ANDROID_TOOLCHAIN value (set by the NDK's toolchain file)
# says whether llvm/clang or gcc is used
if(DEFINED ANDROID_USE_LLVM)
    string(TOLOWER "${ANDROID_USE_LLVM}" QT_ANDROID_USE_LLVM)
elseif(ANDROID_TOOLCHAIN STREQUAL clang)
    set(QT_ANDROID_USE_LLVM "true")
else()
    set(QT_ANDROID_USE_LLVM "false")
endif()

# set some toolchain variables used by androiddeployqt;
# unfortunately, Qt tries to build paths from these variables although these full paths
# are already available in the toochain file, so we have to parse them if using gcc
if(QT_ANDROID_USE_LLVM STREQUAL "true")
    set(QT_ANDROID_TOOLCHAIN_PREFIX "llvm")
    set(QT_ANDROID_TOOLCHAIN_VERSION "4.9")
    set(QT_ANDROID_TOOL_PREFIX "llvm")
else()
    string(REGEX MATCH "${QT_ANDROID_NDK_ROOT}/toolchains/(.*)-(.*)/prebuilt/.*/bin/(.*)-" ANDROID_TOOLCHAIN_PARSED ${ANDROID_TOOLCHAIN_PREFIX})
    if(ANDROID_TOOLCHAIN_PARSED)
        set(QT_ANDROID_TOOLCHAIN_PREFIX ${CMAKE_MATCH_1})
        set(QT_ANDROID_TOOLCHAIN_VERSION ${CMAKE_MATCH_2})
        set(QT_ANDROID_TOOL_PREFIX ${CMAKE_MATCH_3})
    else()
        message(FATAL_ERROR "Failed to parse ANDROID_TOOLCHAIN_PREFIX to get toolchain prefix and version and tool prefix")
    endif()
endif()

## 
 # Decide AndroidManifest.xml related setting
##
set(QT_ANDROID_APP_PACKAGE_SOURCE_ROOT ${CMAKE_SOURCE_DIR}/AndroidManifest.xml)


MACRO(add_qt_android_apk TARGET)
    # create the configuration file that will feed androiddeployqt
    # 1. replace placeholder variables at generation time
    #configure_file(${CMAKE_SOURCE_DIR}/qtdeploy.json.in ${CMAKE_CURRENT_BINARY_DIR}/qtdeploy.json.in @ONLY)

    add_custom_command(
        TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo "post build: add_qt_android_apk()......"
        COMMAND ${CMAKE_COMMAND} -E remove_directory ${QT_ANDROID_APP_BINARY_DIR}/libs/${ANDROID_ABI}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${QT_ANDROID_APP_BINARY_DIR}/libs/${ANDROID_ABI}
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/${LIB_FULL_NAME} ${QT_ANDROID_APP_BINARY_DIR}/libs/${ANDROID_ABI}
        #COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/AndroidManifest.xml ${QT_ANDROID_APP_BINARY_DIR}/
        COMMAND ${QT_ANDROID_QT_ROOT}/bin/androiddeployqt
        --input ${CMAKE_SOURCE_DIR}/android.json
        --output ${QT_ANDROID_APP_BINARY_DIR}
        --android-platform android-29
        --jdk ${JAVA_HOME}
        --gradle
        #${QT_ANDROID_BUILD_TYPE}
        #--reinstall
        #--verbose
        COMMAND ${CMAKE_COMMAND} -E copy ${QT_ANDROID_APP_BINARY_DIR}/build/outputs/apk/debug/android-build-debug.apk ${CMAKE_CURRENT_BINARY_DIR}/
    )
ENDMACRO()
