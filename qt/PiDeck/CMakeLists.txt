cmake_minimum_required(VERSION 3.16)

project(PiDeck
    VERSION 0.1
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.10 REQUIRED COMPONENTS Quick Multimedia)

qt_standard_project_setup(REQUIRES 6.10)

qt_add_executable(appPiDeck
    src/main.cpp
    src/system/systemcontroller.h
    src/system/systemcontroller.cpp
    src/system/sysfs.h
    src/system/medianfilter.h
    src/system/systemmonitor.h
    src/system/systemmonitor.cpp
    src/system/systeminfo.h
    src/system/systeminfo.cpp
    src/media/musiclibrary.h
    src/media/musiclibrary.cpp
    src/network/wifinetwork.h
    src/network/nmcliparser.h
    src/network/nmcliparser.cpp
    src/network/nmcliprocess.h
    src/network/nmcliprocess.cpp
    src/network/wifibackend.h
    src/network/nmcliwifibackend.h
    src/network/nmcliwifibackend.cpp
    src/network/wifinetworkmodel.h
    src/network/wifinetworkmodel.cpp
    src/network/wificontroller.h
    src/network/wificontroller.cpp
)

set_source_files_properties(qml/Theme.qml qml/components/keyboard/Keyboard.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(appPiDeck
    URI PiDeck
    QML_FILES
        qml/Main.qml
        qml/Theme.qml
        qml/components/Icon.qml
        qml/components/NavTile.qml
        qml/components/NavigationIcon.qml
        qml/components/NavigationPanel.qml
        qml/components/SelectOverlay.qml
        qml/components/TopPanel.qml
        qml/components/keyboard/Keyboard.qml
        qml/components/keyboard/KeyboardHint.qml
        qml/components/keyboard/KeyboardSheet.qml
        qml/components/keyboard/KeyGroupTile.qml
        qml/components/keyboard/RadialKeyboard.qml
        qml/bootPage/BootLogLine.qml
        qml/bootPage/BootSplash.qml
        qml/mediaPage/MediaPage.qml
        qml/mediaPage/TrackTile.qml
        qml/gamePage/GamePage.qml
        qml/gamePage/GameTile.qml
        qml/mainPage/AppLayer.qml
        qml/mainPage/AppTile.qml
        qml/mainPage/CentreMainLayer.qml
        qml/models/AppTileModel.qml
        qml/models/BluetoothModel.qml
        qml/models/GameTileModel.qml
        qml/models/WifiModel.qml
        qml/settingsPage/BluetoothTile.qml
        qml/settingsPage/NetworkTile.qml
        qml/settingsPage/SettingRow.qml
        qml/settingsPage/SettingsPage.qml
        qml/settingsPage/SettingsSlider.qml
        qml/settingsPage/SettingsTile.qml
        qml/settingsPage/SettingsTileModel.qml
        qml/settingsPage/panels/AboutPanel.qml
        qml/settingsPage/panels/BluetoothPanel.qml
        qml/settingsPage/panels/DisplayPanel.qml
        qml/settingsPage/panels/SystemPanel.qml
        qml/settingsPage/panels/WifiPanel.qml
        qml/shutdownPage/PowerOverlay.qml
        qml/usbPage/UsbOverlay.qml
    RESOURCES
        assets/fonts/ChakraPetch-Bold.ttf
        assets/fonts/ChakraPetch-Regular.ttf
        assets/icons/about.svg
        assets/icons/app.svg
        assets/icons/back.svg
        assets/icons/batt-charg.svg
        assets/icons/batt-full.svg
        assets/icons/batt-low.svg
        assets/icons/batt-midle.svg
        assets/icons/batt-zero.svg
        assets/icons/bluetooth.svg
        assets/icons/browser.svg
        assets/icons/cpu.svg
        assets/icons/display.svg
        assets/icons/lock.svg
        assets/icons/music.svg
        assets/icons/power.svg
        assets/icons/reboot.svg
        assets/icons/right.svg
        assets/icons/settings.svg
        assets/icons/sleep.svg
        assets/icons/term.svg
        assets/icons/usb.svg
        assets/icons/wifi-full.svg
        assets/icons/wifi-low.svg
        assets/icons/wifi-midle.svg
        assets/icons/wifi-zero.svg
        assets/images/test.png
        assets/images/test2.png
)

target_link_libraries(appPiDeck
    PRIVATE
        Qt6::Quick
        Qt6::Multimedia
)

target_compile_definitions(appPiDeck
    PRIVATE PIDECK_VERSION="${PROJECT_VERSION}"
)

target_include_directories(appPiDeck
    PRIVATE
        src
        src/network
        src/system
        src/media
)

set_target_properties(appPiDeck PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

install(TARGETS appPiDeck
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
