#include "musiclibrary.h"

#include <QDir>
#include <QDirIterator>
#include <QFileInfo>
#include <QStandardPaths>

#include <algorithm>

namespace {

const QStringList &audioFilters()
{
    static const QStringList filters{
        QStringLiteral("*.mp3"), QStringLiteral("*.flac"), QStringLiteral("*.ogg"),
        QStringLiteral("*.oga"), QStringLiteral("*.opus"), QStringLiteral("*.wav"),
        QStringLiteral("*.m4a"), QStringLiteral("*.aac"),
    };
    return filters;
}

} // namespace

MusicLibrary::MusicLibrary(QObject *parent) : QAbstractListModel(parent)
{
    m_folder = defaultFolder();
    refresh();
}

QString MusicLibrary::defaultFolder()
{
    const QString music = QStandardPaths::writableLocation(QStandardPaths::MusicLocation);
    return music.isEmpty() ? QDir::homePath() : music;
}

int MusicLibrary::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : int(m_tracks.size());
}

QVariant MusicLibrary::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_tracks.size())
        return QVariant();

    const MusicTrack &track = m_tracks.at(index.row());
    switch (role) {
    case TitleRole:    return track.title;
    case FileNameRole: return track.fileName;
    case AlbumRole:    return track.album;
    case SourceRole:   return track.source;
    default:           return QVariant();
    }
}

QHash<int, QByteArray> MusicLibrary::roleNames() const
{
    return {
        {TitleRole,    QByteArrayLiteral("title")},
        {FileNameRole, QByteArrayLiteral("fileName")},
        {AlbumRole,    QByteArrayLiteral("album")},
        {SourceRole,   QByteArrayLiteral("source")},
    };
}

void MusicLibrary::setFolder(const QString &folder)
{
    if (m_folder == folder)
        return;

    m_folder = folder;
    emit folderChanged();
    refresh();
}

void MusicLibrary::refresh()
{
    QList<MusicTrack> found;
    const QDir root(m_folder);

    QDirIterator it(m_folder, audioFilters(), QDir::Files | QDir::Readable,
                    QDirIterator::Subdirectories);
    while (it.hasNext()) {
        const QFileInfo info(it.next());

        MusicTrack track;
        track.title = info.completeBaseName();
        track.fileName = info.fileName();
        // Files sitting directly in the library root have no album above them.
        track.album = info.absolutePath() == root.absolutePath()
                          ? QString()
                          : QFileInfo(info.absolutePath()).fileName();
        track.source = QUrl::fromLocalFile(info.absoluteFilePath());

        found.append(track);
    }

    // Folder first, then title: an album stays together and in a sane order,
    // which the file system iteration order does not guarantee.
    std::sort(found.begin(), found.end(), [](const MusicTrack &left, const MusicTrack &right) {
        if (left.album != right.album)
            return left.album.localeAwareCompare(right.album) < 0;
        return left.title.localeAwareCompare(right.title) < 0;
    });

    const int previous = int(m_tracks.size());

    beginResetModel();
    m_tracks = found;
    endResetModel();

    if (previous != int(m_tracks.size()))
        emit countChanged();
}

QUrl MusicLibrary::sourceAt(int row) const
{
    if (row < 0 || row >= m_tracks.size())
        return QUrl();
    return m_tracks.at(row).source;
}

QString MusicLibrary::titleAt(int row) const
{
    if (row < 0 || row >= m_tracks.size())
        return QString();
    return m_tracks.at(row).title;
}
