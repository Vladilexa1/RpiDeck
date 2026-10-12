#pragma once

#include "wifinetwork.h"

#include <QAbstractListModel>
#include <QtQmlIntegration/qqmlintegration.h>

class WifiNetworkModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Owned by WifiController, reach it through WifiController.networks")

public:
    enum Role {
        SsidRole = Qt::UserRole + 1,
        SecuredRole,
        SecurityRole,
        LevelRole,
        ConnectedRole,
        IpRole,
    };
    Q_ENUM(Role)

    explicit WifiNetworkModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Updates rows in place and keeps their order, so the ListView cursor stays
    // on the network the user selected instead of snapping back to the top.
    void merge(const WifiNetworkList &scanned);
    void setAddress(const QString &ip);
    void clear();

private:
    void removeMissing(const WifiNetworkList &scanned);
    void append(const WifiNetwork &network);
    void updateRow(int row, const WifiNetwork &scanned);

    WifiNetworkList m_networks;
};
