import '../model/torrent_model.dart';

enum TorrentColumn {
  queueId('queueId', '队列ID', 72, TorrentSort.queuePosition),
  name('name', '名称', 320, TorrentSort.name),
  selectedSize('selectedSize', '选定大小', 94, TorrentSort.size),
  totalSize('totalSize', '总大小', 94, TorrentSort.size),
  progress('progress', '进度', 110, TorrentSort.progress),
  status('status', '状态', 86, null),
  seeds('seeds', '种子', 64, null),
  peers('peers', '用户', 64, null),
  download('download', '下载速度', 96, TorrentSort.downloadSpeed),
  upload('upload', '上传速度', 96, TorrentSort.uploadSpeed),
  eta('eta', '剩余时间', 110, null),
  ratio('ratio', '分享率', 72, TorrentSort.ratio),
  category('category', '分类', 110, null),
  tags('tags', '标签', 160, null),
  added('added', '添加于', 92, TorrentSort.addedDate),
  completed('completed', '完成于', 92, null),
  tracker('tracker', 'Tracker（站点）', 130, null),
  speedLimit('speedLimit', '下载/上传限速', 150, null),
  downloaded('downloaded', '已下载', 90, null),
  uploaded('uploaded', '已上传', 90, null),
  sessionTransfer('sessionTransfer', '本次会话上传/下载', 150, null),
  savePath('savePath', '保存路径', 220, null),
  ratioLimit('ratioLimit', '分享率限制', 96, null),
  lastSeenComplete('lastSeenComplete', '最后完整可见', 118, null),
  activity('activity', '最后活动', 92, TorrentSort.activityDate);

  final String id;
  final String label;
  final double width;
  final TorrentSort? sort;

  const TorrentColumn(this.id, this.label, this.width, this.sort);
}
