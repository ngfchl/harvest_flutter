import '../../download/model/downloader.dart';
import '../model/torrent_model.dart';
import 'torrent_action_menu.dart';

class TorrentDeleteSummary {
  final int metadataOnlyCount;
  final int deleteFileCount;
  final bool success;

  const TorrentDeleteSummary({required this.metadataOnlyCount, required this.deleteFileCount, required this.success});

  int get total => metadataOnlyCount + deleteFileCount;
}

bool isCleanableTorrentError(Torrent torrent) {
  if (!torrent.hasError) return false;
  final message = torrent.effectiveErrorMessage.toLowerCase();
  if (message.isEmpty || message == '未知错误') return false;

  const keywords = [
    'torrent banned',
    'banned',
    'not registered',
    'unregistered',
    'not found',
    'does not exist',
    'deleted',
    'removed',
    'torrent not exist',
    'torrent not registered',
    'not exist',
    'not authorized',
    'unapproved',
    'not approved',
    '未注册',
    '没有注册',
    '不存在',
    '已删除',
    '被删除',
    '种子被删',
    '禁用',
    '被禁',
    '未通过',
  ];
  return keywords.any(message.contains);
}

Future<TorrentDeleteSummary> deleteTorrentsWithOptionalFiles({
  required DownloaderType type,
  required List<Torrent> torrents,
  required List<Torrent> allTorrents,
  required bool deleteFilesWhenUnpreserved,
  required OnTorrentAction onAction,
}) async {
  final deletingHashes = torrents.map((torrent) => torrent.hashString).where((hash) => hash.isNotEmpty).toSet();
  final deleteFileIds = <String>[];
  final metadataOnlyIds = <String>[];

  for (final torrent in torrents) {
    final hash = torrent.hashString;
    if (hash.isEmpty) continue;

    final shouldDeleteFiles =
        deleteFilesWhenUnpreserved && !hasOtherPreservingSameContent(torrent, allTorrents, deletingHashes);
    (shouldDeleteFiles ? deleteFileIds : metadataOnlyIds).add(hash);
  }

  var success = true;
  if (metadataOnlyIds.isNotEmpty) {
    success &= await runTorrentDeleteAction(type: type, ids: metadataOnlyIds, deleteFiles: false, onAction: onAction);
  }
  if (deleteFileIds.isNotEmpty) {
    success &= await runTorrentDeleteAction(type: type, ids: deleteFileIds, deleteFiles: true, onAction: onAction);
  }

  return TorrentDeleteSummary(
    metadataOnlyCount: metadataOnlyIds.length,
    deleteFileCount: deleteFileIds.length,
    success: success,
  );
}

Future<bool> runTorrentDeleteAction({
  required DownloaderType type,
  required List<String> ids,
  required bool deleteFiles,
  required OnTorrentAction onAction,
}) {
  final isQb = type == DownloaderType.qbittorrent;
  return onAction(
    isQb ? 'delete' : 'remove_torrent',
    isQb ? {'hashes': ids, 'deleteFiles': deleteFiles} : {'ids': ids, 'deleteFiles': deleteFiles},
  );
}

bool hasOtherPreservingSameContent(Torrent target, List<Torrent> allTorrents, Set<String> deletingHashes) {
  final targetKey = normalizedTorrentContentKey(target);
  if (targetKey.isEmpty) return false;

  return allTorrents.any((torrent) {
    final hash = torrent.hashString;
    if (hash.isEmpty || deletingHashes.contains(hash)) return false;
    if (!isPreservingTorrent(torrent)) return false;
    return normalizedTorrentContentKey(torrent) == targetKey;
  });
}

bool isPreservingTorrent(Torrent torrent) {
  return torrent.torrentStatus == TorrentStatus.seeding ||
      torrent.torrentStatus == TorrentStatus.seedWait ||
      torrent.isFinished ||
      torrent.percentDone >= 1.0 ||
      torrent.percentComplete >= 1.0;
}

String normalizedTorrentContentKey(Torrent torrent) {
  final contentPath = torrent.contentPath.trim();
  if (contentPath.isNotEmpty) return _normalizePath(contentPath);

  final downloadDir = torrent.downloadDir.trim();
  final name = torrent.name.trim();
  if (downloadDir.isEmpty || name.isEmpty) return '';
  return _normalizePath('$downloadDir/$name');
}

String _normalizePath(String path) {
  var normalized = path.trim().replaceAll(r'\', '/');
  while (normalized.length > 1 && normalized.endsWith('/')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  return normalized;
}
