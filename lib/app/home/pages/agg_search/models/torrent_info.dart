class SearchTorrentInfo {
  String siteId;
  String tid;
  String poster;
  String category;
  String magnetUrl;
  String detailUrl;
  String title;
  String subtitle;
  String saleStatus;
  double? progress;
  DateTime? saleExpire;
  bool hr;
  dynamic published;
  int size;
  int seeders;
  int leechers;
  int completers;

  SearchTorrentInfo({
    required this.siteId,
    required this.tid,
    required this.poster,
    required this.category,
    required this.magnetUrl,
    required this.detailUrl,
    required this.title,
    required this.subtitle,
    required this.saleStatus,
    this.saleExpire,
    this.progress,
    required this.hr,
    required this.published,
    required this.size,
    required this.seeders,
    required this.leechers,
    required this.completers,
  });

  factory SearchTorrentInfo.fromJson(Map<String, dynamic> json) {
    dynamic published;
    try {
      published = DateTime.parse(json['published']);
    } catch (e) {
      published = json['published'];
    }

    return SearchTorrentInfo(
      siteId: json['site_id'],
      tid: json['tid'],
      poster: json['poster'],
      category: json['category'] ?? '无分类',
      magnetUrl: json['magnet_url'],
      detailUrl: json['detail_url'],
      title: json['title'],
      subtitle: json['subtitle'],
      progress: json['progress'],
      saleStatus: json['sale_status'] ?? '无优惠',
      saleExpire: json['sale_expire'] != null
          ? DateTime.parse(json['sale_expire'])
          : null,
      hr: json['hr'] ?? false,
      published: published,
      size: json['size'],
      seeders: json['seeders'],
      leechers: json['leechers'],
      completers: json['completers'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['site_id'] = siteId;
    data['tid'] = tid;
    data['poster'] = poster;
    data['category'] = category;
    data['magnet_url'] = magnetUrl;
    data['detail_url'] = detailUrl;
    data['title'] = title;
    data['subtitle'] = subtitle;
    data['progress'] = progress;
    data['sale_status'] = saleStatus;
    data['sale_expire'] = saleExpire?.toIso8601String();
    data['hr'] = hr;
    data['published'] = published.toIso8601String();
    data['size'] = size;
    data['seeders'] = seeders;
    data['leechers'] = leechers;
    data['completers'] = completers;
    return data;
  }
}
