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
  DateTime? saleExpire;
  bool hr;
  DateTime published;
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
    required this.hr,
    required this.published,
    required this.size,
    required this.seeders,
    required this.leechers,
    required this.completers,
  });

  factory SearchTorrentInfo.fromJson(Map<String, dynamic> json) {
    return SearchTorrentInfo(
      siteId: json['site_id'],
      tid: json['tid'],
      poster: json['poster'],
      category: json['category'],
      magnetUrl: json['magnet_url'],
      detailUrl: json['detail_url'],
      title: json['title'],
      subtitle: json['subtitle'],
      saleStatus: json['sale_status'],
      saleExpire: json['sale_expire'] != null
          ? DateTime.parse(json['sale_expire'])
          : null,
      hr: json['hr'],
      published: DateTime.parse(json['published']),
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
