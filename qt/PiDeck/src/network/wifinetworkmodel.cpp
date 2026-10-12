#include "wifinetworkmodel.h"

#include <QSet>

WifiNetworkModel::WifiNetworkModel(QObject *parent) : QAbstractListModel(parent) {}

int WifiNetworkModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_networks.size();
}

QVariant WifiNetworkModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_networks.size())
        return QVariant();

    const WifiNetwork &net = m_networks.at(index.row());
    switch (role) {
    case SsidRole:      return net.ssid;
    case SecuredRole:   return net.secured();
    case SecurityRole:  return net.security;
    case LevelRole:     return net.level;
    case ConnectedRole: return net.connected;
    case IpRole:        return net.ip;
    default:            return QVariant();
    }
}

QHash<int, QByteArray> WifiNetworkModel::roleNames() const
{
    return {
        {SsidRole,      QByteArrayLiteral("ssid")},
        {SecuredRole,   QByteArrayLiteral("secured")},
        {SecurityRole,  QByteArrayLiteral("security")},
        {LevelRole,     QByteArrayLiteral("level")},
        {ConnectedRole, QByteArrayLiteral("connected")},
        {IpRole,        QByteArrayLiteral("ip")},
    };
}

void WifiNetworkModel::merge(const WifiNetworkList &scanned)
{
    // The only moment the list is ordered by signal. Re-sorting on every scan
    // would make rows swap places under the cursor, because signal readings
    // wobble by a few percent between scans.
    if (m_networks.isEmpty()) {
        if (scanned.isEmpty())
            return;

        beginInsertRows(QModelIndex(), 0, scanned.size() - 1);
        m_networks = scanned;
        endInsertRows();
        return;
    }

    removeMissing(scanned);

    QHash<QString, int> rowBySsid;
    for (int row = 0; row < m_networks.size(); ++row)
        rowBySsid.insert(m_networks.at(row).ssid, row);

    for (const WifiNetwork &scan : scanned) {
        const auto known = rowBySsid.constFind(scan.ssid);
        if (known == rowBySsid.constEnd()) {
            rowBySsid.insert(scan.ssid, m_networks.size());
            append(scan);
        } else {
            updateRow(*known, scan);
        }
    }
}

void WifiNetworkModel::removeMissing(const WifiNetworkList &scanned)
{
    QSet<QString> present;
    present.reserve(scanned.size());
    for (const WifiNetwork &net : scanned)
        present.insert(net.ssid);

    for (int row = m_networks.size() - 1; row >= 0; --row) {
        if (present.contains(m_networks.at(row).ssid))
            continue;

        beginRemoveRows(QModelIndex(), row, row);
        m_networks.removeAt(row);
        endRemoveRows();
    }
}

void WifiNetworkModel::append(const WifiNetwork &network)
{
    const int row = m_networks.size(); // appended, so existing rows keep their index
    beginInsertRows(QModelIndex(), row, row);
    m_networks.append(network);
    endInsertRows();
}

void WifiNetworkModel::updateRow(int row, const WifiNetwork &scanned)
{
    WifiNetwork &current = m_networks[row];
    QList<int> changedRoles;

    if (current.security != scanned.security) {
        current.security = scanned.security;
        changedRoles << SecurityRole << SecuredRole;
    }
    if (current.level != scanned.level) {
        current.level = scanned.level;
        changedRoles << LevelRole;
    }
    if (current.connected != scanned.connected) {
        current.connected = scanned.connected;
        changedRoles << ConnectedRole;

        if (!current.connected && !current.ip.isEmpty()) {
            current.ip.clear();
            changedRoles << IpRole;
        }
    }

    if (!changedRoles.isEmpty())
        emit dataChanged(index(row), index(row), changedRoles);
}

void WifiNetworkModel::setAddress(const QString &ip)
{
    for (int row = 0; row < m_networks.size(); ++row) {
        WifiNetwork &net = m_networks[row];
        const QString wanted = net.connected ? ip : QString();
        if (net.ip == wanted)
            continue;

        net.ip = wanted;
        emit dataChanged(index(row), index(row), {IpRole});
    }
}

void WifiNetworkModel::clear()
{
    if (m_networks.isEmpty())
        return;

    beginResetModel();
    m_networks.clear();
    endResetModel();
}
