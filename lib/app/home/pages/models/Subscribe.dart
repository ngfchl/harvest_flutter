import 'package:harvest/app/home/pages/models/my_rss.dart';

class SubPlan {
  final int? id;
  final String name;
  final List<String>? exclude;
  final bool available;
  final bool start;
  final int minSize;
  final int maxSize;
  final List<String> discount;
  final String? category;
  final List<String> resolution;
  final List<String> videoCodec;
  final List<String> audioCodec;
  final List<String> source;
  final List<String> publisher;
  final List<String> tags;
  final int? downloaderId;
  final String? downloaderCategory;
  final String? downloaderSavePath;
  final List<MyRss> rssList;
  final String? createdAt;
  final String? updatedAt;

  SubPlan({
    this.id,
    required this.name,
    this.exclude = const [],
    this.available = true,
    this.start = true,
    this.minSize = 1,
    this.maxSize = 15,
    this.discount = const [],
    this.category,
    this.resolution = const [],
    this.videoCodec = const [],
    this.audioCodec = const [],
    this.source = const [],
    this.publisher = const [],
    this.tags = const [],
    this.downloaderId,
    this.downloaderCategory,
    this.downloaderSavePath,
    this.rssList = const [],
    this.createdAt,
    this.updatedAt,
  });

  // ✅ 修正：构造函数名应为 SubPlan.fromJson
  factory SubPlan.fromJson(Map<String, dynamic> json) {
    return SubPlan(
      id: json['id'],
      name: json['name'] ?? '',
      exclude: (json['exclude'] as List<dynamic>?)?.cast<String>() ?? const [],
      available: json['available'] ?? true,
      start: json['start'] ?? true,
      minSize: json['min_size'] ?? 1,
      maxSize: json['max_size'] ?? 15,
      discount: (json['discount'] as List<dynamic>?)?.cast<String>() ?? const [],
      category: json['category'],
      resolution: (json['resolution'] as List<dynamic>?)?.cast<String>() ?? const [],
      videoCodec: (json['video_codec'] as List<dynamic>?)?.cast<String>() ?? const [],
      audioCodec: (json['audio_codec'] as List<dynamic>?)?.cast<String>() ?? const [],
      source: (json['source'] as List<dynamic>?)?.cast<String>() ?? const [],
      publisher: (json['publisher'] as List<dynamic>?)?.cast<String>() ?? const [],
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      downloaderId: json['downloader_id'],
      downloaderCategory: json['downloader_category'],
      downloaderSavePath: json['downloader_save_path'],
      rssList: (json['rss_list'] as List<dynamic>?)?.map((e) => MyRss.fromJson(e as Map<String, dynamic>)).toList() ??
          const [],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // ✅ toJson：将对象转为 JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'exclude': exclude,
      'available': available,
      'start': start,
      'min_size': minSize,
      'max_size': maxSize,
      'discount': discount,
      'category': category,
      'resolution': resolution,
      'video_codec': videoCodec,
      'audio_codec': audioCodec,
      'source': source,
      'publisher': publisher,
      'tags': tags,
      'downloader_id': downloaderId,
      'downloader_category': downloaderCategory,
      'downloader_save_path': downloaderSavePath,
      'rss_list': rssList.map((rss) => rss.id).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // ✅ copyWith：用于不可变对象的更新（常用于 Flutter 状态管理）
  SubPlan copyWith({
    int? id,
    String? name,
    List<String>? exclude,
    bool? available,
    bool? start,
    int? minSize,
    int? maxSize,
    List<String>? discount,
    String? category,
    List<String>? resolution,
    List<String>? videoCodec,
    List<String>? audioCodec,
    List<String>? source,
    List<String>? publisher,
    List<String>? tags,
    int? downloaderId,
    String? downloaderCategory,
    String? downloaderSavePath,
    List<MyRss>? rssList,
    String? createdAt,
    String? updatedAt,
  }) {
    return SubPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      exclude: exclude ?? this.exclude,
      available: available ?? this.available,
      start: start ?? this.start,
      minSize: minSize ?? this.minSize,
      maxSize: maxSize ?? this.maxSize,
      discount: discount ?? this.discount,
      category: category ?? this.category,
      resolution: resolution ?? this.resolution,
      videoCodec: videoCodec ?? this.videoCodec,
      audioCodec: audioCodec ?? this.audioCodec,
      source: source ?? this.source,
      publisher: publisher ?? this.publisher,
      tags: tags ?? this.tags,
      downloaderId: downloaderId ?? this.downloaderId,
      downloaderCategory: downloaderCategory ?? this.downloaderCategory,
      downloaderSavePath: downloaderSavePath ?? this.downloaderSavePath,
      rssList: rssList ?? this.rssList,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Subscribe {
  int? id;
  String name;
  String keyword;
  List<String>? exclude;
  List<String>? season;
  String? douban;
  String? imdb;
  String? tmdb;
  List<String> publishYear;
  bool available;
  int? planId;
  String? createdAt;
  String? updatedAt;

  Subscribe({
    this.id,
    required this.name,
    required this.keyword,
    this.exclude = const [],
    this.publishYear = const [],
    this.season = const [],
    this.douban,
    this.imdb,
    this.tmdb,
    this.planId,
    this.available = true,
    this.createdAt,
    this.updatedAt,
  });

  Subscribe.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        keyword = json['keyword'],
        exclude = json['exclude']?.cast<String>(),
        publishYear = List<String>.from(json['publish_year'] ?? []),
        season = List<String>.from(json['season'] ?? []),
        douban = json['douban'],
        imdb = json['imdb'],
        tmdb = json['tmdb'],
        planId = json['plan_id'],
        available = json['available'] ?? false,
        createdAt = json['created_at'],
        updatedAt = json['updated_at'];

  Subscribe copyWith({
    int? id,
    int? planId,
    String? name,
    String? keyword,
    List<String>? exclude,
    List<String>? publishYear,
    List<String>? season,
    String? douban,
    String? imdb,
    String? tmdb,
    bool? available,
    String? createdAt,
    String? updatedAt,
  }) =>
      Subscribe(
        id: id ?? this.id,
        planId: planId ?? this.planId,
        name: name ?? this.name,
        keyword: keyword ?? this.keyword,
        exclude: exclude ?? this.exclude,
        publishYear: publishYear ?? this.publishYear,
        season: season ?? this.season,
        douban: douban ?? this.douban,
        imdb: imdb ?? this.imdb,
        tmdb: tmdb ?? this.tmdb,
        available: available ?? this.available,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['plan_id'] = planId;
    map['name'] = name;
    map['keyword'] = keyword;
    map['exclude'] = exclude;
    map['publish_year'] = publishYear;
    map['season'] = season;
    map['douban'] = douban;
    map['imdb'] = imdb;
    map['tmdb'] = tmdb;
    map['available'] = available;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

  @override
  String toString() {
    return '订阅信息：$name - $keyword';
  }
}
