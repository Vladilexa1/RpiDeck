#include "systemcontroller.h"

#include <QDebug>
#include <QDesktopServices>
#include <QProcess>
#include <QUrl>

SystemController::SystemController(QObject *parent) : QObject(parent) {}

void SystemController::poweroff()
{
    QProcess::execute(QStringLiteral("systemctl"), {QStringLiteral("poweroff")});
}

void SystemController::reboot()
{
    QProcess::execute(QStringLiteral("systemctl"), {QStringLiteral("reboot")});
}

void SystemController::suspend()
{
    QProcess::execute(QStringLiteral("systemctl"), {QStringLiteral("suspend")});
}

bool SystemController::openUrl(const QString &url)
{
    const QUrl target(url);
    if (!target.isValid()) {
        qWarning() << "refusing to open an invalid url:" << url;
        return false;
    }

    const bool opened = QDesktopServices::openUrl(target);
    if (!opened)
        qWarning() << "nothing handled" << url << "- is xdg-utils installed?";

    return opened;
}
