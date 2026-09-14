#include "network_controller.h"

#include <QDebug>
#include <QProcess>
#include <QSet>
#include <QTimer>

#include <algorithm>
#include <memory>

namespace {
constexpr int kQuickTimeoutMs   = 5000;
constexpr int kScanTimeoutMs    = 25000;
constexpr int kConnectTimeoutMs = 45000;

const QHash<int, QByteArray> kRoleNames = {
    {NetworkController::SsidRole,      QByteArrayLiteral("ssid")},
    {NetworkController::SecuredRole,   QByteArrayLiteral("secured")},
    {NetworkController::SecurityRole,  QByteArrayLiteral("security")},
    {NetworkController::LevelRole,     QByteArrayLiteral("level")},
    {NetworkController::ConnectedRole, QByteArrayLiteral("connected")},
    {NetworkController::IpRole,        QByteArrayLiteral("ip")},
};
} // namespace

NetworkController::NetworkController(QObject *parent) : QAbstractListModel(parent)
{
    refresh_radio_state();
}

// ── модель ──────────────────────────────────────────────────────────────────
int NetworkController::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_networks.size();
}

QVariant NetworkController::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_networks.size())
        return QVariant();

    const QByteArray key = kRoleNames.value(role);
    if (key.isEmpty())
        return QVariant();

    return m_networks.at(index.row()).value(QString::fromLatin1(key));
}

QHash<int, QByteArray> NetworkController::roleNames() const
{
    return kRoleNames;
}

int NetworkController::roleForKey(const QByteArray &key)
{
    return kRoleNames.key(key, -1);
}

// ── запуск nmcli ────────────────────────────────────────────────────────────
// Обрабатываем и finished, и errorOccurred: при FailedToStart (нет nmcli)
// сигнал finished не приходит вообще, и без этого ошибка теряется молча.
void NetworkController::runNmcli(const QStringList &args, int timeoutMs, Done done)
{
    auto *process = new QProcess(this);
    auto reported = std::make_shared<bool>(false);

    auto report = [process, done, reported](bool ok, const QString &out, const QString &err) {
        if (*reported)
            return;
        *reported = true;
        done(ok, out, err);
        process->deleteLater();
    };

    connect(process, &QProcess::errorOccurred, this, [process, report](QProcess::ProcessError e) {
        report(false, QString(),
               e == QProcess::FailedToStart
                   ? QStringLiteral("nmcli not found — is NetworkManager installed?")
                   : process->errorString());
    });

    connect(process, &QProcess::finished, this,
            [process, report](int exitCode, QProcess::ExitStatus status) {
                const QString out = QString::fromUtf8(process->readAllStandardOutput());
                const QString err = QString::fromUtf8(process->readAllStandardError()).trimmed();
                report(status == QProcess::NormalExit && exitCode == 0, out, err);
            });

    // nmcli умеет висеть (нет ответа от NM) — не оставляем UI в состоянии busy навсегда
    QTimer::singleShot(timeoutMs, process, [process, report]() {
        if (process->state() == QProcess::NotRunning)
            return;
        process->kill();
        report(false, QString(), QStringLiteral("nmcli timed out"));
    });

    process->start(QStringLiteral("nmcli"), args);
}

// ── Wi-Fi интерфейс ─────────────────────────────────────────────────────────
void NetworkController::queryDevice(std::function<void()> then)
{
    if (!m_iface.isEmpty()) {
        then();
        return;
    }

    runNmcli({"-t", "-f", "DEVICE,TYPE", "device", "status"}, kQuickTimeoutMs,
             [this, then](bool ok, const QString &out, const QString &err) {
                 if (ok) {
                     const QStringList lines = out.split('\n', Qt::SkipEmptyParts);
                     for (const QString &line : lines) {
                         const QStringList fields = splitTerse(line);
                         if (fields.size() >= 2 && fields.at(1) == QLatin1String("wifi")) {
                             m_iface = fields.at(0);
                             break;
                         }
                     }
                 }

                 if (m_iface.isEmpty())
                     setError(ok ? QStringLiteral("No Wi-Fi device found") : humanizeNmcliError(err));

                 then();
             });
}

// ── состояние радио ─────────────────────────────────────────────────────────
void NetworkController::refresh_radio_state()
{
    runNmcli({"-t", "radio", "wifi"}, kQuickTimeoutMs,
             [this](bool ok, const QString &out, const QString &err) {
                 if (!ok) {
                     setError(humanizeNmcliError(err));
                     return;
                 }
                 setRadioEnabled(out.trimmed() == QLatin1String("enabled"));
             });
}

void NetworkController::set_radio_enabled(bool enabled)
{
    if (m_busy)
        return;

    setBusy(true);
    runNmcli({"radio", "wifi", enabled ? "on" : "off"}, kQuickTimeoutMs,
             [this, enabled](bool ok, const QString &, const QString &err) {
                 setBusy(false);

                 if (!ok) {
                     setError(humanizeNmcliError(err));
                     refresh_radio_state(); // вернуть UI к реальному состоянию
                     return;
                 }

                 setError(QString());
                 setRadioEnabled(enabled);

                 if (enabled)
                     rescan_networks();
                 else
                     clearNetworks();
             });
}

// ── список сетей ────────────────────────────────────────────────────────────
void NetworkController::refresh_networks()
{
    requestList(Auto);
}

void NetworkController::rescan_networks()
{
    requestList(Force);
}

void NetworkController::requestList(RescanMode mode)
{
    if (m_scanning)
        return;

    setScanning(true);
    queryDevice([this, mode]() { queryList(mode); });
}

void NetworkController::queryList(RescanMode mode)
{
    QStringList args{"-t", "-f", "SSID,SECURITY,SIGNAL,ACTIVE", "device", "wifi", "list"};
    if (!m_iface.isEmpty())
        args << "ifname" << m_iface;

    switch (mode) {
    case Force:  args << "--rescan" << "yes";  break;
    case Cached: args << "--rescan" << "no";   break;
    case Auto:   args << "--rescan" << "auto"; break;
    }

    runNmcli(args, kScanTimeoutMs, [this](bool ok, const QString &out, const QString &err) {
        setScanning(false);

        if (!ok) {
            setError(humanizeNmcliError(err));
            return;
        }

        setError(QString());
        applyScan(parseNmcliOutput(out));
        queryIp();
    });
}

QVector<QVariantMap> NetworkController::parseNmcliOutput(const QString &output)
{
    QVector<QVariantMap> list;
    QHash<QString, int> indexBySsid; // одна сеть на 2.4/5 ГГц даёт несколько строк

    const QStringList lines = output.split('\n', Qt::SkipEmptyParts);
    for (const QString &line : lines) {
        const QStringList fields = splitTerse(line);
        if (fields.size() < 4)
            continue;

        const QString ssid = fields.at(0);
        if (ssid.isEmpty())
            continue; // скрытая сеть — показывать нечего

        const QString security = fields.at(1).trimmed(); // у открытых сетей поле пустое
        const int level = fields.at(2).toInt();
        const bool active = fields.at(3) == QLatin1String("yes");

        const auto known = indexBySsid.constFind(ssid);
        if (known != indexBySsid.constEnd()) {
            QVariantMap &net = list[*known];
            if (level > net.value(QStringLiteral("level")).toInt()) {
                net[QStringLiteral("level")] = level;
                net[QStringLiteral("secured")] = !security.isEmpty();
                net[QStringLiteral("security")] =
                    security.isEmpty() ? QStringLiteral("open") : security;
            }
            if (active)
                net[QStringLiteral("connected")] = true;
            continue;
        }

        QVariantMap net;
        net[QStringLiteral("ssid")] = ssid;
        net[QStringLiteral("secured")] = !security.isEmpty();
        net[QStringLiteral("security")] = security.isEmpty() ? QStringLiteral("open") : security;
        net[QStringLiteral("level")] = level;
        net[QStringLiteral("connected")] = active;
        // ip приходит отдельным запросом, здесь его нет намеренно:
        // иначе слияние затирало бы уже известный адрес пустой строкой

        indexBySsid.insert(ssid, list.size());
        list.append(net);
    }

    // порядок применяется только при первом заполнении (см. applyScan)
    std::sort(list.begin(), list.end(), [](const QVariantMap &left, const QVariantMap &right) {
        const bool lc = left.value(QStringLiteral("connected")).toBool();
        const bool rc = right.value(QStringLiteral("connected")).toBool();
        if (lc != rc)
            return lc;
        return left.value(QStringLiteral("level")).toInt()
               > right.value(QStringLiteral("level")).toInt();
    });

    return list;
}

void NetworkController::applyScan(const QVector<QVariantMap> &scanned)
{
    // Первое заполнение: единственный момент, когда список выстраивается по сигналу.
    // Дальше порядок фиксирован, иначе строки ездят под курсором при каждом скане.
    if (m_networks.isEmpty()) {
        if (scanned.isEmpty())
            return;

        beginInsertRows(QModelIndex(), 0, scanned.size() - 1);
        m_networks = scanned;
        for (QVariantMap &net : m_networks)
            net[QStringLiteral("ip")] = QString();
        endInsertRows();
        return;
    }

    QSet<QString> present;
    for (const QVariantMap &net : scanned)
        present.insert(net.value(QStringLiteral("ssid")).toString());

    // исчезнувшие сети
    for (int row = m_networks.size() - 1; row >= 0; --row) {
        if (present.contains(m_networks.at(row).value(QStringLiteral("ssid")).toString()))
            continue;

        beginRemoveRows(QModelIndex(), row, row);
        m_networks.removeAt(row);
        endRemoveRows();
    }

    QHash<QString, int> rowBySsid;
    for (int row = 0; row < m_networks.size(); ++row)
        rowBySsid.insert(m_networks.at(row).value(QStringLiteral("ssid")).toString(), row);

    for (const QVariantMap &net : scanned) {
        const QString ssid = net.value(QStringLiteral("ssid")).toString();
        const auto known = rowBySsid.constFind(ssid);

        if (known == rowBySsid.constEnd()) {
            const int row = m_networks.size(); // новые сети — в конец, порядок не ломаем
            beginInsertRows(QModelIndex(), row, row);
            QVariantMap fresh = net;
            fresh[QStringLiteral("ip")] = QString();
            m_networks.append(fresh);
            endInsertRows();
            rowBySsid.insert(ssid, row);
            continue;
        }

        const int row = *known;
        QVariantMap &current = m_networks[row];
        QVector<int> changedRoles;

        for (auto field = net.cbegin(); field != net.cend(); ++field) {
            if (current.value(field.key()) == field.value())
                continue;
            current[field.key()] = field.value();
            const int role = roleForKey(field.key().toLatin1());
            if (role != -1)
                changedRoles.append(role);
        }

        // отключились — адрес больше не наш
        if (!current.value(QStringLiteral("connected")).toBool()
            && !current.value(QStringLiteral("ip")).toString().isEmpty()) {
            current[QStringLiteral("ip")] = QString();
            changedRoles.append(IpRole);
        }

        if (!changedRoles.isEmpty())
            emit dataChanged(index(row, 0), index(row, 0), changedRoles);
    }
}

void NetworkController::clearNetworks()
{
    if (m_networks.isEmpty())
        return;

    beginResetModel();
    m_networks.clear();
    endResetModel();
}

void NetworkController::queryIp()
{
    if (m_iface.isEmpty())
        return;

    const bool anyConnected =
        std::any_of(m_networks.cbegin(), m_networks.cend(), [](const QVariantMap &net) {
            return net.value(QStringLiteral("connected")).toBool();
        });
    if (!anyConnected)
        return;

    runNmcli({"-t", "-f", "IP4.ADDRESS", "device", "show", m_iface}, kQuickTimeoutMs,
             [this](bool ok, const QString &out, const QString &) {
                 if (!ok)
                     return;

                 // строки вида "IP4.ADDRESS[1]:192.168.1.42/24"
                 QString ip;
                 const QStringList lines = out.split('\n', Qt::SkipEmptyParts);
                 for (const QString &line : lines) {
                     const int sep = line.indexOf(':');
                     if (sep < 0)
                         continue;
                     ip = line.mid(sep + 1).trimmed();
                     const int slash = ip.indexOf('/');
                     if (slash > 0)
                         ip = ip.left(slash);
                     if (!ip.isEmpty())
                         break;
                 }
                 if (ip.isEmpty())
                     return;

                 for (int row = 0; row < m_networks.size(); ++row) {
                     QVariantMap &net = m_networks[row];
                     if (!net.value(QStringLiteral("connected")).toBool()
                         || net.value(QStringLiteral("ip")).toString() == ip)
                         continue;

                     net[QStringLiteral("ip")] = ip;
                     emit dataChanged(index(row, 0), index(row, 0), {IpRole});
                 }
             });
}

// ── подключение / отключение ────────────────────────────────────────────────
void NetworkController::connect_to_wifi(const QString &ssid, const QString &password)
{
    if (ssid.isEmpty() || m_busy)
        return;

    setBusy(true);
    queryDevice([this, ssid, password]() {
        QStringList args{"-w", "30", "device", "wifi", "connect", ssid};
        if (!password.isEmpty())
            args << "password" << password;
        if (!m_iface.isEmpty())
            args << "ifname" << m_iface;

        runNmcli(args, kConnectTimeoutMs,
                 [this, ssid](bool ok, const QString &, const QString &err) {
                     setBusy(false);

                     if (ok) {
                         setError(QString());
                         emit connectSucceeded(ssid);
                     } else {
                         const QString message = humanizeNmcliError(err);
                         qWarning() << "wifi connect failed:" << ssid << err;
                         setError(message);
                         emit connectFailed(ssid, message);
                     }

                     requestList(Cached); // обновить статус connected
                 });
    });
}

void NetworkController::disconnect_wifi(const QString &ssid)
{
    if (m_busy)
        return;

    setBusy(true);
    queryDevice([this, ssid]() {
        if (m_iface.isEmpty()) {
            setBusy(false);
            setError(QStringLiteral("No Wi-Fi device found"));
            return;
        }

        // отключаемся по устройству: имя профиля не обязано совпадать с SSID
        runNmcli({"-w", "15", "device", "disconnect", m_iface}, kConnectTimeoutMs,
                 [this, ssid](bool ok, const QString &, const QString &err) {
                     setBusy(false);

                     if (ok) {
                         setError(QString());
                     } else {
                         qWarning() << "wifi disconnect failed:" << ssid << err;
                         setError(humanizeNmcliError(err));
                     }

                     requestList(Cached);
                 });
    });
}

// ── состояние ───────────────────────────────────────────────────────────────
void NetworkController::setScanning(bool value)
{
    if (m_scanning == value)
        return;
    m_scanning = value;
    emit scanningChanged();
}

void NetworkController::setBusy(bool value)
{
    if (m_busy == value)
        return;
    m_busy = value;
    emit busyChanged();
}

void NetworkController::setRadioEnabled(bool value)
{
    if (m_radioEnabled == value)
        return;
    m_radioEnabled = value;
    emit radioEnabledChanged();
}

void NetworkController::setError(const QString &error)
{
    if (m_lastError == error)
        return;
    m_lastError = error;
    emit lastErrorChanged();
}

// ── парсинг ─────────────────────────────────────────────────────────────────
QStringList NetworkController::splitTerse(const QString &line)
{
    QStringList fields;
    QString current;

    for (int i = 0; i < line.size(); ++i) {
        const QChar c = line.at(i);
        if (c == QLatin1Char('\\') && i + 1 < line.size()) {
            current.append(line.at(++i)); // экранированные ':' и '\' внутри SSID
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

QString NetworkController::humanizeNmcliError(const QString &raw)
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
