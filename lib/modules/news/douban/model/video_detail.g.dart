// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DetailRating _$DetailRatingFromJson(Map<String, dynamic> json) =>
    _DetailRating(
      count: (json['count'] as num?)?.toInt() ?? 0,
      max: (json['max'] as num?)?.toInt() ?? 0,
      starCount: (json['star_count'] as num?)?.toDouble() ?? 0.0,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$DetailRatingToJson(_DetailRating instance) =>
    <String, dynamic>{
      'count': instance.count,
      'max': instance.max,
      'star_count': instance.starCount,
      'value': instance.value,
    };

_Person _$PersonFromJson(Map<String, dynamic> json) =>
    _Person(name: json['name'] as String? ?? '');

Map<String, dynamic> _$PersonToJson(_Person instance) => <String, dynamic>{
  'name': instance.name,
};

_Pic _$PicFromJson(Map<String, dynamic> json) => _Pic(
  large: json['large'] as String? ?? '',
  normal: json['normal'] as String? ?? '',
);

Map<String, dynamic> _$PicToJson(_Pic instance) => <String, dynamic>{
  'large': instance.large,
  'normal': instance.normal,
};

_Trailer _$TrailerFromJson(Map<String, dynamic> json) => _Trailer(
  coverUrl: json['cover_url'] as String? ?? '',
  title: json['title'] as String? ?? '',
  typeName: json['type_name'] as String? ?? '',
  videoUrl: json['video_url'] as String? ?? '',
  runtime: json['runtime'] as String? ?? '',
);

Map<String, dynamic> _$TrailerToJson(_Trailer instance) => <String, dynamic>{
  'cover_url': instance.coverUrl,
  'title': instance.title,
  'type_name': instance.typeName,
  'video_url': instance.videoUrl,
  'runtime': instance.runtime,
};

_Vendor _$VendorFromJson(Map<String, dynamic> json) => _Vendor(
  id: json['id'] as String? ?? '',
  title: json['title'] as String? ?? '',
  icon: json['icon'] as String? ?? '',
  greyIcon: json['grey_icon'] as String? ?? '',
  url: json['url'] as String? ?? '',
  episodesInfo: json['episodes_info'] as String? ?? '',
  paymentDesc: json['payment_desc'] as String? ?? '',
  accessible: json['accessible'] as bool? ?? false,
  isPaid: json['is_paid'] as bool? ?? false,
);

Map<String, dynamic> _$VendorToJson(_Vendor instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'icon': instance.icon,
  'grey_icon': instance.greyIcon,
  'url': instance.url,
  'episodes_info': instance.episodesInfo,
  'payment_desc': instance.paymentDesc,
  'accessible': instance.accessible,
  'is_paid': instance.isPaid,
};

_LinewatchSource _$LinewatchSourceFromJson(Map<String, dynamic> json) =>
    _LinewatchSource(
      literal: json['literal'] as String? ?? '',
      name: json['name'] as String? ?? '',
      pic: json['pic'] as String? ?? '',
    );

Map<String, dynamic> _$LinewatchSourceToJson(_LinewatchSource instance) =>
    <String, dynamic>{
      'literal': instance.literal,
      'name': instance.name,
      'pic': instance.pic,
    };

_Linewatch _$LinewatchFromJson(Map<String, dynamic> json) => _Linewatch(
  free: json['free'] as bool? ?? false,
  source: json['source'] == null
      ? const LinewatchSource()
      : LinewatchSource.fromJson(json['source'] as Map<String, dynamic>),
  url: json['url'] as String? ?? '',
);

Map<String, dynamic> _$LinewatchToJson(_Linewatch instance) =>
    <String, dynamic>{
      'free': instance.free,
      'source': instance.source.toJson(),
      'url': instance.url,
    };

_RealtimeHonor _$RealtimeHonorFromJson(Map<String, dynamic> json) =>
    _RealtimeHonor(
      kind: json['kind'] as String? ?? '',
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      uri: json['uri'] as String? ?? '',
    );

Map<String, dynamic> _$RealtimeHonorToJson(_RealtimeHonor instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'rank': instance.rank,
      'score': instance.score,
      'title': instance.title,
      'uri': instance.uri,
    };

_VideoDetail _$VideoDetailFromJson(Map<String, dynamic> json) => _VideoDetail(
  id: json['id'] as String? ?? '',
  title: json['title'] as String? ?? '',
  originalTitle: json['original_title'] as String? ?? '',
  year: json['year'] as String? ?? '',
  coverUrl: json['cover_url'] as String? ?? '',
  pic: json['pic'] == null
      ? const Pic()
      : Pic.fromJson(json['pic'] as Map<String, dynamic>),
  rating: json['rating'] == null
      ? const DetailRating()
      : DetailRating.fromJson(json['rating'] as Map<String, dynamic>),
  nullRatingReason: json['null_rating_reason'] as String? ?? '',
  actors:
      (json['actors'] as List<dynamic>?)
          ?.map((e) => Person.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Person>[],
  directors:
      (json['directors'] as List<dynamic>?)
          ?.map((e) => Person.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Person>[],
  aka:
      (json['aka'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  countries:
      (json['countries'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  languages:
      (json['languages'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  genres:
      (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  durations:
      (json['durations'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  pubdate:
      (json['pubdate'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  intro: json['intro'] as String? ?? '',
  cardSubtitle: json['card_subtitle'] as String? ?? '',
  isTv: json['is_tv'] as bool? ?? false,
  isReleased: json['is_released'] as bool? ?? false,
  hasLinewatch: json['has_linewatch'] as bool? ?? false,
  episodesCount: (json['episodes_count'] as num?)?.toInt() ?? 0,
  episodesInfo: json['episodes_info'] as String? ?? '',
  trailers:
      (json['trailers'] as List<dynamic>?)
          ?.map((e) => Trailer.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Trailer>[],
  vendors:
      (json['vendors'] as List<dynamic>?)
          ?.map((e) => Vendor.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Vendor>[],
  linewatches:
      (json['linewatches'] as List<dynamic>?)
          ?.map((e) => Linewatch.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Linewatch>[],
  realtimeHonorInfos:
      (json['realtime_hot_honor_infos'] as List<dynamic>?)
          ?.map((e) => RealtimeHonor.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RealtimeHonor>[],
  commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
  reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
  forumTopicCount: (json['forum_topic_count'] as num?)?.toInt() ?? 0,
  url: json['url'] as String? ?? '',
  sharingUrl: json['sharing_url'] as String? ?? '',
  type: json['type'] as String? ?? '',
  subtype: json['subtype'] as String? ?? '',
);

Map<String, dynamic> _$VideoDetailToJson(_VideoDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'original_title': instance.originalTitle,
      'year': instance.year,
      'cover_url': instance.coverUrl,
      'pic': instance.pic.toJson(),
      'rating': instance.rating.toJson(),
      'null_rating_reason': instance.nullRatingReason,
      'actors': instance.actors.map((e) => e.toJson()).toList(),
      'directors': instance.directors.map((e) => e.toJson()).toList(),
      'aka': instance.aka,
      'countries': instance.countries,
      'languages': instance.languages,
      'genres': instance.genres,
      'durations': instance.durations,
      'pubdate': instance.pubdate,
      'intro': instance.intro,
      'card_subtitle': instance.cardSubtitle,
      'is_tv': instance.isTv,
      'is_released': instance.isReleased,
      'has_linewatch': instance.hasLinewatch,
      'episodes_count': instance.episodesCount,
      'episodes_info': instance.episodesInfo,
      'trailers': instance.trailers.map((e) => e.toJson()).toList(),
      'vendors': instance.vendors.map((e) => e.toJson()).toList(),
      'linewatches': instance.linewatches.map((e) => e.toJson()).toList(),
      'realtime_hot_honor_infos': instance.realtimeHonorInfos
          .map((e) => e.toJson())
          .toList(),
      'comment_count': instance.commentCount,
      'review_count': instance.reviewCount,
      'forum_topic_count': instance.forumTopicCount,
      'url': instance.url,
      'sharing_url': instance.sharingUrl,
      'type': instance.type,
      'subtype': instance.subtype,
    };
