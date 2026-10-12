#include "systemmonitor.h"

#include "sysfs.h"

#include <QDir>
#include <QHash>
#include <QTimer>

#include <cstdlib>

namespace {

// Sampled far more often than the panel needs, so that short bursts are
// outvoted inside the median window.
constexpr int kSampleIntervalMs = 500;
// Short window: this stage only has to drop the sub-second spikes, the drift is
// handled by the exponential average that follows it.
constexpr int kMedianWindow = 5;
// Until the window holds a few samples the median is just the latest reading,
// so a spike caught by the very first poll would still reach the panel.
constexpr int kMinSamples = 3;
// Publishing at the sampling rate makes the panel twitch twice a second even
// when the value barely moves; the status bar is readable at 2 s.
constexpr int kPublishEverySamples = 4;
// At 500 ms per sample these give roughly a 10 s time constant for temperature
// and 3 s for load, which stays responsive enough to be useful.
constexpr double kTempAlpha = 0.05;
constexpr double kLoadAlpha = 0.15;
// Dead band against last-digit flicker. It quantises the reading, never freezes
// it: once the real value drifts past the threshold the panel follows.
constexpr int kTempDeadBandC = 2;
constexpr int kLoadDeadBandPercent = 3;

// Priority order, not just a membership test: a machine exposes up to a dozen
// zones, thermal_zone0 is usually the board sensor (acpitz) which trails the
// package by several degrees, and some zones report nonsense (SEN1 answers
// "50", i.e. 0.05 °C).
const QStringList &cpuZoneTypes()
{
    static const QStringList types{
        QStringLiteral("cpu-thermal"),   // Raspberry Pi
        QStringLiteral("cpu_thermal"),
        QStringLiteral("soc_thermal"),
        QStringLiteral("x86_pkg_temp"),  // Intel
        QStringLiteral("coretemp"),
        QStringLiteral("k10temp"),       // AMD
        QStringLiteral("acpitz"),
    };
    return types;
}

} // namespace

SystemMonitor::SystemMonitor(QObject *parent)
    : QObject(parent),
      m_timer(new QTimer(this)),
      m_tempMedian(kMedianWindow),
      m_loadMedian(kMedianWindow),
      m_tempAverage(kTempAlpha),
      m_loadAverage(kLoadAlpha)
{
    m_thermalPath = findCpuThermalZone();
    m_batteryPath = findBattery();

    connect(m_timer, &QTimer::timeout, this, &SystemMonitor::refresh);
    m_timer->start(kSampleIntervalMs);

    refresh();
}

void SystemMonitor::refresh()
{
    ++m_tick;
    const bool publish = (m_tick % kPublishEverySamples) == 0;

    sampleCpuTemp(publish);
    sampleCpuLoad(publish);
    sampleBattery();
}

QString SystemMonitor::findCpuThermalZone()
{
    const QDir root(QStringLiteral("/sys/class/thermal"));
    const QStringList zones = root.entryList({QStringLiteral("thermal_zone*")}, QDir::Dirs);

    QHash<QString, QString> pathByType;
    QString fallback;

    for (const QString &zone : zones) {
        const QString path = root.filePath(zone);
        const QString type = Sysfs::readFirstLine(path + QStringLiteral("/type")).toLower();

        if (!type.isEmpty() && !pathByType.contains(type))
            pathByType.insert(type, path);

        if (fallback.isEmpty() && type.contains(QStringLiteral("cpu")))
            fallback = path;
    }

    for (const QString &preferred : cpuZoneTypes()) {
        const auto found = pathByType.constFind(preferred);
        if (found != pathByType.constEnd())
            return *found + QStringLiteral("/temp");
    }

    return fallback.isEmpty() ? QString() : fallback + QStringLiteral("/temp");
}

QString SystemMonitor::findBattery()
{
    const QDir root(QStringLiteral("/sys/class/power_supply"));
    const QStringList supplies = root.entryList(QDir::Dirs | QDir::NoDotAndDotDot);

    for (const QString &supply : supplies) {
        const QString path = root.filePath(supply);

        if (Sysfs::readFirstLine(path + QStringLiteral("/type")) != QLatin1String("Battery"))
            continue;

        // A wireless mouse or gamepad also reports type=Battery, and its charge
        // would otherwise end up in the status bar instead of the device's own.
        if (Sysfs::readFirstLine(path + QStringLiteral("/scope")) == QLatin1String("Device"))
            continue;

        return path;
    }

    return QString();
}

void SystemMonitor::sampleCpuTemp(bool publish)
{
    if (m_thermalPath.isEmpty())
        return;

    bool ok = false;
    const int milliCelsius = Sysfs::readFirstLine(m_thermalPath).toInt(&ok);
    if (!ok)
        return;

    m_tempMedian.push((milliCelsius + 500) / 1000);
    if (m_tempMedian.size() < kMinSamples)
        return;

    m_tempAverage.push(m_tempMedian.value());
    if (publish)
        setCpuTemp(m_tempAverage.value());
}

void SystemMonitor::sampleCpuLoad(bool publish)
{
    const QString line = Sysfs::readFirstLine(QStringLiteral("/proc/stat"));
    if (!line.startsWith(QLatin1String("cpu ")))
        return;

    const QStringList fields = line.split(QLatin1Char(' '), Qt::SkipEmptyParts);
    if (fields.size() < 6)
        return;

    qint64 total = 0;
    for (int i = 1; i < fields.size(); ++i)
        total += fields.at(i).toLongLong();

    const qint64 idle = fields.at(4).toLongLong() + fields.at(5).toLongLong();

    if (m_lastTotal > 0 && total > m_lastTotal) {
        const qint64 deltaTotal = total - m_lastTotal;
        const qint64 deltaBusy = deltaTotal - (idle - m_lastIdle);

        m_loadMedian.push(qBound(0, int(qRound(100.0 * double(deltaBusy) / double(deltaTotal))), 100));
        if (m_loadMedian.size() >= kMinSamples) {
            m_loadAverage.push(m_loadMedian.value());
            if (publish)
                setCpuLoad(m_loadAverage.value());
        }
    }

    m_lastTotal = total;
    m_lastIdle = idle;
}

void SystemMonitor::sampleBattery()
{
    // A UPS hat can be plugged in after startup, so an absent battery is
    // re-checked rather than decided once.
    if (m_batteryPath.isEmpty())
        m_batteryPath = findBattery();

    const bool present = !m_batteryPath.isEmpty()
                         && Sysfs::readFirstLine(m_batteryPath + QStringLiteral("/present"))
                                != QLatin1String("0");

    int level = -1;
    bool charging = false;

    if (present) {
        bool ok = false;
        const int capacity = Sysfs::readFirstLine(m_batteryPath + QStringLiteral("/capacity")).toInt(&ok);
        level = ok ? qBound(0, capacity, 100) : -1;

        const QString status = Sysfs::readFirstLine(m_batteryPath + QStringLiteral("/status"));
        charging = status == QLatin1String("Charging") || status == QLatin1String("Full");
    }

    if (m_batteryPresent == present && m_batteryLevel == level && m_charging == charging)
        return;

    m_batteryPresent = present;
    m_batteryLevel = level;
    m_charging = charging;
    emit batteryChanged();
}

void SystemMonitor::setCpuTemp(int celsius)
{
    if (m_cpuTemp >= 0 && std::abs(celsius - m_cpuTemp) < kTempDeadBandC)
        return;
    if (m_cpuTemp == celsius)
        return;

    m_cpuTemp = celsius;
    emit cpuTempChanged();
}

void SystemMonitor::setCpuLoad(int percent)
{
    if (m_cpuLoad >= 0 && std::abs(percent - m_cpuLoad) < kLoadDeadBandPercent)
        return;
    if (m_cpuLoad == percent)
        return;

    m_cpuLoad = percent;
    emit cpuLoadChanged();
}
