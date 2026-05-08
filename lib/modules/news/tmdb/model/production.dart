import 'package:freezed_annotation/freezed_annotation.dart';

part 'production.freezed.dart';
part 'production.g.dart';

@freezed
abstract class ProductionCompany with _$ProductionCompany {
  const factory ProductionCompany({
    @Default(0) int id,
    String? logoPath,
    @Default('') String name,
    @Default('') @JsonKey(name: 'origin_country') String originCountry,
  }) = _ProductionCompany;

  factory ProductionCompany.fromJson(Map<String, dynamic> json) =>
      _$ProductionCompanyFromJson(json);
}

@freezed
abstract class ProductionCountry with _$ProductionCountry {
  const factory ProductionCountry({
    @Default('') @JsonKey(name: 'iso_3166_1') String iso31661,
    @Default('') String name,
  }) = _ProductionCountry;

  factory ProductionCountry.fromJson(Map<String, dynamic> json) =>
      _$ProductionCountryFromJson(json);
}

@freezed
abstract class SpokenLanguage with _$SpokenLanguage {
  const factory SpokenLanguage({
    @Default('') @JsonKey(name: 'english_name') String englishName,
    @Default('') @JsonKey(name: 'iso_639_1') String iso6391,
    @Default('') String name,
  }) = _SpokenLanguage;

  factory SpokenLanguage.fromJson(Map<String, dynamic> json) =>
      _$SpokenLanguageFromJson(json);
}

@freezed
abstract class Network with _$Network {
  const factory Network({
    @Default(0) int id,
    @Default('') @JsonKey(name: 'logo_path') String logoPath,
    @Default('') String name,
    @Default('') @JsonKey(name: 'origin_country') String originCountry,
  }) = _Network;

  factory Network.fromJson(Map<String, dynamic> json) =>
      _$NetworkFromJson(json);
}
