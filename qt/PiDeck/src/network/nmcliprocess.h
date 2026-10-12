#pragma once

#include <QObject>
#include <QString>
#include <QStringList>

#include <functional>

class NmcliProcess : public QObject
{
    Q_OBJECT

public:
    struct Result
    {
        bool    ok = false;
        QString out;
        QString err;
    };

    using Callback = std::function<void(const Result &)>;

    explicit NmcliProcess(QObject *parent = nullptr);

    void run(const QStringList &args, int timeoutMs, Callback done);
};
