import QtQuick

ListModel {
    ListElement { ssid: "home-5G";       secured: true;  level: 95; connected: true;  security: "WPA2"; ip: "192.168.0.42" }
    ListElement { ssid: "home-2.4G";     secured: true;  level: 78; connected: false; security: "WPA2"; ip: "" }
    ListElement { ssid: "Pixel_Hotspot"; secured: true;  level: 60; connected: false; security: "WPA2"; ip: "" }
    ListElement { ssid: "CAFE-GUEST";    secured: false; level: 45; connected: false; security: "open"; ip: "" }
    ListElement { ssid: "TP-LINK_4F2A";  secured: true;  level: 22; connected: false; security: "WPA2"; ip: "" }
}