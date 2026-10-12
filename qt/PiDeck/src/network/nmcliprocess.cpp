#include "nmcliprocess.h"

#include <QProcess>
#include <QTimer>

#include <memory>

NmcliProcess::NmcliProcess(QObject *parent) : QObject(parent) {}

void NmcliProcess::run(const QStringList &args, int timeoutMs, Callback done)
{
    auto *process = new QProcess(this);
    auto reported = std::make_shared<bool>(false);

    // Both paths can fire for one process, and the timeout below adds a third,
    // so the callback is guarded instead of being wired to a single signal.
    auto report = [process, done, reported](const Result &result) {
        if (*reported)
            return;
        *reported = true;
        done(result);
        process->deleteLater();
    };

    // FailedToStart never emits finished(), so a missing nmcli would otherwise
    // leave the caller waiting forever with no error at all.
    connect(process, &QProcess::errorOccurred, this, [process, report](QProcess::ProcessError e) {
        report({false, QString(),
                e == QProcess::FailedToStart
                    ? QStringLiteral("nmcli not found — is NetworkManager installed?")
                    : process->errorString()});
    });

    connect(process, &QProcess::finished, this,
            [process, report](int exitCode, QProcess::ExitStatus status) {
                report({status == QProcess::NormalExit && exitCode == 0,
                        QString::fromUtf8(process->readAllStandardOutput()),
                        QString::fromUtf8(process->readAllStandardError()).trimmed()});
            });

    // nmcli can hang when NetworkManager stops answering; without this the UI
    // would stay in its busy state for good.
    QTimer::singleShot(timeoutMs, process, [process, report]() {
        if (process->state() == QProcess::NotRunning)
            return;
        process->kill();
        report({false, QString(), QStringLiteral("nmcli timed out")});
    });

    process->start(QStringLiteral("nmcli"), args);
}
