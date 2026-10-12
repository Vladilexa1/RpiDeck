#pragma once

#include <QObject>
#include <QString>
#include <QtQmlIntegration/qqmlintegration.h>

class SystemController : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit SystemController(QObject *parent = nullptr);

    Q_INVOKABLE void poweroff();
    Q_INVOKABLE void reboot();
    Q_INVOKABLE void suspend();

    // Handed to the desktop's own URL handler rather than to a hardcoded
    // binary, so the link lands in whichever browser the system is set to use.
    // False means nothing claimed it — a bare image without xdg-utils, say.
    Q_INVOKABLE bool openUrl(const QString &url);
};
