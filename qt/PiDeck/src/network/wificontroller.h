#pragma once

#include "wifibackend.h"
// Not a forward declaration: the type appears in a Q_PROPERTY, and moc refuses
// to build a meta type for a pointer to an incomplete class.
#include "wifinetworkmodel.h"

#include <QObject>
#include <QString>
#include <QtQmlIntegration/qqmlintegration.h>

class QTimer;

class WifiController : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(WifiNetworkModel *networks READ networks CONSTANT)
    Q_PROPERTY(bool radioEnabled READ radioEnabled NOTIFY radioEnabledChanged)
    Q_PROPERTY(bool connected READ connected NOTIFY connectionChanged)
    Q_PROPERTY(QString connectedSsid READ connectedSsid NOTIFY connectionChanged)
    Q_PROPERTY(int connectedLevel READ connectedLevel NOTIFY connectionChanged)
    Q_PROPERTY(bool scanning READ scanning NOTIFY scanningChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)

public:
    explicit WifiController(QObject *parent = nullptr);
    // Takes ownership of the backend; exists so tests can drive the controller
    // without nmcli or a real adapter.
    WifiController(WifiBackend *backend, QObject *parent);

    WifiNetworkModel *networks() const { return m_model; }
    bool radioEnabled() const { return m_radioEnabled; }
    bool connected() const { return !m_connectedSsid.isEmpty(); }
    QString connectedSsid() const { return m_connectedSsid; }
    int connectedLevel() const { return m_connectedLevel; }
    bool scanning() const { return m_scanning; }
    bool busy() const { return m_busy; }
    QString lastError() const { return m_lastError; }

    Q_INVOKABLE void refreshCached();
    Q_INVOKABLE void refresh();
    Q_INVOKABLE void rescan();
    Q_INVOKABLE void connectTo(const QString &ssid, const QString &password = QString());
    Q_INVOKABLE void disconnectCurrent();
    Q_INVOKABLE void setRadioEnabled(bool enabled);
    Q_INVOKABLE void refreshRadioState();

signals:
    void radioEnabledChanged();
    void connectionChanged();
    void scanningChanged();
    void busyChanged();
    void lastErrorChanged();
    void connectSucceeded(QString ssid);
    void connectFailed(QString ssid, QString error);

private:
    void connectBackend();
    void requestScan(WifiBackend::ScanMode mode);
    void updateConnection(const WifiNetworkList &networks);
    void onSucceeded(WifiBackend::Op op);
    void onFailed(WifiBackend::Op op, const QString &message);

    void setScanning(bool value);
    void setBusy(bool value);
    void setRadio(bool value);
    void setError(const QString &error);

    WifiBackend      *m_backend;
    WifiNetworkModel *m_model;
    QTimer           *m_poll;
    QString m_pendingSsid;
    QString m_connectedSsid;
    int     m_connectedLevel = 0;
    bool    m_radioEnabled = false;
    bool    m_scanning = false;
    bool    m_busy = false;
    QString m_lastError;
};
