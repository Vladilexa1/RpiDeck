#pragma once

#include "wifinetwork.h"

#include <QObject>
#include <QString>

// Keeps the system-specific half replaceable: nmcli today, NetworkManager over
// D-Bus later, a fake in tests — none of which the controller or the UI sees.
class WifiBackend : public QObject
{
    Q_OBJECT

public:
    enum class Op { Radio, Scan, Connect, Disconnect };
    Q_ENUM(Op)

    // Cached returns what the system already knows and never touches the radio;
    // Force drives a real scan, which costs about seven seconds and a latency
    // spike on a single-radio adapter.
    enum class ScanMode { Cached, Auto, Force };
    Q_ENUM(ScanMode)

    using QObject::QObject;

    virtual void queryRadio() = 0;
    virtual void setRadio(bool enabled) = 0;
    virtual void scan(ScanMode mode) = 0;
    virtual void connectTo(const QString &ssid, const QString &password) = 0;
    virtual void disconnectCurrent() = 0;

signals:
    void radioState(bool enabled);
    void networksReady(const WifiNetworkList &networks);
    void addressReady(const QString &ip);
    void succeeded(WifiBackend::Op op);
    void failed(WifiBackend::Op op, const QString &message);
};
