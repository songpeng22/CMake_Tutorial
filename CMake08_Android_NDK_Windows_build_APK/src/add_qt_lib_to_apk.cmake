CMAKE_MINIMUM_REQUIRED(VERSION 3.2 FATAL_ERROR)

macro(add_qt_android_apk LIB_NAME APK_NAME)

    # parse the macro arguments
    cmake_parse_arguments(ARG "INSTALL" "NAME;VERSION_CODE;PACKAGE_NAME;PACKAGE_SOURCES;KEYSTORE_PASSWORD" "DEPENDS;KEYSTORE;APK_BUILD_TYPE" ${ARGN})

    ## 
    # Decide PATHs and DEFINEs
    ##
    set(LIB_FULL_NAME lib${LIB_NAME}.so)
    set(APK_FULL_NAME ${APK_NAME}.apk)
    set(QT_ANDROID_APP_NAME ${APK_NAME})
    set(PACKAGE_NAME com.example.${APK_NAME})
    set(QT_ANDROID_APP_PACKAGE_NAME com.example.${LIB_NAME})
    # debug or release
    set(QT_ANDROID_BUILD_TYPE --debug)

    # ${CMAKE_CURRENT_BINARY_DIR}/android-build
    set(QT_ANDROID_APP_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/android-build)
    # ${CMAKE_CURRENT_BINARY_DIR}/android-build/libs/arm64-v8a
    file(MAKE_DIRECTORY ${QT_ANDROID_APP_BINARY_DIR}/libs/${ANDROID_ABI})
    # ${CMAKE_CURRENT_BINARY_DIR}/libqtTest.so
    set(QT_ANDROID_APP_PATH ${CMAKE_CURRENT_BINARY_DIR}/${LIB_FULL_NAME})
    set(QT_ANDROID_APPLICATION_BINARY ${QT_ANDROID_APP_PATH})
    
    # STL/STD C++ library
    set(ANDROID_STL_PREFIX llvm-libc++)
    set(QT_ANDROID_STL_PATH "${QT_ANDROID_NDK_ROOT}/sources/cxx-stl/${ANDROID_STL_PREFIX}/libs/${ANDROID_ABI}/libc++_shared.so")

    
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

    # create the configuration file that will feed androiddeployqt
    # 1. replace placeholder variables at generation time
    configure_file(${CMAKE_SOURCE_DIR}/qtdeploy.json.in ${CMAKE_CURRENT_BINARY_DIR}/qtdeploy.json.in @ONLY)
    # 2. evaluate generator expressions at build time
    file(GENERATE
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/qtdeploy.json
        INPUT ${CMAKE_CURRENT_BINARY_DIR}/qtdeploy.json.in
    )

    ## 
    # Decide AndroidManifest.xml related setting
    ##
    set(QT_ANDROID_APP_PACKAGE_SOURCE_ROOT ${CMAKE_SOURCE_DIR}/AndroidManifest.xml)




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
        TARGET ${LIB_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo "post build: add_qt_android_apk()......"
        COMMAND ${CMAKE_COMMAND} -E remove_directory ${QT_ANDROID_APP_BINARY_DIR}/libs/${ANDROID_ABI}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${QT_ANDROID_APP_BINARY_DIR}/libs/${ANDROID_ABI}
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/${LIB_FULL_NAME} ${QT_ANDROID_APP_BINARY_DIR}/libs/${ANDROID_ABI}
        #COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/AndroidManifest.xml ${QT_ANDROID_APP_BINARY_DIR}/
        COMMAND ${QT_ANDROID_QT_ROOT}/bin/androiddeployqt
        #--input ${CMAKE_SOURCE_DIR}/android.json
        --input ${CMAKE_CURRENT_BINARY_DIR}/qtdeploy.json
        --output ${QT_ANDROID_APP_BINARY_DIR}
        --android-platform android-29
        --jdk ${JAVA_HOME}
        --gradle
        #${QT_ANDROID_BUILD_TYPE}
        #--reinstall
        #--verbose
        COMMAND ${CMAKE_COMMAND} -E copy ${QT_ANDROID_APP_BINARY_DIR}/build/outputs/apk/debug/android-build-debug.apk ${CMAKE_CURRENT_BINARY_DIR}/
    )
endmacro()
