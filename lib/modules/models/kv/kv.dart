import 'package:freezed_annotation/freezed_annotation.dart';

part 'kv.freezed.dart';
part 'kv.g.dart';

@freezed
abstract class KV with _$KV {
  const factory KV({
    required String name,
    required num value,
  }) = _KV;

  factory KV.fromJson(Map<String, dynamic> json) =>
      _$KVFromJson(json);
}