// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DoubanRating {

 int get count; int get max;@JsonKey(name: 'star_count') double get starCount; double get value;
/// Create a copy of DoubanRating
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoubanRatingCopyWith<DoubanRating> get copyWith => _$DoubanRatingCopyWithImpl<DoubanRating>(this as DoubanRating, _$identity);

  /// Serializes this DoubanRating to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoubanRating&&(identical(other.count, count) || other.count == count)&&(identical(other.max, max) || other.max == max)&&(identical(other.starCount, starCount) || other.starCount == starCount)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,max,starCount,value);

@override
String toString() {
  return 'DoubanRating(count: $count, max: $max, starCount: $starCount, value: $value)';
}


}

/// @nodoc
abstract mixin class $DoubanRatingCopyWith<$Res>  {
  factory $DoubanRatingCopyWith(DoubanRating value, $Res Function(DoubanRating) _then) = _$DoubanRatingCopyWithImpl;
@useResult
$Res call({
 int count, int max,@JsonKey(name: 'star_count') double starCount, double value
});




}
/// @nodoc
class _$DoubanRatingCopyWithImpl<$Res>
    implements $DoubanRatingCopyWith<$Res> {
  _$DoubanRatingCopyWithImpl(this._self, this._then);

  final DoubanRating _self;
  final $Res Function(DoubanRating) _then;

/// Create a copy of DoubanRating
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? max = null,Object? starCount = null,Object? value = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as int,starCount: null == starCount ? _self.starCount : starCount // ignore: cast_nullable_to_non_nullable
as double,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [DoubanRating].
extension DoubanRatingPatterns on DoubanRating {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoubanRating value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoubanRating() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoubanRating value)  $default,){
final _that = this;
switch (_that) {
case _DoubanRating():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoubanRating value)?  $default,){
final _that = this;
switch (_that) {
case _DoubanRating() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count,  int max, @JsonKey(name: 'star_count')  double starCount,  double value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoubanRating() when $default != null:
return $default(_that.count,_that.max,_that.starCount,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count,  int max, @JsonKey(name: 'star_count')  double starCount,  double value)  $default,) {final _that = this;
switch (_that) {
case _DoubanRating():
return $default(_that.count,_that.max,_that.starCount,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count,  int max, @JsonKey(name: 'star_count')  double starCount,  double value)?  $default,) {final _that = this;
switch (_that) {
case _DoubanRating() when $default != null:
return $default(_that.count,_that.max,_that.starCount,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DoubanRating implements DoubanRating {
  const _DoubanRating({this.count = 0, this.max = 0, @JsonKey(name: 'star_count') this.starCount = 0.0, this.value = 0.0});
  factory _DoubanRating.fromJson(Map<String, dynamic> json) => _$DoubanRatingFromJson(json);

@override@JsonKey() final  int count;
@override@JsonKey() final  int max;
@override@JsonKey(name: 'star_count') final  double starCount;
@override@JsonKey() final  double value;

/// Create a copy of DoubanRating
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoubanRatingCopyWith<_DoubanRating> get copyWith => __$DoubanRatingCopyWithImpl<_DoubanRating>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DoubanRatingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoubanRating&&(identical(other.count, count) || other.count == count)&&(identical(other.max, max) || other.max == max)&&(identical(other.starCount, starCount) || other.starCount == starCount)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,max,starCount,value);

@override
String toString() {
  return 'DoubanRating(count: $count, max: $max, starCount: $starCount, value: $value)';
}


}

/// @nodoc
abstract mixin class _$DoubanRatingCopyWith<$Res> implements $DoubanRatingCopyWith<$Res> {
  factory _$DoubanRatingCopyWith(_DoubanRating value, $Res Function(_DoubanRating) _then) = __$DoubanRatingCopyWithImpl;
@override @useResult
$Res call({
 int count, int max,@JsonKey(name: 'star_count') double starCount, double value
});




}
/// @nodoc
class __$DoubanRatingCopyWithImpl<$Res>
    implements _$DoubanRatingCopyWith<$Res> {
  __$DoubanRatingCopyWithImpl(this._self, this._then);

  final _DoubanRating _self;
  final $Res Function(_DoubanRating) _then;

/// Create a copy of DoubanRating
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? max = null,Object? starCount = null,Object? value = null,}) {
  return _then(_DoubanRating(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as int,starCount: null == starCount ? _self.starCount : starCount // ignore: cast_nullable_to_non_nullable
as double,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$SearchTarget {

 String get abstract;@JsonKey(name: 'card_subtitle') String get cardSubtitle;@JsonKey(name: 'controversy_reason') String get controversyReason;@JsonKey(name: 'cover_url') String get coverUrl;@JsonKey(name: 'has_linewatch') bool get hasLinewatch; String get id;@JsonKey(name: 'null_rating_reason') String get nullRatingReason; DoubanRating get rating; String get title; String get uri; String get year;
/// Create a copy of SearchTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchTargetCopyWith<SearchTarget> get copyWith => _$SearchTargetCopyWithImpl<SearchTarget>(this as SearchTarget, _$identity);

  /// Serializes this SearchTarget to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchTarget&&(identical(other.abstract, abstract) || other.abstract == abstract)&&(identical(other.cardSubtitle, cardSubtitle) || other.cardSubtitle == cardSubtitle)&&(identical(other.controversyReason, controversyReason) || other.controversyReason == controversyReason)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.hasLinewatch, hasLinewatch) || other.hasLinewatch == hasLinewatch)&&(identical(other.id, id) || other.id == id)&&(identical(other.nullRatingReason, nullRatingReason) || other.nullRatingReason == nullRatingReason)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.title, title) || other.title == title)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.year, year) || other.year == year));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,abstract,cardSubtitle,controversyReason,coverUrl,hasLinewatch,id,nullRatingReason,rating,title,uri,year);

@override
String toString() {
  return 'SearchTarget(abstract: $abstract, cardSubtitle: $cardSubtitle, controversyReason: $controversyReason, coverUrl: $coverUrl, hasLinewatch: $hasLinewatch, id: $id, nullRatingReason: $nullRatingReason, rating: $rating, title: $title, uri: $uri, year: $year)';
}


}

/// @nodoc
abstract mixin class $SearchTargetCopyWith<$Res>  {
  factory $SearchTargetCopyWith(SearchTarget value, $Res Function(SearchTarget) _then) = _$SearchTargetCopyWithImpl;
@useResult
$Res call({
 String abstract,@JsonKey(name: 'card_subtitle') String cardSubtitle,@JsonKey(name: 'controversy_reason') String controversyReason,@JsonKey(name: 'cover_url') String coverUrl,@JsonKey(name: 'has_linewatch') bool hasLinewatch, String id,@JsonKey(name: 'null_rating_reason') String nullRatingReason, DoubanRating rating, String title, String uri, String year
});


$DoubanRatingCopyWith<$Res> get rating;

}
/// @nodoc
class _$SearchTargetCopyWithImpl<$Res>
    implements $SearchTargetCopyWith<$Res> {
  _$SearchTargetCopyWithImpl(this._self, this._then);

  final SearchTarget _self;
  final $Res Function(SearchTarget) _then;

/// Create a copy of SearchTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? abstract = null,Object? cardSubtitle = null,Object? controversyReason = null,Object? coverUrl = null,Object? hasLinewatch = null,Object? id = null,Object? nullRatingReason = null,Object? rating = null,Object? title = null,Object? uri = null,Object? year = null,}) {
  return _then(_self.copyWith(
abstract: null == abstract ? _self.abstract : abstract // ignore: cast_nullable_to_non_nullable
as String,cardSubtitle: null == cardSubtitle ? _self.cardSubtitle : cardSubtitle // ignore: cast_nullable_to_non_nullable
as String,controversyReason: null == controversyReason ? _self.controversyReason : controversyReason // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,hasLinewatch: null == hasLinewatch ? _self.hasLinewatch : hasLinewatch // ignore: cast_nullable_to_non_nullable
as bool,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nullRatingReason: null == nullRatingReason ? _self.nullRatingReason : nullRatingReason // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as DoubanRating,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of SearchTarget
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DoubanRatingCopyWith<$Res> get rating {
  
  return $DoubanRatingCopyWith<$Res>(_self.rating, (value) {
    return _then(_self.copyWith(rating: value));
  });
}
}


/// Adds pattern-matching-related methods to [SearchTarget].
extension SearchTargetPatterns on SearchTarget {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchTarget value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchTarget() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchTarget value)  $default,){
final _that = this;
switch (_that) {
case _SearchTarget():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchTarget value)?  $default,){
final _that = this;
switch (_that) {
case _SearchTarget() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String abstract, @JsonKey(name: 'card_subtitle')  String cardSubtitle, @JsonKey(name: 'controversy_reason')  String controversyReason, @JsonKey(name: 'cover_url')  String coverUrl, @JsonKey(name: 'has_linewatch')  bool hasLinewatch,  String id, @JsonKey(name: 'null_rating_reason')  String nullRatingReason,  DoubanRating rating,  String title,  String uri,  String year)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchTarget() when $default != null:
return $default(_that.abstract,_that.cardSubtitle,_that.controversyReason,_that.coverUrl,_that.hasLinewatch,_that.id,_that.nullRatingReason,_that.rating,_that.title,_that.uri,_that.year);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String abstract, @JsonKey(name: 'card_subtitle')  String cardSubtitle, @JsonKey(name: 'controversy_reason')  String controversyReason, @JsonKey(name: 'cover_url')  String coverUrl, @JsonKey(name: 'has_linewatch')  bool hasLinewatch,  String id, @JsonKey(name: 'null_rating_reason')  String nullRatingReason,  DoubanRating rating,  String title,  String uri,  String year)  $default,) {final _that = this;
switch (_that) {
case _SearchTarget():
return $default(_that.abstract,_that.cardSubtitle,_that.controversyReason,_that.coverUrl,_that.hasLinewatch,_that.id,_that.nullRatingReason,_that.rating,_that.title,_that.uri,_that.year);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String abstract, @JsonKey(name: 'card_subtitle')  String cardSubtitle, @JsonKey(name: 'controversy_reason')  String controversyReason, @JsonKey(name: 'cover_url')  String coverUrl, @JsonKey(name: 'has_linewatch')  bool hasLinewatch,  String id, @JsonKey(name: 'null_rating_reason')  String nullRatingReason,  DoubanRating rating,  String title,  String uri,  String year)?  $default,) {final _that = this;
switch (_that) {
case _SearchTarget() when $default != null:
return $default(_that.abstract,_that.cardSubtitle,_that.controversyReason,_that.coverUrl,_that.hasLinewatch,_that.id,_that.nullRatingReason,_that.rating,_that.title,_that.uri,_that.year);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SearchTarget implements SearchTarget {
  const _SearchTarget({this.abstract = '', @JsonKey(name: 'card_subtitle') this.cardSubtitle = '', @JsonKey(name: 'controversy_reason') this.controversyReason = '', @JsonKey(name: 'cover_url') this.coverUrl = '', @JsonKey(name: 'has_linewatch') this.hasLinewatch = false, this.id = '', @JsonKey(name: 'null_rating_reason') this.nullRatingReason = '', this.rating = const DoubanRating(), this.title = '', this.uri = '', this.year = ''});
  factory _SearchTarget.fromJson(Map<String, dynamic> json) => _$SearchTargetFromJson(json);

@override@JsonKey() final  String abstract;
@override@JsonKey(name: 'card_subtitle') final  String cardSubtitle;
@override@JsonKey(name: 'controversy_reason') final  String controversyReason;
@override@JsonKey(name: 'cover_url') final  String coverUrl;
@override@JsonKey(name: 'has_linewatch') final  bool hasLinewatch;
@override@JsonKey() final  String id;
@override@JsonKey(name: 'null_rating_reason') final  String nullRatingReason;
@override@JsonKey() final  DoubanRating rating;
@override@JsonKey() final  String title;
@override@JsonKey() final  String uri;
@override@JsonKey() final  String year;

/// Create a copy of SearchTarget
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchTargetCopyWith<_SearchTarget> get copyWith => __$SearchTargetCopyWithImpl<_SearchTarget>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchTargetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchTarget&&(identical(other.abstract, abstract) || other.abstract == abstract)&&(identical(other.cardSubtitle, cardSubtitle) || other.cardSubtitle == cardSubtitle)&&(identical(other.controversyReason, controversyReason) || other.controversyReason == controversyReason)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.hasLinewatch, hasLinewatch) || other.hasLinewatch == hasLinewatch)&&(identical(other.id, id) || other.id == id)&&(identical(other.nullRatingReason, nullRatingReason) || other.nullRatingReason == nullRatingReason)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.title, title) || other.title == title)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.year, year) || other.year == year));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,abstract,cardSubtitle,controversyReason,coverUrl,hasLinewatch,id,nullRatingReason,rating,title,uri,year);

@override
String toString() {
  return 'SearchTarget(abstract: $abstract, cardSubtitle: $cardSubtitle, controversyReason: $controversyReason, coverUrl: $coverUrl, hasLinewatch: $hasLinewatch, id: $id, nullRatingReason: $nullRatingReason, rating: $rating, title: $title, uri: $uri, year: $year)';
}


}

/// @nodoc
abstract mixin class _$SearchTargetCopyWith<$Res> implements $SearchTargetCopyWith<$Res> {
  factory _$SearchTargetCopyWith(_SearchTarget value, $Res Function(_SearchTarget) _then) = __$SearchTargetCopyWithImpl;
@override @useResult
$Res call({
 String abstract,@JsonKey(name: 'card_subtitle') String cardSubtitle,@JsonKey(name: 'controversy_reason') String controversyReason,@JsonKey(name: 'cover_url') String coverUrl,@JsonKey(name: 'has_linewatch') bool hasLinewatch, String id,@JsonKey(name: 'null_rating_reason') String nullRatingReason, DoubanRating rating, String title, String uri, String year
});


@override $DoubanRatingCopyWith<$Res> get rating;

}
/// @nodoc
class __$SearchTargetCopyWithImpl<$Res>
    implements _$SearchTargetCopyWith<$Res> {
  __$SearchTargetCopyWithImpl(this._self, this._then);

  final _SearchTarget _self;
  final $Res Function(_SearchTarget) _then;

/// Create a copy of SearchTarget
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? abstract = null,Object? cardSubtitle = null,Object? controversyReason = null,Object? coverUrl = null,Object? hasLinewatch = null,Object? id = null,Object? nullRatingReason = null,Object? rating = null,Object? title = null,Object? uri = null,Object? year = null,}) {
  return _then(_SearchTarget(
abstract: null == abstract ? _self.abstract : abstract // ignore: cast_nullable_to_non_nullable
as String,cardSubtitle: null == cardSubtitle ? _self.cardSubtitle : cardSubtitle // ignore: cast_nullable_to_non_nullable
as String,controversyReason: null == controversyReason ? _self.controversyReason : controversyReason // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,hasLinewatch: null == hasLinewatch ? _self.hasLinewatch : hasLinewatch // ignore: cast_nullable_to_non_nullable
as bool,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nullRatingReason: null == nullRatingReason ? _self.nullRatingReason : nullRatingReason // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as DoubanRating,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of SearchTarget
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DoubanRatingCopyWith<$Res> get rating {
  
  return $DoubanRatingCopyWith<$Res>(_self.rating, (value) {
    return _then(_self.copyWith(rating: value));
  });
}
}


/// @nodoc
mixin _$DoubanSearchResult {

 String get layout; SearchTarget get target;@JsonKey(name: 'target_id') String get targetId;@JsonKey(name: 'target_type') String get targetType;@JsonKey(name: 'type_name') String get typeName;
/// Create a copy of DoubanSearchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoubanSearchResultCopyWith<DoubanSearchResult> get copyWith => _$DoubanSearchResultCopyWithImpl<DoubanSearchResult>(this as DoubanSearchResult, _$identity);

  /// Serializes this DoubanSearchResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoubanSearchResult&&(identical(other.layout, layout) || other.layout == layout)&&(identical(other.target, target) || other.target == target)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.typeName, typeName) || other.typeName == typeName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,layout,target,targetId,targetType,typeName);

@override
String toString() {
  return 'DoubanSearchResult(layout: $layout, target: $target, targetId: $targetId, targetType: $targetType, typeName: $typeName)';
}


}

/// @nodoc
abstract mixin class $DoubanSearchResultCopyWith<$Res>  {
  factory $DoubanSearchResultCopyWith(DoubanSearchResult value, $Res Function(DoubanSearchResult) _then) = _$DoubanSearchResultCopyWithImpl;
@useResult
$Res call({
 String layout, SearchTarget target,@JsonKey(name: 'target_id') String targetId,@JsonKey(name: 'target_type') String targetType,@JsonKey(name: 'type_name') String typeName
});


$SearchTargetCopyWith<$Res> get target;

}
/// @nodoc
class _$DoubanSearchResultCopyWithImpl<$Res>
    implements $DoubanSearchResultCopyWith<$Res> {
  _$DoubanSearchResultCopyWithImpl(this._self, this._then);

  final DoubanSearchResult _self;
  final $Res Function(DoubanSearchResult) _then;

/// Create a copy of DoubanSearchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? layout = null,Object? target = null,Object? targetId = null,Object? targetType = null,Object? typeName = null,}) {
  return _then(_self.copyWith(
layout: null == layout ? _self.layout : layout // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as SearchTarget,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as String,typeName: null == typeName ? _self.typeName : typeName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of DoubanSearchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchTargetCopyWith<$Res> get target {
  
  return $SearchTargetCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}
}


/// Adds pattern-matching-related methods to [DoubanSearchResult].
extension DoubanSearchResultPatterns on DoubanSearchResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoubanSearchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoubanSearchResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoubanSearchResult value)  $default,){
final _that = this;
switch (_that) {
case _DoubanSearchResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoubanSearchResult value)?  $default,){
final _that = this;
switch (_that) {
case _DoubanSearchResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String layout,  SearchTarget target, @JsonKey(name: 'target_id')  String targetId, @JsonKey(name: 'target_type')  String targetType, @JsonKey(name: 'type_name')  String typeName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoubanSearchResult() when $default != null:
return $default(_that.layout,_that.target,_that.targetId,_that.targetType,_that.typeName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String layout,  SearchTarget target, @JsonKey(name: 'target_id')  String targetId, @JsonKey(name: 'target_type')  String targetType, @JsonKey(name: 'type_name')  String typeName)  $default,) {final _that = this;
switch (_that) {
case _DoubanSearchResult():
return $default(_that.layout,_that.target,_that.targetId,_that.targetType,_that.typeName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String layout,  SearchTarget target, @JsonKey(name: 'target_id')  String targetId, @JsonKey(name: 'target_type')  String targetType, @JsonKey(name: 'type_name')  String typeName)?  $default,) {final _that = this;
switch (_that) {
case _DoubanSearchResult() when $default != null:
return $default(_that.layout,_that.target,_that.targetId,_that.targetType,_that.typeName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DoubanSearchResult implements DoubanSearchResult {
  const _DoubanSearchResult({this.layout = '', this.target = const SearchTarget(), @JsonKey(name: 'target_id') this.targetId = '', @JsonKey(name: 'target_type') this.targetType = '', @JsonKey(name: 'type_name') this.typeName = ''});
  factory _DoubanSearchResult.fromJson(Map<String, dynamic> json) => _$DoubanSearchResultFromJson(json);

@override@JsonKey() final  String layout;
@override@JsonKey() final  SearchTarget target;
@override@JsonKey(name: 'target_id') final  String targetId;
@override@JsonKey(name: 'target_type') final  String targetType;
@override@JsonKey(name: 'type_name') final  String typeName;

/// Create a copy of DoubanSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoubanSearchResultCopyWith<_DoubanSearchResult> get copyWith => __$DoubanSearchResultCopyWithImpl<_DoubanSearchResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DoubanSearchResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoubanSearchResult&&(identical(other.layout, layout) || other.layout == layout)&&(identical(other.target, target) || other.target == target)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.typeName, typeName) || other.typeName == typeName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,layout,target,targetId,targetType,typeName);

@override
String toString() {
  return 'DoubanSearchResult(layout: $layout, target: $target, targetId: $targetId, targetType: $targetType, typeName: $typeName)';
}


}

/// @nodoc
abstract mixin class _$DoubanSearchResultCopyWith<$Res> implements $DoubanSearchResultCopyWith<$Res> {
  factory _$DoubanSearchResultCopyWith(_DoubanSearchResult value, $Res Function(_DoubanSearchResult) _then) = __$DoubanSearchResultCopyWithImpl;
@override @useResult
$Res call({
 String layout, SearchTarget target,@JsonKey(name: 'target_id') String targetId,@JsonKey(name: 'target_type') String targetType,@JsonKey(name: 'type_name') String typeName
});


@override $SearchTargetCopyWith<$Res> get target;

}
/// @nodoc
class __$DoubanSearchResultCopyWithImpl<$Res>
    implements _$DoubanSearchResultCopyWith<$Res> {
  __$DoubanSearchResultCopyWithImpl(this._self, this._then);

  final _DoubanSearchResult _self;
  final $Res Function(_DoubanSearchResult) _then;

/// Create a copy of DoubanSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? layout = null,Object? target = null,Object? targetId = null,Object? targetType = null,Object? typeName = null,}) {
  return _then(_DoubanSearchResult(
layout: null == layout ? _self.layout : layout // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as SearchTarget,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as String,typeName: null == typeName ? _self.typeName : typeName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of DoubanSearchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchTargetCopyWith<$Res> get target {
  
  return $SearchTargetCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}
}

// dart format on
