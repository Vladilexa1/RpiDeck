#include "nmcliparser.h"

#include <QHash>

#include <algorithm>
#include <optional>

namespace {

std::optional<WifiNetwork> parseNetworkLine(const QString &line)
{
    const QStringList fields = NmcliParser::splitTerse(line);
    if (fields.size() < 4)
        return std::nullopt;

    const QString ssid = fields.at(0);
    if (ssid.isEmpty())
        return std::nullopt;

    const QString security = fields.at(1).trimmed();

    WifiNetwork net;
    net.ssid = ssid;
    // An open network leaves SECURITY empty rather than printing a placeholder.
    net.security = security.isEmpty() ? QStringLiteral("open") : security;
    net.level = fields.at(2).toInt();
    net.connected = fields.at(3) == QLatin1String("yes");

    return net;
}

} // namespace

QStringList NmcliParser::splitTerse(const QString &line)
{
    QStringList fields;
    QString current;

    for (int i = 0; i < line.size(); ++i) {
        const QChar c = line.at(i);
        // nmcli escapes ':' and '\' inside values, so a plain split(':') tears
        // apart every SSID that contains a colon.
        if (c == QLatin1Char('\\') && i + 1 < line.size()) {
            current.append(line.at(++i));
        } else if (c == QLatin1Char(':')) {
            fields.append(current);
            current.clear();
        } else {
            current.append(c);
        }
    }
    fields.append(current);

    return fields;
}

WifiNetworkList NmcliParser::parseNetworks(const QString &output)
{
    WifiNetworkList list;
    QHash<QString, int> indexBySsid;

    const QStringList lines = output.split('\n', Qt::SkipEmptyParts);
    for (const QString &line : lines) {
        const std::optional<WifiNetwork> parsed = parseNetworkLine(line);
        if (!parsed)
            continue;

        const auto known = indexBySsid.constFind(parsed->ssid);
        if (known == indexBySsid.constEnd()) {
            indexBySsid.insert(parsed->ssid, list.size());
            list.append(*parsed);
            continue;
        }

        WifiNetwork &net = list[*known];
        if (parsed->level > net.level) {
            net.level = parsed->level;
            net.security = parsed->security;
        }
        if (parsed->connected)
            net.connected = true;
    }

    std::sort(list.begin(), list.end(), [](const WifiNetwork &left, const WifiNetwork &right) {
        if (left.connected != right.connected)
            return left.connected;
        return left.level > right.level;
    });

    return list;
}

QString NmcliParser::parseWifiDevice(const QString &output)
{
    const QStringList lines = output.split('\n', Qt::SkipEmptyParts);
    for (const QString &line : lines) {
        const QStringList fields = splitTerse(line);
        if (fields.size() >= 2 && fields.at(1) == QLatin1String("wifi"))
            return fields.at(0);
    }
    return QString();
}

QString NmcliParser::parseIp4(const QString &output)
{
    // Lines look like "IP4.ADDRESS[1]:192.168.1.42/24".
    const QStringList lines = output.split('\n', Qt::SkipEmptyParts);
    for (const QString &line : lines) {
        const int separator = line.indexOf(':');
        if (separator < 0)
            continue;

        QString ip = line.mid(separator + 1).trimmed();
        const int slash = ip.indexOf('/');
        if (slash > 0)
            ip = ip.left(slash);

        if (!ip.isEmpty())
            return ip;
    }
    return QString();
}

bool NmcliParser::parseRadioState(const QString &output)
{
    return output.trimmed() == QLatin1String("enabled");
}

QString NmcliParser::humanizeError(const QString &raw)
{
    if (raw.contains(QLatin1String("Secrets were required"), Qt::CaseInsensitive)
        || raw.contains(QLatin1String("802-11-wireless-security"), Qt::CaseInsensitive))
        return QStringLiteral("Wrong or missing password");

    if (raw.contains(QLatin1String("Not authorized"), Qt::CaseInsensitive))
        return QStringLiteral("Not authorized — needs root or a polkit rule");

    if (raw.contains(QLatin1String("No network with SSID"), Qt::CaseInsensitive))
        return QStringLiteral("Network is out of range");

    QString message = raw.section('\n', 0, 0).trimmed();
    if (message.startsWith(QLatin1String("Error: ")))
        message = message.mid(7);

    return message.isEmpty() ? QStringLiteral("nmcli failed") : message;
}
