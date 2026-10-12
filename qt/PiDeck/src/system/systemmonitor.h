#pragma once

#include "emafilter.h"
#include "medianfilter.h"

#include <QObject>
#include <QString>
#include <QtQmlIntegration/qqmlintegration.h>

class QTimer;

class SystemMonitor : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(int cpuTemp READ cpuTemp NOTIFY cpuTempChanged)   // °C, -1 without a sensor
    Q_PROPERTY(int cpuLoad READ cpuLoad NOTIFY cpuLoadChanged)   // %, -1 until the second sample
    Q_PROPERTY(bool batteryPresent READ batteryPresent NOTIFY batteryChanged)
    Q_PROPERTY(int batteryLevel READ batteryLevel NOTIFY batteryChanged)
    Q_PROPERTY(bool charging READ charging NOTIFY batteryChanged)

public:
    explicit SystemMonitor(QObject *parent = nullptr);

    int cpuTemp() const { return m_cpuTemp; }
    int cpuLoad() const { return m_cpuLoad; }
    bool batteryPresent() const { return m_batteryPresent; }
    int batteryLevel() const { return m_batteryLevel; }
    bool charging() const { return m_charging; }

    Q_INVOKABLE void refresh();

signals:
    void cpuTempChanged();
    void cpuLoadChanged();
    void batteryChanged();

private:
    static QString findCpuThermalZone();
    static QString findBattery();

    void sampleCpuTemp(bool publish);
    void sampleCpuLoad(bool publish);
    void sampleBattery();

    void setCpuTemp(int celsius);
    void setCpuLoad(int percent);

    QTimer *m_timer;
    QString m_thermalPath;
    QString m_batteryPath;

    MedianFilter m_tempMedian;
    MedianFilter m_loadMedian;
    EmaFilter m_tempAverage;
    EmaFilter m_loadAverage;

    int    m_tick = 0;
    qint64 m_lastIdle = 0;
    qint64 m_lastTotal = 0;

    int  m_cpuTemp = -1;
    int  m_cpuLoad = -1;
    int  m_batteryLevel = -1;
    bool m_batteryPresent = false;
    bool m_charging = false;
};
