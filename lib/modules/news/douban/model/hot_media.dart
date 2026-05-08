import 'package:freezed_annotation/freezed_annotation.dart';

part 'hot_media.freezed.dart';
part 'hot_media.g.dart';

@freezed
abstract class HotMedia with _$HotMedia {
  const factory HotMedia({
    @Default('') String title,
    @Default('') @JsonKey(name: 'url') String doubanUrl,
    @Default('') @JsonKey(name: 'cover') String poster,
    @Default(false) bool playable,
    @Default('') String id,
    @Default('') String rate,
    @Default(0) @JsonKey(name: 'cover_x') int coverX,
    @Default(0) @JsonKey(name: 'cover_y') int coverY,
    @Default(false) @JsonKey(name: 'is_new') bool isNew,
    @Default('') @JsonKey(name: 'episodes_info') String episodesInfo,
    @Default('') String cookie,
  }) = _HotMedia;

  factory HotMedia.fromJson(Map<String, dynamic> json) =>
      _$HotMediaFromJson(json);
}
