#pragma once

#include <QFile>
#include <QString>
#include <QStringList>

namespace Sysfs {

inline QString readFirstLine(const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return QString();

    // Device-tree values are NUL-terminated, and the NUL survives into QString
    // and then into the UI as a stray glyph.
    return QString::fromUtf8(file.readLine()).remove(QChar(u'\0')).trimmed();
}

inline QStringList readLines(const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return {};

    // QFile::atEnd() is useless on procfs: those files report size 0, so the
    // usual while (!atEnd()) loop exits before reading a single line.
    QStringList lines;
    QByteArray line;
    while (!(line = file.readLine()).isEmpty())
        lines.append(QString::fromUtf8(line).trimmed());

    return lines;
}

// Parses "MemTotal:  16062244 kB" into 16062244.
inline qint64 valueKb(const QString &line)
{
    return line.section(QLatin1Char(':'), 1).remove(QLatin1String("kB")).trimmed().toLongLong();
}

} // namespace Sysfs
