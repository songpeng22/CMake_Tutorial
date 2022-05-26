set( QT_MSVC2013_64 1 )
set( QT_MSVC2015_32 2 )
set( QT_MSVC2015_64 3 )
set( QT_MSVC2017_32 4 )
set( QT_MSVC2017_64 5 )
set( QT_MSVC2013_32_STATIC 6 )
set( QT_MSVC2015_32_STATIC 7 )


MACRO(CHOOSE_QT_SDK SDK_VERSION)
message("SDK_VERSION: " ${SDK_VERSION})
if( ${SDK_VERSION} EQUAL QT_MSVC2013_64 )
    set( CMAKE_PREFIX_PATH C:/Qt/Qt5.10.1/5.10.1/msvc2013_64/  )
    set( Qt5_DIR ${CMAKE_PREFIX_PATH}lib/cmake/Qt5 )
    set( QT_QMAKE_EXECUTABLE ${CMAKE_PREFIX_PATH}bin/qmake.exe )
elseif( ${SDK_VERSION} EQUAL QT_MSVC2015_32 )
    set( CMAKE_PREFIX_PATH C:/Qt/Qt5.10.1/5.10.1/msvc2015/     )
    set( Qt5_DIR ${CMAKE_PREFIX_PATH}lib/cmake/Qt5 )
    set( QT_QMAKE_EXECUTABLE ${CMAKE_PREFIX_PATH}bin/qmake.exe )
elseif( ${SDK_VERSION} EQUAL QT_MSVC2015_64 )
    set( CMAKE_PREFIX_PATH C:/Qt/Qt5.10.1/5.10.1/msvc2015_64/  )
    set( Qt5_DIR ${CMAKE_PREFIX_PATH}lib/cmake/Qt5 )
    set( QT_QMAKE_EXECUTABLE ${CMAKE_PREFIX_PATH}bin/qmake.exe )
elseif( ${SDK_VERSION} EQUAL QT_MSVC2017_32 )
    set( CMAKE_PREFIX_PATH C:/Qt/Qt5.12.4_vs2017_dynamic/   )
    set( Qt5_DIR ${CMAKE_PREFIX_PATH}lib/cmake/Qt5 )
    set( QT_QMAKE_EXECUTABLE ${CMAKE_PREFIX_PATH}bin/qmake.exe )
elseif( ${SDK_VERSION} EQUAL QT_MSVC2017_64 )
    set( CMAKE_PREFIX_PATH C:/Qt/Qt5.10.1/5.10.1/msvc2017_64/   )
    set( Qt5_DIR ${CMAKE_PREFIX_PATH}lib/cmake/Qt5 )
    set( QT_QMAKE_EXECUTABLE ${CMAKE_PREFIX_PATH}bin/qmake.exe )
elseif( ${SDK_VERSION} EQUAL QT_MSVC2013_32_STATIC )
    set( CMAKE_PREFIX_PATH C:/Qt/Qt5.10.1_mt_static_vs2013/  )
    set( Qt5_DIR ${CMAKE_PREFIX_PATH}lib/cmake/Qt5 )
    set( QT_QMAKE_EXECUTABLE ${CMAKE_PREFIX_PATH}bin/qmake.exe )
elseif( ${SDK_VERSION} EQUAL QT_MSVC2015_32_STATIC )
    set( CMAKE_PREFIX_PATH C:/Qt/Qt5.10.1_mt_static_vs2015/   )
    set( Qt5_DIR ${CMAKE_PREFIX_PATH}lib/cmake/Qt5 )
    set( QT_QMAKE_EXECUTABLE ${CMAKE_PREFIX_PATH}bin/qmake.exe )
else()
    message( "!!!invalid SDK_VERSION: " ${SDK_VERSION} )
endif( ${SDK_VERSION} EQUAL QT_MSVC2013_64 )
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


