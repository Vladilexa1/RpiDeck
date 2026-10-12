#pragma once

#include <QObject>
#include <QString>
#include <QtQmlIntegration/qqmlintegration.h>

class QTimer;

// Machine identity plus the stats that move on the scale of minutes. Sensors
// that need sub-second sampling live in SystemMonitor instead.
class SystemInfo : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QString hostname READ hostname CONSTANT)
    Q_PROPERTY(QString model READ model CONSTANT)
    Q_PROPERTY(QString os READ os CONSTANT)
    Q_PROPERTY(QString kernel READ kernel CONSTANT)
    Q_PROPERTY(QString serial READ serial CONSTANT)
    Q_PROPERTY(QString appVersion READ appVersion CONSTANT)
    Q_PROPERTY(QString builtWith READ builtWith CONSTANT)
    Q_PROPERTY(int memoryTotalGb READ memoryTotalGb CONSTANT)

    Q_PROPERTY(QString uptime READ uptime NOTIFY statsChanged)
    Q_PROPERTY(int memoryUsedGb READ memoryUsedGb NOTIFY statsChanged)
    Q_PROPERTY(int memoryUsedPercent READ memoryUsedPercent NOTIFY statsChanged)
    Q_PROPERTY(int storageUsedGb READ storageUsedGb NOTIFY statsChanged)
    Q_PROPERTY(int storageTotalGb READ storageTotalGb NOTIFY statsChanged)
    Q_PROPERTY(int storageUsedPercent READ storageUsedPercent NOTIFY statsChanged)

public:
    explicit SystemInfo(QObject *parent = nullptr);

    QString hostname() const { return m_hostname; }
    QString model() const { return m_model; }
    QString os() const { return m_os; }
    QString kernel() const { return m_kernel; }
    QString serial() const { return m_serial; }
    QString appVersion() const;
    QString builtWith() const;
    int memoryTotalGb() const { return m_memoryTotalGb; }

    QString uptime() const { return m_uptime; }
    int memoryUsedGb() const { return m_memoryUsedGb; }
    int memoryUsedPercent() const { return m_memoryUsedPercent; }
    int storageUsedGb() const { return m_storageUsedGb; }
    int storageTotalGb() const { return m_storageTotalGb; }
    int storageUsedPercent() const { return m_storageUsedPercent; }

    Q_INVOKABLE void refresh();

signals:
    void statsChanged();

private:
    static QString detectModel();
    static QString detectSerial();
    static qint64 readMemTotalKb();

    void readUptime();
    void readMemory();
    void readStorage();

    QTimer *m_timer;

    QString m_hostname;
    QString m_model;
    QString m_os;
    QString m_kernel;
    QString m_serial;
    int m_memoryTotalGb = 0;

    QString m_uptime;
    int m_memoryUsedGb = 0;
    int m_memoryUsedPercent = 0;
    int m_storageUsedGb = 0;
    int m_storageTotalGb = 0;
    int m_storageUsedPercent = 0;
};
