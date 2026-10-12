#pragma once

#include "wifinetwork.h"

#include <QString>
#include <QStringList>

// Pure functions over nmcli terse (-t) output: no process, no state, no QObject,
// which is what makes the fragile part of the nmcli integration testable.
namespace NmcliParser {

QStringList splitTerse(const QString &line);

// Duplicate SSIDs (2.4/5 GHz, several access points) collapse into the entry
// with the strongest signal; the result is ordered connected-first, then by
// signal. Unnamed (hidden) networks are dropped: there is nothing to show.
WifiNetworkList parseNetworks(const QString &output);

QString parseWifiDevice(const QString &output);
QString parseIp4(const QString &output);
bool parseRadioState(const QString &output);

// nmcli error text condensed into something a status line can show.
QString humanizeError(const QString &raw);

} // namespace NmcliParser
