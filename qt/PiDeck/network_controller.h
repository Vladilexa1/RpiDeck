#pragma once

#include <QAbstractListModel>
#include <QByteArray>
#include <QHash>
#include <QString>
#include <QStringList>
#include <QVariantMap>
#include <QVector>
#include <QtQml>

#include <functional>

class NetworkController : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool radioEnabled READ radioEnabled NOTIFY radioEnabledChanged)
    Q_PROPERTY(bool scanning READ scanning NOTIFY scanningChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)

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

    explicit NetworkController(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    bool radioEnabled() const { return m_radioEnabled; }
    bool scanning() const { return m_scanning; }
    bool busy() const { return m_busy; }
    QString lastError() const { return m_lastError; }

    Q_INVOKABLE void refresh_networks();
    Q_INVOKABLE void rescan_networks();
    Q_INVOKABLE void connect_to_wifi(const QString &ssid, const QString &password = QString());
    Q_INVOKABLE void disconnect_wifi(const QString &ssid = QString());
    Q_INVOKABLE void set_radio_enabled(bool enabled);
    Q_INVOKABLE void refresh_radio_state();

signals:
    void radioEnabledChanged();
    void scanningChanged();
    void busyChanged();
    void lastErrorChanged();
    void connectSucceeded(QString ssid);
    void connectFailed(QString ssid, QString error);

private:
    enum RescanMode { Auto, Force, Cached };

    using Done = std::function<void(bool ok, const QString &out, const QString &err)>;

    void runNmcli(const QStringList &args, int timeoutMs, Done done);
    void queryDevice(std::function<void()> then);
    void queryList(RescanMode mode);
    void queryIp();
    void requestList(RescanMode mode);

    static QVector<QVariantMap> parseNmcliOutput(const QString &output);
    void applyScan(const QVector<QVariantMap> &scanned);
    void clearNetworks();

    void setScanning(bool value);
    void setBusy(bool value);
    void setRadioEnabled(bool value);
    void setError(const QString &error);

    static QStringList splitTerse(const QString &line);
    static QString humanizeNmcliError(const QString &raw);
    static int roleForKey(const QByteArray &key);

    QVector<QVariantMap> m_networks;
    QString m_iface;
    bool m_radioEnabled = false;
    bool m_scanning = false;
    bool m_busy = false;
    QString m_lastError;
};
