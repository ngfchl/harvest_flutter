import 'package:harvest/app/home/pages/models/my_rss.dart';

class Subscribe {
  Subscribe({
    this.id,
    required this.name,
    required this.keyword,
    this.exclude = const [],
    this.douban,
    this.imdb,
    this.tmdb,
    this.available = true,
    this.start = true,
    this.size = 15,
    this.discount = const [],
    this.category,
    this.season,
    this.publishYear = const [],
    this.resolution = const [],
    this.videoCodec = const [],
    this.audioCodec = const [],
    this.source = const [],
    this.publisher = const [],
    this.tags = const [],
    this.downloaderId,
    this.downloaderCategory,
    this.rssList = const [],
    this.createdAt,
    this.updatedAt,
  });

  Subscribe.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        keyword = json['keyword'],
        exclude = json['exclude']?.cast<String>(),
        douban = json['douban'],
        imdb = json['imdb'],
        tmdb = json['tmdb'],
        available = json['available'] ?? false,
        start = json['start'] ?? false,
        size = json['size'] ?? 0,
        discount = json['discount']?.cast<String>() ?? [],
        category = json['category'],
        season = json['season'],
        publishYear = json['publish_year']?.cast<String>() ?? [],
        resolution = json['resolution']?.cast<String>() ?? [],
        videoCodec = json['video_codec']?.cast<String>() ?? [],
        audioCodec = json['audio_codec']?.cast<String>() ?? [],
        source = json['source']?.cast<String>() ?? [],
        publisher = json['publisher']?.cast<String>() ?? [],
        tags = json['tags']?.cast<String>() ?? [],
        downloaderId = json['downloader_id'],
        downloaderCategory = json['downloader_category'],
        rssList = (json['rss_list'] as List<dynamic>?)
                ?.map((e) => MyRss.fromJson(e))
                .toList() ??
            [],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'];

  int? id;
  String name;
  String keyword;
  List<String>? exclude;
  String? douban;
  String? imdb;
  String? tmdb;
  bool available;
  bool start;
  int size;
  List<String> discount;
  String? category;
  String? season;
  List<String> publishYear;
  List<String> resolution;
  List<String> videoCodec;
  List<String> audioCodec;
  List<String> source;
  List<String> publisher;
  List<String> tags;
  int? downloaderId;
  String? downloaderCategory;
  List<MyRss> rssList;
  String? createdAt;
  String? updatedAt;

  Subscribe copyWith({
    int? id,
    String? name,
    String? keyword,
    List<String>? exclude,
    String? douban,
    String? imdb,
    String? tmdb,
    bool? available,
    bool? start,
    int? size,
    List<String>? discount,
    String? category,
    String? season,
    List<String>? publishYear,
    List<String>? resolution,
    List<String>? videoCodec,
    List<String>? audioCodec,
    List<String>? source,
    List<String>? publisher,
    List<String>? tags,
    int? downloaderId,
    String? downloaderCategory,
    List<MyRss>? rssList,
    String? createdAt,
    String? updatedAt,
  }) =>
      Subscribe(
        id: id ?? this.id,
        name: name ?? this.name,
        keyword: keyword ?? this.keyword,
        exclude: exclude ?? this.exclude,
        douban: douban ?? this.douban,
        imdb: imdb ?? this.imdb,
        tmdb: tmdb ?? this.tmdb,
        available: available ?? this.available,
        start: start ?? this.start,
        size: size ?? this.size,
        discount: discount ?? this.discount,
        category: category ?? this.category,
        season: season ?? this.season,
        publishYear: publishYear ?? this.publishYear,
        resolution: resolution ?? this.resolution,
        videoCodec: videoCodec ?? this.videoCodec,
        audioCodec: audioCodec ?? this.audioCodec,
        source: source ?? this.source,
        publisher: publisher ?? this.publisher,
        tags: tags ?? this.tags,
        downloaderId: downloaderId ?? this.downloaderId,
        downloaderCategory: downloaderCategory ?? this.downloaderCategory,
        rssList: rssList ?? this.rssList,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['keyword'] = keyword;
    map['exclude'] = exclude;
    map['douban'] = douban;
    map['imdb'] = imdb;
    map['tmdb'] = tmdb;
    map['available'] = available;
    map['start'] = start;
    map['size'] = size;
    map['discount'] = discount;
    map['category'] = category;
    map['season'] = season;
    map['publish_year'] = publishYear;
    map['resolution'] = resolution;
    map['video_codec'] = videoCodec;
    map['audio_codec'] = audioCodec;
    map['source'] = source;
    map['publisher'] = publisher;
    map['tags'] = tags;
    map['downloader_id'] = downloaderId;
    map['downloader_category'] = downloaderCategory;
    map['rss_list'] = rssList.map((v) => v.id).toList();
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

  @override
  String toString() {
    return '订阅信息：$name - $keyword';
  }
}
