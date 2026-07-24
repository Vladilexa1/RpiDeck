cmake_minimum_required(VERSION 3.16)

project(PiDeck VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.10)

qt_add_executable(appPiDeck
    main.cpp
)

qt_add_qml_module(appPiDeck
    URI PiDeck
    QML_FILES
        Main.qml
        NavigationPanel.qml
        TopPanel.qml
        AppLayer.qml
        AppTile.qml
        AppTileModel.qml
        NavTile.qml
        NavigationIcon.qml
        CentreMainLayer.qml

        RESOURCES
            icons/power.svg
            icons/app.svg
            icons/usb.svg
            icons/browser.svg
            icons/music.svg
            icons/settings.svg
            icons/term.svg
            icons/cpu.svg
            icons/batt-full.svg
            icons/batt-midle.svg
            icons/batt-low.svg
            icons/batt-charg.svg
            icons/wifi-full.svg
            icons/wifi-midle.svg
            icons/wifi-low.svg
            icons/wifi-zero.svg
            fonts/ChakraPetch-Regular.ttf
            fonts/ChakraPetch-Bold.ttf
            QML_FILES SettingsPage.qml
            QML_FILES GamePage.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appPiDeck PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appPiDeck
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appPiDeck
    PRIVATE Qt6::Quick
)

install(TARGETS appPiDeck
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
