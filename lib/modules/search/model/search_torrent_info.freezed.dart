// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_torrent_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SearchTorrentInfo {

@JsonKey(name: 'site_id', fromJson: _toString) String get siteId;@JsonKey(fromJson: _toString) String get tid;@JsonKey(fromJson: _toString) String get poster; String get category;@JsonKey(name: 'magnet_url', fromJson: _toString) String get magnetUrl;@JsonKey(name: 'detail_url', fromJson: _toString) String get detailUrl;@JsonKey(fromJson: _toString) String get title;@JsonKey(fromJson: _toString) String get subtitle;@JsonKey(fromJson: _toString) String? get cookie;@JsonKey(fromJson: _toDoubleOrNull) double? get progress;@JsonKey(name: 'sale_status') String get saleStatus;@JsonKey(name: 'sale_expire') String? get saleExpire; List<String> get tags; bool get hr;@JsonKey(fromJson: _toString) String get published;@JsonKey(fromJson: _toInt) int get size;@JsonKey(fromJson: _toInt) int get seeders;@JsonKey(fromJson: _toInt) int get leechers;@JsonKey(fromJson: _toInt) int get completers;
/// Create a copy of SearchTorrentInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchTorrentInfoCopyWith<SearchTorrentInfo> get copyWith => _$SearchTorrentInfoCopyWithImpl<SearchTorrentInfo>(this as SearchTorrentInfo, _$identity);

  /// Serializes this SearchTorrentInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchTorrentInfo&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.tid, tid) || other.tid == tid)&&(identical(other.poster, poster) || other.poster == poster)&&(identical(other.category, category) || other.category == category)&&(identical(other.magnetUrl, magnetUrl) || other.magnetUrl == magnetUrl)&&(identical(other.detailUrl, detailUrl) || other.detailUrl == detailUrl)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.cookie, cookie) || other.cookie == cookie)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.saleStatus, saleStatus) || other.saleStatus == saleStatus)&&(identical(other.saleExpire, saleExpire) || other.saleExpire == saleExpire)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.hr, hr) || other.hr == hr)&&(identical(other.published, published) || other.published == published)&&(identical(other.size, size) || other.size == size)&&(identical(other.seeders, seeders) || other.seeders == seeders)&&(identical(other.leechers, leechers) || other.leechers == leechers)&&(identical(other.completers, completers) || other.completers == completers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,siteId,tid,poster,category,magnetUrl,detailUrl,title,subtitle,cookie,progress,saleStatus,saleExpire,const DeepCollectionEquality().hash(tags),hr,published,size,seeders,leechers,completers]);

@override
String toString() {
  return 'SearchTorrentInfo(siteId: $siteId, tid: $tid, poster: $poster, category: $category, magnetUrl: $magnetUrl, detailUrl: $detailUrl, title: $title, subtitle: $subtitle, cookie: $cookie, progress: $progress, saleStatus: $saleStatus, saleExpire: $saleExpire, tags: $tags, hr: $hr, published: $published, size: $size, seeders: $seeders, leechers: $leechers, completers: $completers)';
}


}

/// @nodoc
abstract mixin class $SearchTorrentInfoCopyWith<$Res>  {
  factory $SearchTorrentInfoCopyWith(SearchTorrentInfo value, $Res Function(SearchTorrentInfo) _then) = _$SearchTorrentInfoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'site_id', fromJson: _toString) String siteId,@JsonKey(fromJson: _toString) String tid,@JsonKey(fromJson: _toString) String poster, String category,@JsonKey(name: 'magnet_url', fromJson: _toString) String magnetUrl,@JsonKey(name: 'detail_url', fromJson: _toString) String detailUrl,@JsonKey(fromJson: _toString) String title,@JsonKey(fromJson: _toString) String subtitle,@JsonKey(fromJson: _toString) String? cookie,@JsonKey(fromJson: _toDoubleOrNull) double? progress,@JsonKey(name: 'sale_status') String saleStatus,@JsonKey(name: 'sale_expire') String? saleExpire, List<String> tags, bool hr,@JsonKey(fromJson: _toString) String published,@JsonKey(fromJson: _toInt) int size,@JsonKey(fromJson: _toInt) int seeders,@JsonKey(fromJson: _toInt) int leechers,@JsonKey(fromJson: _toInt) int completers
});




}
/// @nodoc
class _$SearchTorrentInfoCopyWithImpl<$Res>
    implements $SearchTorrentInfoCopyWith<$Res> {
  _$SearchTorrentInfoCopyWithImpl(this._self, this._then);

  final SearchTorrentInfo _self;
  final $Res Function(SearchTorrentInfo) _then;

/// Create a copy of SearchTorrentInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? siteId = null,Object? tid = null,Object? poster = null,Object? category = null,Object? magnetUrl = null,Object? detailUrl = null,Object? title = null,Object? subtitle = null,Object? cookie = freezed,Object? progress = freezed,Object? saleStatus = null,Object? saleExpire = freezed,Object? tags = null,Object? hr = null,Object? published = null,Object? size = null,Object? seeders = null,Object? leechers = null,Object? completers = null,}) {
  return _then(_self.copyWith(
siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,tid: null == tid ? _self.tid : tid // ignore: cast_nullable_to_non_nullable
as String,poster: null == poster ? _self.poster : poster // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,magnetUrl: null == magnetUrl ? _self.magnetUrl : magnetUrl // ignore: cast_nullable_to_non_nullable
as String,detailUrl: null == detailUrl ? _self.detailUrl : detailUrl // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,cookie: freezed == cookie ? _self.cookie : cookie // ignore: cast_nullable_to_non_nullable
as String?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,saleStatus: null == saleStatus ? _self.saleStatus : saleStatus // ignore: cast_nullable_to_non_nullable
as String,saleExpire: freezed == saleExpire ? _self.saleExpire : saleExpire // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,hr: null == hr ? _self.hr : hr // ignore: cast_nullable_to_non_nullable
as bool,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,seeders: null == seeders ? _self.seeders : seeders // ignore: cast_nullable_to_non_nullable
as int,leechers: null == leechers ? _self.leechers : leechers // ignore: cast_nullable_to_non_nullable
as int,completers: null == completers ? _self.completers : completers // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchTorrentInfo].
extension SearchTorrentInfoPatterns on SearchTorrentInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchTorrentInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchTorrentInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchTorrentInfo value)  $default,){
final _that = this;
switch (_that) {
case _SearchTorrentInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchTorrentInfo value)?  $default,){
final _that = this;
switch (_that) {
case _SearchTorrentInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'site_id', fromJson: _toString)  String siteId, @JsonKey(fromJson: _toString)  String tid, @JsonKey(fromJson: _toString)  String poster,  String category, @JsonKey(name: 'magnet_url', fromJson: _toString)  String magnetUrl, @JsonKey(name: 'detail_url', fromJson: _toString)  String detailUrl, @JsonKey(fromJson: _toString)  String title, @JsonKey(fromJson: _toString)  String subtitle, @JsonKey(fromJson: _toString)  String? cookie, @JsonKey(fromJson: _toDoubleOrNull)  double? progress, @JsonKey(name: 'sale_status')  String saleStatus, @JsonKey(name: 'sale_expire')  String? saleExpire,  List<String> tags,  bool hr, @JsonKey(fromJson: _toString)  String published, @JsonKey(fromJson: _toInt)  int size, @JsonKey(fromJson: _toInt)  int seeders, @JsonKey(fromJson: _toInt)  int leechers, @JsonKey(fromJson: _toInt)  int completers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchTorrentInfo() when $default != null:
return $default(_that.siteId,_that.tid,_that.poster,_that.category,_that.magnetUrl,_that.detailUrl,_that.title,_that.subtitle,_that.cookie,_that.progress,_that.saleStatus,_that.saleExpire,_that.tags,_that.hr,_that.published,_that.size,_that.seeders,_that.leechers,_that.completers);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'site_id', fromJson: _toString)  String siteId, @JsonKey(fromJson: _toString)  String tid, @JsonKey(fromJson: _toString)  String poster,  String category, @JsonKey(name: 'magnet_url', fromJson: _toString)  String magnetUrl, @JsonKey(name: 'detail_url', fromJson: _toString)  String detailUrl, @JsonKey(fromJson: _toString)  String title, @JsonKey(fromJson: _toString)  String subtitle, @JsonKey(fromJson: _toString)  String? cookie, @JsonKey(fromJson: _toDoubleOrNull)  double? progress, @JsonKey(name: 'sale_status')  String saleStatus, @JsonKey(name: 'sale_expire')  String? saleExpire,  List<String> tags,  bool hr, @JsonKey(fromJson: _toString)  String published, @JsonKey(fromJson: _toInt)  int size, @JsonKey(fromJson: _toInt)  int seeders, @JsonKey(fromJson: _toInt)  int leechers, @JsonKey(fromJson: _toInt)  int completers)  $default,) {final _that = this;
switch (_that) {
case _SearchTorrentInfo():
return $default(_that.siteId,_that.tid,_that.poster,_that.category,_that.magnetUrl,_that.detailUrl,_that.title,_that.subtitle,_that.cookie,_that.progress,_that.saleStatus,_that.saleExpire,_that.tags,_that.hr,_that.published,_that.size,_that.seeders,_that.leechers,_that.completers);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'site_id', fromJson: _toString)  String siteId, @JsonKey(fromJson: _toString)  String tid, @JsonKey(fromJson: _toString)  String poster,  String category, @JsonKey(name: 'magnet_url', fromJson: _toString)  String magnetUrl, @JsonKey(name: 'detail_url', fromJson: _toString)  String detailUrl, @JsonKey(fromJson: _toString)  String title, @JsonKey(fromJson: _toString)  String subtitle, @JsonKey(fromJson: _toString)  String? cookie, @JsonKey(fromJson: _toDoubleOrNull)  double? progress, @JsonKey(name: 'sale_status')  String saleStatus, @JsonKey(name: 'sale_expire')  String? saleExpire,  List<String> tags,  bool hr, @JsonKey(fromJson: _toString)  String published, @JsonKey(fromJson: _toInt)  int size, @JsonKey(fromJson: _toInt)  int seeders, @JsonKey(fromJson: _toInt)  int leechers, @JsonKey(fromJson: _toInt)  int completers)?  $default,) {final _that = this;
switch (_that) {
case _SearchTorrentInfo() when $default != null:
return $default(_that.siteId,_that.tid,_that.poster,_that.category,_that.magnetUrl,_that.detailUrl,_that.title,_that.subtitle,_that.cookie,_that.progress,_that.saleStatus,_that.saleExpire,_that.tags,_that.hr,_that.published,_that.size,_that.seeders,_that.leechers,_that.completers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SearchTorrentInfo implements SearchTorrentInfo {
  const _SearchTorrentInfo({@JsonKey(name: 'site_id', fromJson: _toString) this.siteId = '', @JsonKey(fromJson: _toString) this.tid = '', @JsonKey(fromJson: _toString) this.poster = '', this.category = '', @JsonKey(name: 'magnet_url', fromJson: _toString) this.magnetUrl = '', @JsonKey(name: 'detail_url', fromJson: _toString) this.detailUrl = '', @JsonKey(fromJson: _toString) this.title = '', @JsonKey(fromJson: _toString) this.subtitle = '', @JsonKey(fromJson: _toString) this.cookie, @JsonKey(fromJson: _toDoubleOrNull) this.progress, @JsonKey(name: 'sale_status') this.saleStatus = '无优惠', @JsonKey(name: 'sale_expire') this.saleExpire, final  List<String> tags = const [], this.hr = false, @JsonKey(fromJson: _toString) this.published = '', @JsonKey(fromJson: _toInt) this.size = 0, @JsonKey(fromJson: _toInt) this.seeders = 0, @JsonKey(fromJson: _toInt) this.leechers = 0, @JsonKey(fromJson: _toInt) this.completers = 0}): _tags = tags;
  factory _SearchTorrentInfo.fromJson(Map<String, dynamic> json) => _$SearchTorrentInfoFromJson(json);

@override@JsonKey(name: 'site_id', fromJson: _toString) final  String siteId;
@override@JsonKey(fromJson: _toString) final  String tid;
@override@JsonKey(fromJson: _toString) final  String poster;
@override@JsonKey() final  String category;
@override@JsonKey(name: 'magnet_url', fromJson: _toString) final  String magnetUrl;
@override@JsonKey(name: 'detail_url', fromJson: _toString) final  String detailUrl;
@override@JsonKey(fromJson: _toString) final  String title;
@override@JsonKey(fromJson: _toString) final  String subtitle;
@override@JsonKey(fromJson: _toString) final  String? cookie;
@override@JsonKey(fromJson: _toDoubleOrNull) final  double? progress;
@override@JsonKey(name: 'sale_status') final  String saleStatus;
@override@JsonKey(name: 'sale_expire') final  String? saleExpire;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey() final  bool hr;
@override@JsonKey(fromJson: _toString) final  String published;
@override@JsonKey(fromJson: _toInt) final  int size;
@override@JsonKey(fromJson: _toInt) final  int seeders;
@override@JsonKey(fromJson: _toInt) final  int leechers;
@override@JsonKey(fromJson: _toInt) final  int completers;

/// Create a copy of SearchTorrentInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchTorrentInfoCopyWith<_SearchTorrentInfo> get copyWith => __$SearchTorrentInfoCopyWithImpl<_SearchTorrentInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchTorrentInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchTorrentInfo&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.tid, tid) || other.tid == tid)&&(identical(other.poster, poster) || other.poster == poster)&&(identical(other.category, category) || other.category == category)&&(identical(other.magnetUrl, magnetUrl) || other.magnetUrl == magnetUrl)&&(identical(other.detailUrl, detailUrl) || other.detailUrl == detailUrl)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.cookie, cookie) || other.cookie == cookie)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.saleStatus, saleStatus) || other.saleStatus == saleStatus)&&(identical(other.saleExpire, saleExpire) || other.saleExpire == saleExpire)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.hr, hr) || other.hr == hr)&&(identical(other.published, published) || other.published == published)&&(identical(other.size, size) || other.size == size)&&(identical(other.seeders, seeders) || other.seeders == seeders)&&(identical(other.leechers, leechers) || other.leechers == leechers)&&(identical(other.completers, completers) || other.completers == completers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,siteId,tid,poster,category,magnetUrl,detailUrl,title,subtitle,cookie,progress,saleStatus,saleExpire,const DeepCollectionEquality().hash(_tags),hr,published,size,seeders,leechers,completers]);

@override
String toString() {
  return 'SearchTorrentInfo(siteId: $siteId, tid: $tid, poster: $poster, category: $category, magnetUrl: $magnetUrl, detailUrl: $detailUrl, title: $title, subtitle: $subtitle, cookie: $cookie, progress: $progress, saleStatus: $saleStatus, saleExpire: $saleExpire, tags: $tags, hr: $hr, published: $published, size: $size, seeders: $seeders, leechers: $leechers, completers: $completers)';
}


}

/// @nodoc
abstract mixin class _$SearchTorrentInfoCopyWith<$Res> implements $SearchTorrentInfoCopyWith<$Res> {
  factory _$SearchTorrentInfoCopyWith(_SearchTorrentInfo value, $Res Function(_SearchTorrentInfo) _then) = __$SearchTorrentInfoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'site_id', fromJson: _toString) String siteId,@JsonKey(fromJson: _toString) String tid,@JsonKey(fromJson: _toString) String poster, String category,@JsonKey(name: 'magnet_url', fromJson: _toString) String magnetUrl,@JsonKey(name: 'detail_url', fromJson: _toString) String detailUrl,@JsonKey(fromJson: _toString) String title,@JsonKey(fromJson: _toString) String subtitle,@JsonKey(fromJson: _toString) String? cookie,@JsonKey(fromJson: _toDoubleOrNull) double? progress,@JsonKey(name: 'sale_status') String saleStatus,@JsonKey(name: 'sale_expire') String? saleExpire, List<String> tags, bool hr,@JsonKey(fromJson: _toString) String published,@JsonKey(fromJson: _toInt) int size,@JsonKey(fromJson: _toInt) int seeders,@JsonKey(fromJson: _toInt) int leechers,@JsonKey(fromJson: _toInt) int completers
});




}
/// @nodoc
class __$SearchTorrentInfoCopyWithImpl<$Res>
    implements _$SearchTorrentInfoCopyWith<$Res> {
  __$SearchTorrentInfoCopyWithImpl(this._self, this._then);

  final _SearchTorrentInfo _self;
  final $Res Function(_SearchTorrentInfo) _then;

/// Create a copy of SearchTorrentInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? siteId = null,Object? tid = null,Object? poster = null,Object? category = null,Object? magnetUrl = null,Object? detailUrl = null,Object? title = null,Object? subtitle = null,Object? cookie = freezed,Object? progress = freezed,Object? saleStatus = null,Object? saleExpire = freezed,Object? tags = null,Object? hr = null,Object? published = null,Object? size = null,Object? seeders = null,Object? leechers = null,Object? completers = null,}) {
  return _then(_SearchTorrentInfo(
siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,tid: null == tid ? _self.tid : tid // ignore: cast_nullable_to_non_nullable
as String,poster: null == poster ? _self.poster : poster // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,magnetUrl: null == magnetUrl ? _self.magnetUrl : magnetUrl // ignore: cast_nullable_to_non_nullable
as String,detailUrl: null == detailUrl ? _self.detailUrl : detailUrl // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,cookie: freezed == cookie ? _self.cookie : cookie // ignore: cast_nullable_to_non_nullable
as String?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,saleStatus: null == saleStatus ? _self.saleStatus : saleStatus // ignore: cast_nullable_to_non_nullable
as String,saleExpire: freezed == saleExpire ? _self.saleExpire : saleExpire // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,hr: null == hr ? _self.hr : hr // ignore: cast_nullable_to_non_nullable
as bool,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,seeders: null == seeders ? _self.seeders : seeders // ignore: cast_nullable_to_non_nullable
as int,leechers: null == leechers ? _self.leechers : leechers // ignore: cast_nullable_to_non_nullable
as int,completers: null == completers ? _self.completers : completers // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
