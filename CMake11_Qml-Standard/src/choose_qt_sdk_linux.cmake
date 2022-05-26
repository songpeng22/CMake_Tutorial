set( QT_LINUX 11 )
set( QT_ANDROID_ARM64_V8A 12 )

MACRO(CHOOSE_QT_SDK SDK_VERSION)
message("SDK_VERSION: " ${SDK_VERSION})
if( ${SDK_VERSION} EQUAL QT_LINUX )
    set( CMAKE_PREFIX_PATH /home/peng/qt/5.12.4/gcc_64/  )
    set( Qt5_DIR ${CMAKE_PREFIX_PATH}/lib/cmake/Qt5 )
    set( QT_QMAKE_EXECUTABLE ${CMAKE_PREFIX_PATH}/bin/qmake )
elseif( ${SDK_VERSION} EQUAL QT_ANDROID_ARM64_V8A )
    set( CMAKE_PREFIX_PATH /home/peng/qt/5.12.4/android_arm64_v8a/  )
    set( Qt5_DIR ${CMAKE_PREFIX_PATH}/lib/cmake/Qt5 )
    set( QT_QMAKE_EXECUTABLE ${CMAKE_PREFIX_PATH}/bin/qmake )
else()
    message( "!!!invalid SDK_VERSION: " ${SDK_VERSION} )
endif()
message("CMAKE_PREFIX_PATH from MACRO: " ${CMAKE_PREFIX_PATH})
ENDMACRO()

MACRO(CMAKE_QT_CONFIG)
# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)
# CMake moc automatically when needed
set(CMAKE_AUTOMOC ON)
# Create code from a list of Qt designer ui files
set(CMAKE_AUTOUIC ON)
#CMake rcc automatically( handle qrc file )
set(CMAKE_AUTORCC ON)

# Find the QtWidgets library
find_package( Qt5 REQUIRED 
# QuickWidgets means CMake would search for ".\lib\cmake\Qt5QuickWidgetsConfig.cmake"
    COMPONENTS Core Gui Widgets Qml Quick QuickWidgets QuickControls2 Network
)
ENDMACRO()


