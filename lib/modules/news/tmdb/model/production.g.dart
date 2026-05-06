// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'production.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductionCompany _$ProductionCompanyFromJson(Map<String, dynamic> json) =>
    _ProductionCompany(
      id: (json['id'] as num?)?.toInt() ?? 0,
      logoPath: json['logoPath'] as String?,
      name: json['name'] as String? ?? '',
      originCountry: json['origin_country'] as String? ?? '',
    );

Map<String, dynamic> _$ProductionCompanyToJson(_ProductionCompany instance) =>
    <String, dynamic>{
      'id': instance.id,
      'logoPath': instance.logoPath,
      'name': instance.name,
      'origin_country': instance.originCountry,
    };

_ProductionCountry _$ProductionCountryFromJson(Map<String, dynamic> json) =>
    _ProductionCountry(
      iso31661: json['iso_3166_1'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );

Map<String, dynamic> _$ProductionCountryToJson(_ProductionCountry instance) =>
    <String, dynamic>{'iso_3166_1': instance.iso31661, 'name': instance.name};

_SpokenLanguage _$SpokenLanguageFromJson(Map<String, dynamic> json) =>
    _SpokenLanguage(
      englishName: json['english_name'] as String? ?? '',
      iso6391: json['iso_639_1'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );

Map<String, dynamic> _$SpokenLanguageToJson(_SpokenLanguage instance) =>
    <String, dynamic>{
      'english_name': instance.englishName,
      'iso_639_1': instance.iso6391,
      'name': instance.name,
    };

_Network _$NetworkFromJson(Map<String, dynamic> json) => _Network(
  id: (json['id'] as num?)?.toInt() ?? 0,
  logoPath: json['logo_path'] as String? ?? '',
  name: json['name'] as String? ?? '',
  originCountry: json['origin_country'] as String? ?? '',
);

Map<String, dynamic> _$NetworkToJson(_Network instance) => <String, dynamic>{
  'id': instance.id,
  'logo_path': instance.logoPath,
  'name': instance.name,
  'origin_country': instance.originCountry,
};
