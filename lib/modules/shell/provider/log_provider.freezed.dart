// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'log_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LogFileInfo implements DiagnosticableTreeMixin {

 String get name; String get filePath; int get sizeBytes; DateTime get lastModified;
/// Create a copy of LogFileInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogFileInfoCopyWith<LogFileInfo> get copyWith => _$LogFileInfoCopyWithImpl<LogFileInfo>(this as LogFileInfo, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as LogFileInfo;
  properties
    ..add(DiagnosticsProperty('type', 'LogFileInfo'))
    ..add(DiagnosticsProperty('name', _this.name))..add(DiagnosticsProperty('filePath', _this.filePath))..add(DiagnosticsProperty('sizeBytes', _this.sizeBytes))..add(DiagnosticsProperty('lastModified', _this.lastModified));
}

@override
bool operator ==(Object other) {
  final _this = this as LogFileInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogFileInfo&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.filePath, _this.filePath) || other.filePath == _this.filePath)&&(identical(other.sizeBytes, _this.sizeBytes) || other.sizeBytes == _this.sizeBytes)&&(identical(other.lastModified, _this.lastModified) || other.lastModified == _this.lastModified));
}


@override
int get hashCode {
  final _this = this as LogFileInfo;
  return Object.hash(runtimeType,_this.name,_this.filePath,_this.sizeBytes,_this.lastModified);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as LogFileInfo;
  return 'LogFileInfo(name: ${_this.name}, filePath: ${_this.filePath}, sizeBytes: ${_this.sizeBytes}, lastModified: ${_this.lastModified})';
}


}

/// @nodoc
abstract mixin class $LogFileInfoCopyWith<$Res>  {
  factory $LogFileInfoCopyWith(LogFileInfo value, $Res Function(LogFileInfo) _then) = _$LogFileInfoCopyWithImpl;
@useResult
$Res call({
 String name, String filePath, int sizeBytes, DateTime lastModified
});




}
/// @nodoc
class _$LogFileInfoCopyWithImpl<$Res>
    implements $LogFileInfoCopyWith<$Res> {
  _$LogFileInfoCopyWithImpl(this._self, this._then);

  final LogFileInfo _self;
  final $Res Function(LogFileInfo) _then;

/// Create a copy of LogFileInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? filePath = null,Object? sizeBytes = null,Object? lastModified = null,}) {
  return _then(LogFileInfo(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LogFileInfo].
extension LogFileInfoPatterns on LogFileInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LogFileInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LogFileInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LogFileInfo value)  $default,){
final _that = this;
switch (_that) {
case _LogFileInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LogFileInfo value)?  $default,){
final _that = this;
switch (_that) {
case _LogFileInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String filePath,  int sizeBytes,  DateTime lastModified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LogFileInfo() when $default != null:
return $default(_that.name,_that.filePath,_that.sizeBytes,_that.lastModified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String filePath,  int sizeBytes,  DateTime lastModified)  $default,) {final _that = this;
switch (_that) {
case _LogFileInfo():
return $default(_that.name,_that.filePath,_that.sizeBytes,_that.lastModified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String filePath,  int sizeBytes,  DateTime lastModified)?  $default,) {final _that = this;
switch (_that) {
case _LogFileInfo() when $default != null:
return $default(_that.name,_that.filePath,_that.sizeBytes,_that.lastModified);case _:
  return null;

}
}

}

/// @nodoc


class _LogFileInfo with DiagnosticableTreeMixin implements LogFileInfo {
  const _LogFileInfo({required this.name, required this.filePath, required this.sizeBytes, required this.lastModified});
  

@override final  String name;
@override final  String filePath;
@override final  int sizeBytes;
@override final  DateTime lastModified;

/// Create a copy of LogFileInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LogFileInfoCopyWith<_LogFileInfo> get copyWith => __$LogFileInfoCopyWithImpl<_LogFileInfo>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'LogFileInfo'))
    ..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('filePath', filePath))..add(DiagnosticsProperty('sizeBytes', sizeBytes))..add(DiagnosticsProperty('lastModified', lastModified));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LogFileInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,filePath,sizeBytes,lastModified);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'LogFileInfo(name: $name, filePath: $filePath, sizeBytes: $sizeBytes, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class _$LogFileInfoCopyWith<$Res> implements $LogFileInfoCopyWith<$Res> {
  factory _$LogFileInfoCopyWith(_LogFileInfo value, $Res Function(_LogFileInfo) _then) = __$LogFileInfoCopyWithImpl;
@override @useResult
$Res call({
 String name, String filePath, int sizeBytes, DateTime lastModified
});




}
/// @nodoc
class __$LogFileInfoCopyWithImpl<$Res>
    implements _$LogFileInfoCopyWith<$Res> {
  __$LogFileInfoCopyWithImpl(this._self, this._then);

  final _LogFileInfo _self;
  final $Res Function(_LogFileInfo) _then;

/// Create a copy of LogFileInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? filePath = null,Object? sizeBytes = null,Object? lastModified = null,}) {
  return _then(_LogFileInfo(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$LogState implements DiagnosticableTreeMixin {

 List<LogFileInfo> get files; bool get isLoading; LogLevel? get selectedLevel; String? get viewingFilePath; String? get viewingFileName; List<String> get viewingLines; bool get isLoadingContent; bool get isFollowing;
/// Create a copy of LogState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogStateCopyWith<LogState> get copyWith => _$LogStateCopyWithImpl<LogState>(this as LogState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as LogState;
  properties
    ..add(DiagnosticsProperty('type', 'LogState'))
    ..add(DiagnosticsProperty('files', _this.files))..add(DiagnosticsProperty('isLoading', _this.isLoading))..add(DiagnosticsProperty('selectedLevel', _this.selectedLevel))..add(DiagnosticsProperty('viewingFilePath', _this.viewingFilePath))..add(DiagnosticsProperty('viewingFileName', _this.viewingFileName))..add(DiagnosticsProperty('viewingLines', _this.viewingLines))..add(DiagnosticsProperty('isLoadingContent', _this.isLoadingContent))..add(DiagnosticsProperty('isFollowing', _this.isFollowing));
}

@override
bool operator ==(Object other) {
  final _this = this as LogState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogState&&const DeepCollectionEquality().equals(other.files, _this.files)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.selectedLevel, _this.selectedLevel) || other.selectedLevel == _this.selectedLevel)&&(identical(other.viewingFilePath, _this.viewingFilePath) || other.viewingFilePath == _this.viewingFilePath)&&(identical(other.viewingFileName, _this.viewingFileName) || other.viewingFileName == _this.viewingFileName)&&const DeepCollectionEquality().equals(other.viewingLines, _this.viewingLines)&&(identical(other.isLoadingContent, _this.isLoadingContent) || other.isLoadingContent == _this.isLoadingContent)&&(identical(other.isFollowing, _this.isFollowing) || other.isFollowing == _this.isFollowing));
}


@override
int get hashCode {
  final _this = this as LogState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.files),_this.isLoading,_this.selectedLevel,_this.viewingFilePath,_this.viewingFileName,const DeepCollectionEquality().hash(_this.viewingLines),_this.isLoadingContent,_this.isFollowing);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as LogState;
  return 'LogState(files: ${_this.files}, isLoading: ${_this.isLoading}, selectedLevel: ${_this.selectedLevel}, viewingFilePath: ${_this.viewingFilePath}, viewingFileName: ${_this.viewingFileName}, viewingLines: ${_this.viewingLines}, isLoadingContent: ${_this.isLoadingContent}, isFollowing: ${_this.isFollowing})';
}


}

/// @nodoc
abstract mixin class $LogStateCopyWith<$Res>  {
  factory $LogStateCopyWith(LogState value, $Res Function(LogState) _then) = _$LogStateCopyWithImpl;
@useResult
$Res call({
 List<LogFileInfo> files, bool isLoading, LogLevel? selectedLevel, String? viewingFilePath, String? viewingFileName, List<String> viewingLines, bool isLoadingContent, bool isFollowing
});




}
/// @nodoc
class _$LogStateCopyWithImpl<$Res>
    implements $LogStateCopyWith<$Res> {
  _$LogStateCopyWithImpl(this._self, this._then);

  final LogState _self;
  final $Res Function(LogState) _then;

/// Create a copy of LogState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? files = null,Object? isLoading = null,Object? selectedLevel = freezed,Object? viewingFilePath = freezed,Object? viewingFileName = freezed,Object? viewingLines = null,Object? isLoadingContent = null,Object? isFollowing = null,}) {
  return _then(LogState(
files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<LogFileInfo>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,selectedLevel: freezed == selectedLevel ? _self.selectedLevel : selectedLevel // ignore: cast_nullable_to_non_nullable
as LogLevel?,viewingFilePath: freezed == viewingFilePath ? _self.viewingFilePath : viewingFilePath // ignore: cast_nullable_to_non_nullable
as String?,viewingFileName: freezed == viewingFileName ? _self.viewingFileName : viewingFileName // ignore: cast_nullable_to_non_nullable
as String?,viewingLines: null == viewingLines ? _self.viewingLines : viewingLines // ignore: cast_nullable_to_non_nullable
as List<String>,isLoadingContent: null == isLoadingContent ? _self.isLoadingContent : isLoadingContent // ignore: cast_nullable_to_non_nullable
as bool,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LogState].
extension LogStatePatterns on LogState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LogState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LogState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LogState value)  $default,){
final _that = this;
switch (_that) {
case _LogState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LogState value)?  $default,){
final _that = this;
switch (_that) {
case _LogState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<LogFileInfo> files,  bool isLoading,  LogLevel? selectedLevel,  String? viewingFilePath,  String? viewingFileName,  List<String> viewingLines,  bool isLoadingContent,  bool isFollowing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LogState() when $default != null:
return $default(_that.files,_that.isLoading,_that.selectedLevel,_that.viewingFilePath,_that.viewingFileName,_that.viewingLines,_that.isLoadingContent,_that.isFollowing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<LogFileInfo> files,  bool isLoading,  LogLevel? selectedLevel,  String? viewingFilePath,  String? viewingFileName,  List<String> viewingLines,  bool isLoadingContent,  bool isFollowing)  $default,) {final _that = this;
switch (_that) {
case _LogState():
return $default(_that.files,_that.isLoading,_that.selectedLevel,_that.viewingFilePath,_that.viewingFileName,_that.viewingLines,_that.isLoadingContent,_that.isFollowing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<LogFileInfo> files,  bool isLoading,  LogLevel? selectedLevel,  String? viewingFilePath,  String? viewingFileName,  List<String> viewingLines,  bool isLoadingContent,  bool isFollowing)?  $default,) {final _that = this;
switch (_that) {
case _LogState() when $default != null:
return $default(_that.files,_that.isLoading,_that.selectedLevel,_that.viewingFilePath,_that.viewingFileName,_that.viewingLines,_that.isLoadingContent,_that.isFollowing);case _:
  return null;

}
}

}

/// @nodoc


class _LogState with DiagnosticableTreeMixin implements LogState {
  const _LogState({ List<LogFileInfo> files = const [], this.isLoading = false, this.selectedLevel, this.viewingFilePath, this.viewingFileName,  List<String> viewingLines = const [], this.isLoadingContent = false, this.isFollowing = true}): _files = files,_viewingLines = viewingLines;
  

 final  List<LogFileInfo> _files;
@override@JsonKey() List<LogFileInfo> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}

@override@JsonKey() final  bool isLoading;
@override final  LogLevel? selectedLevel;
@override final  String? viewingFilePath;
@override final  String? viewingFileName;
 final  List<String> _viewingLines;
@override@JsonKey() List<String> get viewingLines {
  if (_viewingLines is EqualUnmodifiableListView) return _viewingLines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_viewingLines);
}

@override@JsonKey() final  bool isLoadingContent;
@override@JsonKey() final  bool isFollowing;

/// Create a copy of LogState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LogStateCopyWith<_LogState> get copyWith => __$LogStateCopyWithImpl<_LogState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'LogState'))
    ..add(DiagnosticsProperty('files', files))..add(DiagnosticsProperty('isLoading', isLoading))..add(DiagnosticsProperty('selectedLevel', selectedLevel))..add(DiagnosticsProperty('viewingFilePath', viewingFilePath))..add(DiagnosticsProperty('viewingFileName', viewingFileName))..add(DiagnosticsProperty('viewingLines', viewingLines))..add(DiagnosticsProperty('isLoadingContent', isLoadingContent))..add(DiagnosticsProperty('isFollowing', isFollowing));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LogState&&const DeepCollectionEquality().equals(other.files, _files)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.selectedLevel, selectedLevel) || other.selectedLevel == selectedLevel)&&(identical(other.viewingFilePath, viewingFilePath) || other.viewingFilePath == viewingFilePath)&&(identical(other.viewingFileName, viewingFileName) || other.viewingFileName == viewingFileName)&&const DeepCollectionEquality().equals(other.viewingLines, _viewingLines)&&(identical(other.isLoadingContent, isLoadingContent) || other.isLoadingContent == isLoadingContent)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_files),isLoading,selectedLevel,viewingFilePath,viewingFileName,const DeepCollectionEquality().hash(_viewingLines),isLoadingContent,isFollowing);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'LogState(files: $files, isLoading: $isLoading, selectedLevel: $selectedLevel, viewingFilePath: $viewingFilePath, viewingFileName: $viewingFileName, viewingLines: $viewingLines, isLoadingContent: $isLoadingContent, isFollowing: $isFollowing)';
}


}

/// @nodoc
abstract mixin class _$LogStateCopyWith<$Res> implements $LogStateCopyWith<$Res> {
  factory _$LogStateCopyWith(_LogState value, $Res Function(_LogState) _then) = __$LogStateCopyWithImpl;
@override @useResult
$Res call({
 List<LogFileInfo> files, bool isLoading, LogLevel? selectedLevel, String? viewingFilePath, String? viewingFileName, List<String> viewingLines, bool isLoadingContent, bool isFollowing
});




}
/// @nodoc
class __$LogStateCopyWithImpl<$Res>
    implements _$LogStateCopyWith<$Res> {
  __$LogStateCopyWithImpl(this._self, this._then);

  final _LogState _self;
  final $Res Function(_LogState) _then;

/// Create a copy of LogState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? files = null,Object? isLoading = null,Object? selectedLevel = freezed,Object? viewingFilePath = freezed,Object? viewingFileName = freezed,Object? viewingLines = null,Object? isLoadingContent = null,Object? isFollowing = null,}) {
  return _then(_LogState(
files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<LogFileInfo>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,selectedLevel: freezed == selectedLevel ? _self.selectedLevel : selectedLevel // ignore: cast_nullable_to_non_nullable
as LogLevel?,viewingFilePath: freezed == viewingFilePath ? _self.viewingFilePath : viewingFilePath // ignore: cast_nullable_to_non_nullable
as String?,viewingFileName: freezed == viewingFileName ? _self.viewingFileName : viewingFileName // ignore: cast_nullable_to_non_nullable
as String?,viewingLines: null == viewingLines ? _self._viewingLines : viewingLines // ignore: cast_nullable_to_non_nullable
as List<String>,isLoadingContent: null == isLoadingContent ? _self.isLoadingContent : isLoadingContent // ignore: cast_nullable_to_non_nullable
as bool,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
