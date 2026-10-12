#include "nmcliwifibackend.h"

#include "nmcliparser.h"
#include "nmcliprocess.h"

namespace {
constexpr int kQuickTimeoutMs   = 5000;
constexpr int kScanTimeoutMs    = 25000;
constexpr int kConnectTimeoutMs = 45000;
} // namespace

NmcliWifiBackend::NmcliWifiBackend(QObject *parent)
    : WifiBackend(parent), m_nmcli(new NmcliProcess(this))
{
}

void NmcliWifiBackend::queryRadio()
{
    m_nmcli->run({"-t", "radio", "wifi"}, kQuickTimeoutMs,
                 [this](const NmcliProcess::Result &result) {
                     if (!result.ok) {
                         emit failed(Op::Radio, NmcliParser::humanizeError(result.err));
                         return;
                     }
                     emit radioState(NmcliParser::parseRadioState(result.out));
                 });
}

void NmcliWifiBackend::setRadio(bool enabled)
{
    m_nmcli->run({"radio", "wifi", enabled ? "on" : "off"}, kQuickTimeoutMs,
                 [this, enabled](const NmcliProcess::Result &result) {
                     if (!result.ok) {
                         emit failed(Op::Radio, NmcliParser::humanizeError(result.err));
                         queryRadio(); // the toggle in the UI must not lie about the real state
                         return;
                     }
                     emit radioState(enabled);
                     emit succeeded(Op::Radio);
                 });
}

void NmcliWifiBackend::scan(ScanMode mode)
{
    withDevice([this, mode]() { requestList(mode); });
}

void NmcliWifiBackend::connectTo(const QString &ssid, const QString &password)
{
    withDevice([this, ssid, password]() {
        QStringList args{"-w", "30", "device", "wifi", "connect", ssid};
        if (!password.isEmpty())
            args << "password" << password;
        if (!m_iface.isEmpty())
            args << "ifname" << m_iface;

        m_nmcli->run(args, kConnectTimeoutMs, [this](const NmcliProcess::Result &result) {
            if (result.ok)
                emit succeeded(Op::Connect);
            else
                emit failed(Op::Connect, NmcliParser::humanizeError(result.err));
        });
    });
}

void NmcliWifiBackend::disconnectCurrent()
{
    withDevice([this]() {
        if (m_iface.isEmpty()) {
            emit failed(Op::Disconnect, QStringLiteral("No Wi-Fi device found"));
            return;
        }

        // Disconnecting by device rather than by profile name: the connection
        // profile is not required to be named after the SSID.
        m_nmcli->run({"-w", "15", "device", "disconnect", m_iface}, kConnectTimeoutMs,
                     [this](const NmcliProcess::Result &result) {
                         if (result.ok)
                             emit succeeded(Op::Disconnect);
                         else
                             emit failed(Op::Disconnect, NmcliParser::humanizeError(result.err));
                     });
    });
}

void NmcliWifiBackend::withDevice(std::function<void()> then)
{
    if (!m_iface.isEmpty()) {
        then();
        return;
    }

    m_nmcli->run({"-t", "-f", "DEVICE,TYPE", "device", "status"}, kQuickTimeoutMs,
                 [this, then](const NmcliProcess::Result &result) {
                     if (result.ok)
                         m_iface = NmcliParser::parseWifiDevice(result.out);

                     if (m_iface.isEmpty())
                         emit failed(Op::Scan, result.ok
                                                   ? QStringLiteral("No Wi-Fi device found")
                                                   : NmcliParser::humanizeError(result.err));
                     then();
                 });
}

void NmcliWifiBackend::requestList(ScanMode mode)
{
    QStringList args{"-t", "-f", "SSID,SECURITY,SIGNAL,ACTIVE", "device", "wifi", "list"};
    if (!m_iface.isEmpty())
        args << "ifname" << m_iface;

    switch (mode) {
    case ScanMode::Cached: args << "--rescan" << "no";   break;
    case ScanMode::Auto:   args << "--rescan" << "auto"; break;
    case ScanMode::Force:  args << "--rescan" << "yes";  break;
    }

    m_nmcli->run(args, kScanTimeoutMs, [this](const NmcliProcess::Result &result) {
        if (!result.ok) {
            emit failed(Op::Scan, NmcliParser::humanizeError(result.err));
            return;
        }

        emit networksReady(NmcliParser::parseNetworks(result.out));
        requestAddress();
    });
}

void NmcliWifiBackend::requestAddress()
{
    if (m_iface.isEmpty())
        return;

    m_nmcli->run({"-t", "-f", "IP4.ADDRESS", "device", "show", m_iface}, kQuickTimeoutMs,
                 [this](const NmcliProcess::Result &result) {
                     if (result.ok)
                         emit addressReady(NmcliParser::parseIp4(result.out));
                 });
}
