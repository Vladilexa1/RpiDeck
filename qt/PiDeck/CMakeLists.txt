cmake_minimum_required(VERSION 3.16)

project(PiDeck VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.10)

qt_add_executable(appPiDeck
    main.cpp
)

set_source_files_properties(Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(appPiDeck
    URI PiDeck
    QML_FILES
        Main.qml
        Theme.qml
        Icon.qml
        NavigationPanel.qml
        TopPanel.qml
        mainPage/AppLayer.qml
        mainPage/AppTile.qml
        models/AppTileModel.qml
        NavTile.qml
        NavigationIcon.qml
        mainPage/CentreMainLayer.qml
        settingsPage/SettingsPage.qml
        GamePage.qml
        settingsPage/SettingsTile.qml
        settingsPage/SettingsTileModel.qml
        settingsPage/panels/WifiPanel.qml
        settingsPage/panels/AboutPanel.qml
        settingsPage/panels/BluetoothPanel.qml
        settingsPage/panels/DisplayPanel.qml
        settingsPage/panels/SystemPanel.qml
        settingsPage/SettingRow.qml
        settingsPage/SettingsSlider.qml
        models/WifiModel.qml
        models/BluetoothModel.qml
        settingsPage/NetworkTile.qml
        settingsPage/BluetoothTile.qml
        shutdownPage/PowerOverlay.qml
        usbPage/UsbOverlay.qml
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
            icons/right.svg
            icons/back.svg
            icons/wifi-zero.svg
            icons/lock.svg
            icons/bluetooth.svg
            icons/display.svg
            icons/about.svg
            icons/reboot.svg
            icons/sleep.svg
            fonts/ChakraPetch-Regular.ttf
            fonts/ChakraPetch-Bold.ttf
            QML_FILES SelectOverlay.qml
            QML_FILES GameTile.qml
            QML_FILES models/GameTileModel.qml
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
