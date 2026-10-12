#include "systeminfo.h"

#include "sysfs.h"

#include <QStorageInfo>
#include <QSysInfo>
#include <QTimer>

#include <cmath>

namespace {

constexpr int kStatsIntervalMs = 10000;
constexpr qint64 kBytesPerGb = 1024LL * 1024 * 1024;

int toGb(qint64 bytes)
{
    return int(bytes / kBytesPerGb);
}

// MemTotal and the advertised size never match: firmware reserves a slice, so a
// 16 GB machine reports 15.3. Rounding up restores the number on the box.
int toAdvertisedGb(qint64 kilobytes)
{
    return int(std::ceil(double(kilobytes) / (1024.0 * 1024.0)));
}

QString formatUptime(qint64 seconds)
{
    const qint64 days = seconds / 86400;
    const qint64 hours = (seconds % 86400) / 3600;
    const qint64 minutes = (seconds % 3600) / 60;

    if (days > 0)
        return QStringLiteral("%1d %2h").arg(days).arg(hours);
    if (hours > 0)
        return QStringLiteral("%1h %2m").arg(hours).arg(minutes);
    return QStringLiteral("%1m").arg(minutes);
}

} // namespace

SystemInfo::SystemInfo(QObject *parent) : QObject(parent), m_timer(new QTimer(this))
{
    m_hostname = QSysInfo::machineHostName();
    m_model = detectModel();
    m_os = QSysInfo::prettyProductName();
    m_kernel = QStringLiteral("%1 %2").arg(QSysInfo::kernelVersion(),
                                           QSysInfo::currentCpuArchitecture());
    m_serial = detectSerial();
    m_memoryTotalGb = toAdvertisedGb(readMemTotalKb());

    connect(m_timer, &QTimer::timeout, this, &SystemInfo::refresh);
    m_timer->start(kStatsIntervalMs);

    refresh();
}

QString SystemInfo::appVersion() const
{
    return QStringLiteral(PIDECK_VERSION);
}

QString SystemInfo::builtWith() const
{
    return QStringLiteral("Qt %1 · QML").arg(QStringLiteral(QT_VERSION_STR));
}

void SystemInfo::refresh()
{
    const QString uptime = m_uptime;
    const int memoryGb = m_memoryUsedGb;
    const int memoryPercent = m_memoryUsedPercent;
    const int storageGb = m_storageUsedGb;
    const int storagePercent = m_storageUsedPercent;

    readUptime();
    readMemory();
    readStorage();

    if (uptime != m_uptime || memoryGb != m_memoryUsedGb || memoryPercent != m_memoryUsedPercent
        || storageGb != m_storageUsedGb || storagePercent != m_storageUsedPercent)
        emit statsChanged();
}

QString SystemInfo::detectModel()
{
    // A Pi names itself in the device tree; on x86 the closest equivalent is DMI.
    const QString deviceTree = Sysfs::readFirstLine(QStringLiteral("/proc/device-tree/model"));
    if (!deviceTree.isEmpty())
        return deviceTree;

    const QString dmi =
        Sysfs::readFirstLine(QStringLiteral("/sys/devices/virtual/dmi/id/product_name"));
    if (!dmi.isEmpty())
        return dmi;

    return QSysInfo::currentCpuArchitecture();
}

QString SystemInfo::detectSerial()
{
    const QStringList lines = Sysfs::readLines(QStringLiteral("/proc/cpuinfo"));
    for (const QString &line : lines) {
        if (!line.startsWith(QLatin1String("Serial"), Qt::CaseInsensitive))
            continue;

        const QString value = line.section(QLatin1Char(':'), 1).trimmed();
        if (!value.isEmpty())
            return value;
    }

    // x86 has no CPU serial, so fall back to the installation id.
    return QString::fromLatin1(QSysInfo::machineUniqueId());
}

qint64 SystemInfo::readMemTotalKb()
{
    const QStringList lines = Sysfs::readLines(QStringLiteral("/proc/meminfo"));
    for (const QString &line : lines) {
        if (line.startsWith(QLatin1String("MemTotal:")))
            return Sysfs::valueKb(line);
    }
    return 0;
}

void SystemInfo::readUptime()
{
    const QString line = Sysfs::readFirstLine(QStringLiteral("/proc/uptime"));
    if (line.isEmpty())
        return;

    m_uptime = formatUptime(qint64(line.section(' ', 0, 0).toDouble()));
}

void SystemInfo::readMemory()
{
    qint64 total = 0;
    qint64 available = 0;

    const QStringList lines = Sysfs::readLines(QStringLiteral("/proc/meminfo"));
    for (const QString &line : lines) {
        if (line.startsWith(QLatin1String("MemTotal:")))
            total = Sysfs::valueKb(line);
        // MemAvailable, not MemFree: the kernel counts reclaimable cache as free,
        // and MemFree alone would report a nearly full machine at all times.
        else if (line.startsWith(QLatin1String("MemAvailable:")))
            available = Sysfs::valueKb(line);

        if (total > 0 && available > 0)
            break;
    }

    if (total <= 0)
        return;

    const qint64 used = total - available;
    m_memoryUsedGb = int(std::round(double(used) / (1024.0 * 1024.0)));
    m_memoryUsedPercent = int(std::round(100.0 * double(used) / double(total)));
}

void SystemInfo::readStorage()
{
    const QStorageInfo root = QStorageInfo::root();
    if (!root.isValid() || !root.isReady())
        return;

    const qint64 total = root.bytesTotal();
    if (total <= 0)
        return;

    // Available, not free: the difference is the root-only reserve, which the
    // user can never actually use.
    const qint64 used = total - root.bytesAvailable();

    m_storageTotalGb = toGb(total);
    m_storageUsedGb = toGb(used);
    m_storageUsedPercent = int(std::round(100.0 * double(used) / double(total)));
}
