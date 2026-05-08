import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_detail.freezed.dart';
part 'video_detail.g.dart';

// ─── Rating ───

@freezed
abstract class DetailRating with _$DetailRating {
  const factory DetailRating({
    @Default(0) int count,
    @Default(0) int max,
    @Default(0.0) @JsonKey(name: 'star_count') double starCount,
    @Default(0.0) double value,
  }) = _DetailRating;

  factory DetailRating.fromJson(Map<String, dynamic> json) =>
      _$DetailRatingFromJson(json);
}

// ─── Person (演员/导演/编剧) ───

@freezed
abstract class Person with _$Person {
  const factory Person({@Default('') String name}) = _Person;

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
}

// ─── Pic ───

@freezed
abstract class Pic with _$Pic {
  const factory Pic({@Default('') String large, @Default('') String normal}) =
      _Pic;

  factory Pic.fromJson(Map<String, dynamic> json) => _$PicFromJson(json);
}

// ─── Trailer ───

@freezed
abstract class Trailer with _$Trailer {
  const factory Trailer({
    @Default('') @JsonKey(name: 'cover_url') String coverUrl,
    @Default('') String title,
    @Default('') @JsonKey(name: 'type_name') String typeName,
    @Default('') @JsonKey(name: 'video_url') String videoUrl,
    @Default('') String runtime,
  }) = _Trailer;

  factory Trailer.fromJson(Map<String, dynamic> json) =>
      _$TrailerFromJson(json);
}

// ─── Vendor (播放源) ───

@freezed
abstract class Vendor with _$Vendor {
  const factory Vendor({
    @Default('') String id,
    @Default('') String title,
    @Default('') String icon,
    @Default('') @JsonKey(name: 'grey_icon') String greyIcon,
    @Default('') String url,
    @Default('') @JsonKey(name: 'episodes_info') String episodesInfo,
    @Default('') @JsonKey(name: 'payment_desc') String paymentDesc,
    @Default(false) bool accessible,
    @Default(false) @JsonKey(name: 'is_paid') bool isPaid,
  }) = _Vendor;

  factory Vendor.fromJson(Map<String, dynamic> json) => _$VendorFromJson(json);
}

// ─── Linewatch ───

@freezed
abstract class LinewatchSource with _$LinewatchSource {
  const factory LinewatchSource({
    @Default('') String literal,
    @Default('') String name,
    @Default('') String pic,
  }) = _LinewatchSource;

  factory LinewatchSource.fromJson(Map<String, dynamic> json) =>
      _$LinewatchSourceFromJson(json);
}

@freezed
abstract class Linewatch with _$Linewatch {
  const factory Linewatch({
    @Default(false) bool free,
    @Default(LinewatchSource()) LinewatchSource source,
    @Default('') String url,
  }) = _Linewatch;

  factory Linewatch.fromJson(Map<String, dynamic> json) =>
      _$LinewatchFromJson(json);
}

// ─── RealtimeHonor ───

@freezed
abstract class RealtimeHonor with _$RealtimeHonor {
  const factory RealtimeHonor({
    @Default('') String kind,
    @Default(0) int rank,
    @Default(0) int score,
    @Default('') String title,
    @Default('') String uri,
  }) = _RealtimeHonor;

  factory RealtimeHonor.fromJson(Map<String, dynamic> json) =>
      _$RealtimeHonorFromJson(json);
}

// ─── VideoDetail (主 Model) ───

@freezed
abstract class VideoDetail with _$VideoDetail {
  const factory VideoDetail({
    @Default('') String id,
    @Default('') String title,
    @Default('') @JsonKey(name: 'original_title') String originalTitle,
    @Default('') String year,
    @Default('') @JsonKey(name: 'cover_url') String coverUrl,
    @Default(Pic()) Pic pic,
    @Default(DetailRating()) DetailRating rating,
    @Default('') @JsonKey(name: 'null_rating_reason') String nullRatingReason,
    @Default(<Person>[]) List<Person> actors,
    @Default(<Person>[]) List<Person> directors,
    @Default(<String>[]) List<String> aka,
    @Default(<String>[]) List<String> countries,
    @Default(<String>[]) List<String> languages,
    @Default(<String>[]) List<String> genres,
    @Default(<String>[]) List<String> durations,
    @Default(<String>[]) List<String> pubdate,
    @Default('') String intro,
    @Default('') @JsonKey(name: 'card_subtitle') String cardSubtitle,
    @Default(false) @JsonKey(name: 'is_tv') bool isTv,
    @Default(false) @JsonKey(name: 'is_released') bool isReleased,
    @Default(false) @JsonKey(name: 'has_linewatch') bool hasLinewatch,
    @Default(0) @JsonKey(name: 'episodes_count') int episodesCount,
    @Default('') @JsonKey(name: 'episodes_info') String episodesInfo,
    @Default(<Trailer>[]) List<Trailer> trailers,
    @Default(<Vendor>[]) List<Vendor> vendors,
    @Default(<Linewatch>[]) List<Linewatch> linewatches,
    @Default(<RealtimeHonor>[])
    @JsonKey(name: 'realtime_hot_honor_infos')
    List<RealtimeHonor> realtimeHonorInfos,
    @Default(0) @JsonKey(name: 'comment_count') int commentCount,
    @Default(0) @JsonKey(name: 'review_count') int reviewCount,
    @Default(0) @JsonKey(name: 'forum_topic_count') int forumTopicCount,
    @Default('') String url,
    @Default('') @JsonKey(name: 'sharing_url') String sharingUrl,
    @Default('') String type,
    @Default('') String subtype,
  }) = _VideoDetail;

  factory VideoDetail.fromJson(Map<String, dynamic> json) =>
      _$VideoDetailFromJson(json);
}
