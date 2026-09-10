#pragma once

#include <QObject>
#include <QProcess>
#include <QtQml>

class SystemController : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit SystemController(QObject *parent = nullptr) : QObject(parent) {}

    Q_INVOKABLE void poweroff() {
        QProcess::execute("systemctl", {"poweroff"});
    }

    Q_INVOKABLE void reboot() {
        QProcess::execute("systemctl", {"reboot"});
    }

    Q_INVOKABLE void suspend() {
        QProcess::execute("systemctl", {"suspend"});
    }
};