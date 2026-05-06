// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_results.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchResults {

 int get page;@JsonKey(name: 'total_pages') int get totalPages;@JsonKey(name: 'total_results') int get totalResults; List<MediaItem> get results; int? get id; Map<String, dynamic>? get dates;
/// Create a copy of SearchResults
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchResultsCopyWith<SearchResults> get copyWith => _$SearchResultsCopyWithImpl<SearchResults>(this as SearchResults, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchResults&&(identical(other.page, page) || other.page == page)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.totalResults, totalResults) || other.totalResults == totalResults)&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.dates, dates));
}


@override
int get hashCode => Object.hash(runtimeType,page,totalPages,totalResults,const DeepCollectionEquality().hash(results),id,const DeepCollectionEquality().hash(dates));

@override
String toString() {
  return 'SearchResults(page: $page, totalPages: $totalPages, totalResults: $totalResults, results: $results, id: $id, dates: $dates)';
}


}

/// @nodoc
abstract mixin class $SearchResultsCopyWith<$Res>  {
  factory $SearchResultsCopyWith(SearchResults value, $Res Function(SearchResults) _then) = _$SearchResultsCopyWithImpl;
@useResult
$Res call({
 int page,@JsonKey(name: 'total_pages') int totalPages,@JsonKey(name: 'total_results') int totalResults, List<MediaItem> results, int? id, Map<String, dynamic>? dates
});




}
/// @nodoc
class _$SearchResultsCopyWithImpl<$Res>
    implements $SearchResultsCopyWith<$Res> {
  _$SearchResultsCopyWithImpl(this._self, this._then);

  final SearchResults _self;
  final $Res Function(SearchResults) _then;

/// Create a copy of SearchResults
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? page = null,Object? totalPages = null,Object? totalResults = null,Object? results = null,Object? id = freezed,Object? dates = freezed,}) {
  return _then(_self.copyWith(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,totalResults: null == totalResults ? _self.totalResults : totalResults // ignore: cast_nullable_to_non_nullable
as int,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<MediaItem>,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,dates: freezed == dates ? _self.dates : dates // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchResults].
extension SearchResultsPatterns on SearchResults {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchResults value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchResults() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchResults value)  $default,){
final _that = this;
switch (_that) {
case _SearchResults():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchResults value)?  $default,){
final _that = this;
switch (_that) {
case _SearchResults() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int page, @JsonKey(name: 'total_pages')  int totalPages, @JsonKey(name: 'total_results')  int totalResults,  List<MediaItem> results,  int? id,  Map<String, dynamic>? dates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchResults() when $default != null:
return $default(_that.page,_that.totalPages,_that.totalResults,_that.results,_that.id,_that.dates);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int page, @JsonKey(name: 'total_pages')  int totalPages, @JsonKey(name: 'total_results')  int totalResults,  List<MediaItem> results,  int? id,  Map<String, dynamic>? dates)  $default,) {final _that = this;
switch (_that) {
case _SearchResults():
return $default(_that.page,_that.totalPages,_that.totalResults,_that.results,_that.id,_that.dates);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int page, @JsonKey(name: 'total_pages')  int totalPages, @JsonKey(name: 'total_results')  int totalResults,  List<MediaItem> results,  int? id,  Map<String, dynamic>? dates)?  $default,) {final _that = this;
switch (_that) {
case _SearchResults() when $default != null:
return $default(_that.page,_that.totalPages,_that.totalResults,_that.results,_that.id,_that.dates);case _:
  return null;

}
}

}

/// @nodoc


class _SearchResults implements SearchResults {
  const _SearchResults({this.page = 0, @JsonKey(name: 'total_pages') this.totalPages = 0, @JsonKey(name: 'total_results') this.totalResults = 0, final  List<MediaItem> results = const [], this.id, final  Map<String, dynamic>? dates}): _results = results,_dates = dates;
  

@override@JsonKey() final  int page;
@override@JsonKey(name: 'total_pages') final  int totalPages;
@override@JsonKey(name: 'total_results') final  int totalResults;
 final  List<MediaItem> _results;
@override@JsonKey() List<MediaItem> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override final  int? id;
 final  Map<String, dynamic>? _dates;
@override Map<String, dynamic>? get dates {
  final value = _dates;
  if (value == null) return null;
  if (_dates is EqualUnmodifiableMapView) return _dates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of SearchResults
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchResultsCopyWith<_SearchResults> get copyWith => __$SearchResultsCopyWithImpl<_SearchResults>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchResults&&(identical(other.page, page) || other.page == page)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.totalResults, totalResults) || other.totalResults == totalResults)&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._dates, _dates));
}


@override
int get hashCode => Object.hash(runtimeType,page,totalPages,totalResults,const DeepCollectionEquality().hash(_results),id,const DeepCollectionEquality().hash(_dates));

@override
String toString() {
  return 'SearchResults(page: $page, totalPages: $totalPages, totalResults: $totalResults, results: $results, id: $id, dates: $dates)';
}


}

/// @nodoc
abstract mixin class _$SearchResultsCopyWith<$Res> implements $SearchResultsCopyWith<$Res> {
  factory _$SearchResultsCopyWith(_SearchResults value, $Res Function(_SearchResults) _then) = __$SearchResultsCopyWithImpl;
@override @useResult
$Res call({
 int page,@JsonKey(name: 'total_pages') int totalPages,@JsonKey(name: 'total_results') int totalResults, List<MediaItem> results, int? id, Map<String, dynamic>? dates
});




}
/// @nodoc
class __$SearchResultsCopyWithImpl<$Res>
    implements _$SearchResultsCopyWith<$Res> {
  __$SearchResultsCopyWithImpl(this._self, this._then);

  final _SearchResults _self;
  final $Res Function(_SearchResults) _then;

/// Create a copy of SearchResults
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? page = null,Object? totalPages = null,Object? totalResults = null,Object? results = null,Object? id = freezed,Object? dates = freezed,}) {
  return _then(_SearchResults(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,totalResults: null == totalResults ? _self.totalResults : totalResults // ignore: cast_nullable_to_non_nullable
as int,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<MediaItem>,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,dates: freezed == dates ? _self._dates : dates // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
