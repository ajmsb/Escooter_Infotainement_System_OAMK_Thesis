cmake_minimum_required(VERSION 3.14)

project(Escooter_Infotainement_System_OAMK_Thesis VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Quick Widgets Location Positioning Multimedia Charts)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Quick Widgets Location Positioning Multimedia Charts)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    find_package(Qt6 REQUIRED COMPONENTS Core5Compat)
endif()

set(PROJECT_SOURCES
        main.cpp
        dashboarddata.h
        dashboarddata.cpp
        datasimulator.h
        datasimulator.cpp
        routesimulator.h
        routesimulator.cpp
        qml.qrc
)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(Escooter_Infotainement_System_OAMK_Thesis
        MANUAL_FINALIZATION
        ${PROJECT_SOURCES}
    )
# Define target properties for Android with Qt 6 as:
#    set_property(TARGET Escooter_Infotainement_System_OAMK_Thesis APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
#                 ${CMAKE_CURRENT_SOURCE_DIR}/android)
# For more information, see https://doc.qt.io/qt-6/qt-add-executable.html#target-creation
else()
    if(ANDROID)
        add_library(Escooter_Infotainement_System_OAMK_Thesis SHARED
            ${PROJECT_SOURCES}
        )
# Define properties for Android with Qt 5 after find_package() calls as:
#    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
    else()
        add_executable(Escooter_Infotainement_System_OAMK_Thesis
          ${PROJECT_SOURCES}
        )
    endif()
endif()

target_link_libraries(Escooter_Infotainement_System_OAMK_Thesis
    PRIVATE
        Qt${QT_VERSION_MAJOR}::Core
        Qt${QT_VERSION_MAJOR}::Quick
        Qt${QT_VERSION_MAJOR}::Widgets
        Qt${QT_VERSION_MAJOR}::Location
        Qt${QT_VERSION_MAJOR}::Positioning
        Qt${QT_VERSION_MAJOR}::Multimedia
        Qt${QT_VERSION_MAJOR}::Charts)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    target_link_libraries(Escooter_Infotainement_System_OAMK_Thesis PRIVATE Qt6::Core5Compat)
endif()

# Pass the source directory to C++ so the media scanner can find assets/media/
target_compile_definitions(Escooter_Infotainement_System_OAMK_Thesis PRIVATE
    SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}"
)

set_target_properties(Escooter_Infotainement_System_OAMK_Thesis PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

install(TARGETS Escooter_Infotainement_System_OAMK_Thesis
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

if(QT_VERSION_MAJOR EQUAL 6)
    qt_import_qml_plugins(Escooter_Infotainement_System_OAMK_Thesis)
    qt_finalize_executable(Escooter_Infotainement_System_OAMK_Thesis)
endif()
