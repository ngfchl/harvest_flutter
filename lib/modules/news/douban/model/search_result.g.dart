// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DoubanRating _$DoubanRatingFromJson(Map<String, dynamic> json) =>
    _DoubanRating(
      count: (json['count'] as num?)?.toInt() ?? 0,
      max: (json['max'] as num?)?.toInt() ?? 0,
      starCount: (json['star_count'] as num?)?.toDouble() ?? 0.0,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$DoubanRatingToJson(_DoubanRating instance) =>
    <String, dynamic>{
      'count': instance.count,
      'max': instance.max,
      'star_count': instance.starCount,
      'value': instance.value,
    };

_SearchTarget _$SearchTargetFromJson(Map<String, dynamic> json) =>
    _SearchTarget(
      abstract: json['abstract'] as String? ?? '',
      cardSubtitle: json['card_subtitle'] as String? ?? '',
      controversyReason: json['controversy_reason'] as String? ?? '',
      coverUrl: json['cover_url'] as String? ?? '',
      hasLinewatch: json['has_linewatch'] as bool? ?? false,
      id: json['id'] as String? ?? '',
      nullRatingReason: json['null_rating_reason'] as String? ?? '',
      rating: json['rating'] == null
          ? const DoubanRating()
          : DoubanRating.fromJson(json['rating'] as Map<String, dynamic>),
      title: json['title'] as String? ?? '',
      uri: json['uri'] as String? ?? '',
      year: json['year'] as String? ?? '',
    );

Map<String, dynamic> _$SearchTargetToJson(_SearchTarget instance) =>
    <String, dynamic>{
      'abstract': instance.abstract,
      'card_subtitle': instance.cardSubtitle,
      'controversy_reason': instance.controversyReason,
      'cover_url': instance.coverUrl,
      'has_linewatch': instance.hasLinewatch,
      'id': instance.id,
      'null_rating_reason': instance.nullRatingReason,
      'rating': instance.rating.toJson(),
      'title': instance.title,
      'uri': instance.uri,
      'year': instance.year,
    };

_DoubanSearchResult _$DoubanSearchResultFromJson(Map<String, dynamic> json) =>
    _DoubanSearchResult(
      layout: json['layout'] as String? ?? '',
      target: json['target'] == null
          ? const SearchTarget()
          : SearchTarget.fromJson(json['target'] as Map<String, dynamic>),
      targetId: json['target_id'] as String? ?? '',
      targetType: json['target_type'] as String? ?? '',
      typeName: json['type_name'] as String? ?? '',
    );

Map<String, dynamic> _$DoubanSearchResultToJson(_DoubanSearchResult instance) =>
    <String, dynamic>{
      'layout': instance.layout,
      'target': instance.target.toJson(),
      'target_id': instance.targetId,
      'target_type': instance.targetType,
      'type_name': instance.typeName,
    };
