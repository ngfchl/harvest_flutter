import 'package:harvest/utils/logger_helper.dart';

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
  List<String> tags;
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
    required this.tags,
    required this.hr,
    required this.published,
    required this.size,
    required this.seeders,
    required this.leechers,
    required this.completers,
  });

  factory SearchTorrentInfo.fromJson(Map<String, dynamic> json) {
    dynamic published;
    dynamic size;
    dynamic saleExpire;
    try {
      published = DateTime.parse(json['published']);
    } catch (e) {
      published = json['published'];
      Logger.instance.e(json['published']);
    }
    try {
      size = int.parse(json['size']);
    } catch (e) {
      size = 0;
    }
    try {
      saleExpire = json['sale_expire'] != null
          ? DateTime.parse(json['sale_expire'])
          : null;
    } catch (e, trace) {
      Logger.instance.e(e);
      Logger.instance.e(trace);
      Logger.instance.e(json);
      saleExpire = null;
    }
    return SearchTorrentInfo(
      siteId: json['site_id'],
      tid: json['tid'].toString(),
      poster: json['poster'] ?? '',
      category: json['category'] ?? '无分类',
      magnetUrl: json['magnet_url'],
      detailUrl: json['detail_url'],
      title: json['title'],
      subtitle: json['subtitle'] ?? '',
      progress: json['progress'],
      tags: List<String>.from(json['tags']),
      saleStatus: json['sale_status'] ?? '无优惠',
      saleExpire: saleExpire,
      hr: json['hr'] ?? false,
      published: published,
      size: size,
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
    data['sale_expire'] = saleExpire?.toString();
    data['hr'] = hr;
    data['published'] = published.toString();
    data['size'] = size;
    data['seeders'] = seeders;
    data['leechers'] = leechers;
    data['completers'] = completers;
    return data;
  }

  SearchTorrentInfo copyWith({
    String? siteId,
    String? tid,
    String? poster,
    String? category,
    String? magnetUrl,
    String? detailUrl,
    String? title,
    String? subtitle,
    String? saleStatus,
    List<String>? tags,
    DateTime? saleExpire,
    double? progress,
    bool? hr,
    DateTime? published,
    int? size,
    int? seeders,
    int? leechers,
    int? completers,
  }) {
    return SearchTorrentInfo(
      siteId: siteId ?? this.siteId,
      tid: tid ?? this.tid,
      poster: poster ?? this.poster,
      category: category ?? this.category,
      magnetUrl: magnetUrl ?? this.magnetUrl,
      detailUrl: detailUrl ?? this.detailUrl,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      progress: progress ?? this.progress,
      saleStatus: saleStatus ?? this.saleStatus,
      saleExpire: saleExpire ?? this.saleExpire,
      hr: hr ?? this.hr,
      tags: tags ?? this.tags,
      published: published ?? this.published,
      size: size ?? this.size,
      seeders: seeders ?? this.seeders,
      leechers: leechers ?? this.leechers,
      completers: completers ?? this.completers,
    );
  }
}
