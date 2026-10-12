#pragma once

#include <QAbstractListModel>
#include <QList>
#include <QString>
#include <QStringList>
#include <QUrl>
#include <QtQmlIntegration/qqmlintegration.h>

struct MusicTrack
{
    QString title;      // file name without the extension
    QString fileName;
    QString album;      // name of the containing folder
    QUrl    source;
};

// Flat list of playable files found under one folder. Tags are deliberately not
// read: pulling metadata out of every file means decoding every file, which on
// a Pi turns opening the page into a visible stall.
class MusicLibrary : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QString folder READ folder WRITE setFolder NOTIFY folderChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum Role {
        TitleRole = Qt::UserRole + 1,
        FileNameRole,
        AlbumRole,
        SourceRole,
    };
    Q_ENUM(Role)

    explicit MusicLibrary(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString folder() const { return m_folder; }
    void setFolder(const QString &folder);
    int count() const { return int(m_tracks.size()); }

    Q_INVOKABLE void refresh();
    Q_INVOKABLE QUrl sourceAt(int row) const;
    Q_INVOKABLE QString titleAt(int row) const;

signals:
    void folderChanged();
    void countChanged();

private:
    static QString defaultFolder();

    QString m_folder;
    QList<MusicTrack> m_tracks;
};
