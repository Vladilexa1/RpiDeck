#include "wificontroller.h"

#include "nmcliwifibackend.h"
#include "wifinetworkmodel.h"

#include <QDebug>
#include <QTimer>

namespace {
// The status bar shows the current network on every screen, so connection state
// has to stay fresh even when the Wi-Fi page is closed. Cached mode keeps that
// cheap: no radio activity, about 30 ms per poll.
constexpr int kConnectionPollMs = 10000;
} // namespace

WifiController::WifiController(QObject *parent)
    : WifiController(new NmcliWifiBackend, parent)
{
}

WifiController::WifiController(WifiBackend *backend, QObject *parent)
    : QObject(parent),
      m_backend(backend),
      m_model(new WifiNetworkModel(this)),
      m_poll(new QTimer(this))
{
    m_backend->setParent(this);
    connectBackend();

    m_poll->setInterval(kConnectionPollMs);
    connect(m_poll, &QTimer::timeout, this, &WifiController::refreshCached);
    m_poll->start();

    m_backend->queryRadio();
    refreshCached();
}

void WifiController::connectBackend()
{
    connect(m_backend, &WifiBackend::radioState, this, [this](bool enabled) {
        setRadio(enabled);
        if (enabled)
            return;

        m_model->clear();
        updateConnection({});
    });

    connect(m_backend, &WifiBackend::networksReady, this, [this](const WifiNetworkList &networks) {
        setScanning(false);
        setError(QString());
        m_model->merge(networks);
        updateConnection(networks);
    });

    connect(m_backend, &WifiBackend::addressReady, this,
            [this](const QString &ip) { m_model->setAddress(ip); });

    connect(m_backend, &WifiBackend::succeeded, this, &WifiController::onSucceeded);
    connect(m_backend, &WifiBackend::failed, this, &WifiController::onFailed);
}

void WifiController::refreshCached()
{
    requestScan(WifiBackend::ScanMode::Cached);
}

void WifiController::refresh()
{
    requestScan(WifiBackend::ScanMode::Auto);
}

void WifiController::rescan()
{
    requestScan(WifiBackend::ScanMode::Force);
}

void WifiController::requestScan(WifiBackend::ScanMode mode)
{
    if (m_scanning)
        return;

    setScanning(true);
    m_backend->scan(mode);
}

void WifiController::connectTo(const QString &ssid, const QString &password)
{
    if (ssid.isEmpty() || m_busy)
        return;

    m_pendingSsid = ssid;
    setBusy(true);
    m_backend->connectTo(ssid, password);
}

void WifiController::disconnectCurrent()
{
    if (m_busy)
        return;

    setBusy(true);
    m_backend->disconnectCurrent();
}

void WifiController::setRadioEnabled(bool enabled)
{
    if (m_busy)
        return;

    setBusy(true);
    m_backend->setRadio(enabled);
}

void WifiController::refreshRadioState()
{
    m_backend->queryRadio();
}

void WifiController::updateConnection(const WifiNetworkList &networks)
{
    QString ssid;
    int level = 0;

    for (const WifiNetwork &net : networks) {
        if (!net.connected)
            continue;
        ssid = net.ssid;
        level = net.level;
        break;
    }

    if (m_connectedSsid == ssid && m_connectedLevel == level)
        return;

    m_connectedSsid = ssid;
    m_connectedLevel = level;
    emit connectionChanged();
}

void WifiController::onSucceeded(WifiBackend::Op op)
{
    setBusy(false);
    setError(QString());

    switch (op) {
    case WifiBackend::Op::Connect:
        emit connectSucceeded(m_pendingSsid);
        refresh();
        break;
    case WifiBackend::Op::Disconnect:
        refresh();
        break;
    case WifiBackend::Op::Radio:
    case WifiBackend::Op::Scan:
        break;
    }
}

void WifiController::onFailed(WifiBackend::Op op, const QString &message)
{
    setError(message);

    switch (op) {
    case WifiBackend::Op::Scan:
        setScanning(false);
        break;
    case WifiBackend::Op::Connect:
        setBusy(false);
        qWarning() << "wifi connect failed:" << m_pendingSsid << message;
        emit connectFailed(m_pendingSsid, message);
        refresh();
        break;
    case WifiBackend::Op::Disconnect:
        setBusy(false);
        qWarning() << "wifi disconnect failed:" << message;
        refresh();
        break;
    case WifiBackend::Op::Radio:
        setBusy(false);
        break;
    }
}

void WifiController::setScanning(bool value)
{
    if (m_scanning == value)
        return;
    m_scanning = value;
    emit scanningChanged();
}

void WifiController::setBusy(bool value)
{
    if (m_busy == value)
        return;
    m_busy = value;
    emit busyChanged();
}

void WifiController::setRadio(bool value)
{
    if (m_radioEnabled == value)
        return;
    m_radioEnabled = value;
    emit radioEnabledChanged();
}

void WifiController::setError(const QString &error)
{
    if (m_lastError == error)
        return;
    m_lastError = error;
    emit lastErrorChanged();
}
