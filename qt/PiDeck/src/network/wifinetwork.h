#pragma once

#include <QList>
#include <QMetaType>
#include <QString>

struct WifiNetwork
{
    QString ssid;
    QString security;        // "open", or a list such as "WPA2 WPA3"
    int     level = 0;       // 0..100
    bool    connected = false;
    // Comes from a separate query, so it is always empty in scan results and
    // must never overwrite an address the model already knows.
    QString ip;

    bool secured() const { return security != QLatin1String("open"); }
};

Q_DECLARE_METATYPE(WifiNetwork)

using WifiNetworkList = QList<WifiNetwork>;
