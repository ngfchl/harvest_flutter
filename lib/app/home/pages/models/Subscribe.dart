import 'package:harvest/app/home/pages/models/MyRss.dart';

class Subscribe {
  Subscribe({
    num? id,
    String? name,
    String? keyword,
    List<String>? exclude,
    String? douban,
    String? imdb,
    String? tmdb,
    bool? available,
    bool? start,
    num? size,
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
    num? downloaderId,
    String? downloaderCategory,
    List<MyRss>? rssList,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _name = name;
    _keyword = keyword;
    _exclude = exclude;
    _douban = douban;
    _imdb = imdb;
    _tmdb = tmdb;
    _available = available;
    _start = start;
    _size = size;
    _discount = discount;
    _category = category;
    _season = season;
    _publishYear = publishYear;
    _resolution = resolution;
    _videoCodec = videoCodec;
    _audioCodec = audioCodec;
    _source = source;
    _publisher = publisher;
    _tags = tags;
    _downloaderId = downloaderId;
    _downloaderCategory = downloaderCategory;
    _rssList = rssList;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Subscribe.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _keyword = json['keyword'];
    if (json['exclude'] != null) {
      _exclude?.addAll(json['exclude']);
    }
    _douban = json['douban'];
    _imdb = json['imdb'];
    _tmdb = json['tmdb'];
    _available = json['available'];
    _start = json['start'];
    _size = json['size'];
    if (json['discount'] != null) {
      _discount?.addAll(json['discount']);
    }
    _category = json['category'];
    _season = json['season'];
    if (json['publish_year'] != null) {
      _publishYear?.addAll(json['publish_year']);
    }
    _resolution =
        json['resolution'] != null ? json['resolution'].cast<String>() : [];
    if (json['video_codec'] != null) {
      _videoCodec?.addAll(json['video_codec']);
    }
    if (json['audio_codec'] != null) {
      _audioCodec?.addAll(json['audio_codec']);
    }
    if (json['source'] != null) {
      _source?.addAll(json['source']);
    }
    if (json['publisher'] != null) {
      _publisher?.addAll(json['publisher']);
    }
    if (json['tags'] != null) {
      _tags?.addAll(json['tags']);
    }
    _downloaderId = json['downloader_id'];
    _downloaderCategory = json['downloader_category'];
    if (json['rss_list'] != null) {
      _rssList = [];
      json['rss_list'].forEach((v) {
        _rssList?.add(MyRss.fromJson(v));
      });
    }
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }

  num? _id;
  String? _name;
  String? _keyword;
  List<String>? _exclude;
  String? _douban;
  String? _imdb;
  String? _tmdb;
  bool? _available;
  bool? _start;
  num? _size;
  List<String>? _discount;
  String? _category;
  String? _season;
  List<String>? _publishYear;
  List<String>? _resolution;
  List<String>? _videoCodec;
  List<String>? _audioCodec;
  List<String>? _source;
  List<String>? _publisher;
  List<String>? _tags;
  num? _downloaderId;
  String? _downloaderCategory;
  List<MyRss>? _rssList;
  String? _createdAt;
  String? _updatedAt;

  Subscribe copyWith({
    num? id,
    String? name,
    String? keyword,
    List<String>? exclude,
    String? douban,
    String? imdb,
    String? tmdb,
    bool? available,
    bool? start,
    num? size,
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
    num? downloaderId,
    String? downloaderCategory,
    List<MyRss>? rssList,
    String? createdAt,
    String? updatedAt,
  }) =>
      Subscribe(
        id: id ?? _id,
        name: name ?? _name,
        keyword: keyword ?? _keyword,
        exclude: exclude ?? _exclude,
        douban: douban ?? _douban,
        imdb: imdb ?? _imdb,
        tmdb: tmdb ?? _tmdb,
        available: available ?? _available,
        start: start ?? _start,
        size: size ?? _size,
        discount: discount ?? _discount,
        category: category ?? _category,
        season: season ?? _season,
        publishYear: publishYear ?? _publishYear,
        resolution: resolution ?? _resolution,
        videoCodec: videoCodec ?? _videoCodec,
        audioCodec: audioCodec ?? _audioCodec,
        source: source ?? _source,
        publisher: publisher ?? _publisher,
        tags: tags ?? _tags,
        downloaderId: downloaderId ?? _downloaderId,
        downloaderCategory: downloaderCategory ?? _downloaderCategory,
        rssList: rssList ?? _rssList,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );

  num? get id => _id;

  String? get name => _name;

  String? get keyword => _keyword;

  List<dynamic>? get exclude => _exclude;

  dynamic get douban => _douban;

  dynamic get imdb => _imdb;

  dynamic get tmdb => _tmdb;

  bool? get available => _available;

  bool? get start => _start;

  num? get size => _size;

  List<dynamic>? get discount => _discount;

  String? get category => _category;

  String? get season => _season;

  List<dynamic>? get publishYear => _publishYear;

  List<String>? get resolution => _resolution;

  List<dynamic>? get videoCodec => _videoCodec;

  List<dynamic>? get audioCodec => _audioCodec;

  List<dynamic>? get source => _source;

  List<dynamic>? get publisher => _publisher;

  List<dynamic>? get tags => _tags;

  num? get downloaderId => _downloaderId;

  dynamic get downloaderCategory => _downloaderCategory;

  List<MyRss>? get rssList => _rssList;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['keyword'] = _keyword;
    if (_exclude != null) {
      map['exclude'] = _exclude?.map((v) => v.toString()).toList();
    }
    map['douban'] = _douban;
    map['imdb'] = _imdb;
    map['tmdb'] = _tmdb;
    map['available'] = _available;
    map['start'] = _start;
    map['size'] = _size;
    if (_discount != null) {
      map['discount'] = _discount?.map((v) => v.toString()).toList();
    }
    map['category'] = _category;
    map['season'] = _season;
    if (_publishYear != null) {
      map['publish_year'] = _publishYear?.map((v) => v.toString()).toList();
    }
    map['resolution'] = _resolution;
    if (_videoCodec != null) {
      map['video_codec'] = _videoCodec?.map((v) => v.toString()).toList();
    }
    if (_audioCodec != null) {
      map['audio_codec'] = _audioCodec?.map((v) => v.toString()).toList();
    }
    if (_source != null) {
      map['source'] = _source?.map((v) => v.toString()).toList();
    }
    if (_publisher != null) {
      map['publisher'] = _publisher?.map((v) => v.toString()).toList();
    }
    if (_tags != null) {
      map['tags'] = _tags?.map((v) => v.toString()).toList();
    }
    map['downloader_id'] = _downloaderId;
    map['downloader_category'] = _downloaderCategory;
    if (_rssList != null) {
      map['rss_list'] = _rssList?.map((v) => v.toJson()).toList();
    }
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}
