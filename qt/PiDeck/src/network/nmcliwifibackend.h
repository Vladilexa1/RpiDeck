#pragma once

#include "wifibackend.h"

#include <QString>

#include <functional>

class NmcliProcess;

// Every nmcli specific — argument names, --rescan, the interface name, timeouts
// — is confined to this class.
class NmcliWifiBackend : public WifiBackend
{
    Q_OBJECT

public:
    explicit NmcliWifiBackend(QObject *parent = nullptr);

    void queryRadio() override;
    void setRadio(bool enabled) override;
    void scan(ScanMode mode) override;
    void connectTo(const QString &ssid, const QString &password) override;
    void disconnectCurrent() override;

private:
    void withDevice(std::function<void()> then);
    void requestList(ScanMode mode);
    void requestAddress();

    NmcliProcess *m_nmcli;
    QString m_iface;
};
