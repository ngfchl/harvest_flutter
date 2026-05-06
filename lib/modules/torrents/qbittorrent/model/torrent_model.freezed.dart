// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'torrent_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TrackerStat {

 int get id; String get host; String get sitename; String get announce; int get seederCount; int get leecherCount; int get downloadCount; bool get lastAnnounceSucceeded; String get lastAnnounceResult; int get lastAnnounceTime; int get nextAnnounceTime; bool get isBackup;
/// Create a copy of TrackerStat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackerStatCopyWith<TrackerStat> get copyWith => _$TrackerStatCopyWithImpl<TrackerStat>(this as TrackerStat, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackerStat&&(identical(other.id, id) || other.id == id)&&(identical(other.host, host) || other.host == host)&&(identical(other.sitename, sitename) || other.sitename == sitename)&&(identical(other.announce, announce) || other.announce == announce)&&(identical(other.seederCount, seederCount) || other.seederCount == seederCount)&&(identical(other.leecherCount, leecherCount) || other.leecherCount == leecherCount)&&(identical(other.downloadCount, downloadCount) || other.downloadCount == downloadCount)&&(identical(other.lastAnnounceSucceeded, lastAnnounceSucceeded) || other.lastAnnounceSucceeded == lastAnnounceSucceeded)&&(identical(other.lastAnnounceResult, lastAnnounceResult) || other.lastAnnounceResult == lastAnnounceResult)&&(identical(other.lastAnnounceTime, lastAnnounceTime) || other.lastAnnounceTime == lastAnnounceTime)&&(identical(other.nextAnnounceTime, nextAnnounceTime) || other.nextAnnounceTime == nextAnnounceTime)&&(identical(other.isBackup, isBackup) || other.isBackup == isBackup));
}


@override
int get hashCode => Object.hash(runtimeType,id,host,sitename,announce,seederCount,leecherCount,downloadCount,lastAnnounceSucceeded,lastAnnounceResult,lastAnnounceTime,nextAnnounceTime,isBackup);

@override
String toString() {
  return 'TrackerStat(id: $id, host: $host, sitename: $sitename, announce: $announce, seederCount: $seederCount, leecherCount: $leecherCount, downloadCount: $downloadCount, lastAnnounceSucceeded: $lastAnnounceSucceeded, lastAnnounceResult: $lastAnnounceResult, lastAnnounceTime: $lastAnnounceTime, nextAnnounceTime: $nextAnnounceTime, isBackup: $isBackup)';
}


}

/// @nodoc
abstract mixin class $TrackerStatCopyWith<$Res>  {
  factory $TrackerStatCopyWith(TrackerStat value, $Res Function(TrackerStat) _then) = _$TrackerStatCopyWithImpl;
@useResult
$Res call({
 int id, String host, String sitename, String announce, int seederCount, int leecherCount, int downloadCount, bool lastAnnounceSucceeded, String lastAnnounceResult, int lastAnnounceTime, int nextAnnounceTime, bool isBackup
});




}
/// @nodoc
class _$TrackerStatCopyWithImpl<$Res>
    implements $TrackerStatCopyWith<$Res> {
  _$TrackerStatCopyWithImpl(this._self, this._then);

  final TrackerStat _self;
  final $Res Function(TrackerStat) _then;

/// Create a copy of TrackerStat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? host = null,Object? sitename = null,Object? announce = null,Object? seederCount = null,Object? leecherCount = null,Object? downloadCount = null,Object? lastAnnounceSucceeded = null,Object? lastAnnounceResult = null,Object? lastAnnounceTime = null,Object? nextAnnounceTime = null,Object? isBackup = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,sitename: null == sitename ? _self.sitename : sitename // ignore: cast_nullable_to_non_nullable
as String,announce: null == announce ? _self.announce : announce // ignore: cast_nullable_to_non_nullable
as String,seederCount: null == seederCount ? _self.seederCount : seederCount // ignore: cast_nullable_to_non_nullable
as int,leecherCount: null == leecherCount ? _self.leecherCount : leecherCount // ignore: cast_nullable_to_non_nullable
as int,downloadCount: null == downloadCount ? _self.downloadCount : downloadCount // ignore: cast_nullable_to_non_nullable
as int,lastAnnounceSucceeded: null == lastAnnounceSucceeded ? _self.lastAnnounceSucceeded : lastAnnounceSucceeded // ignore: cast_nullable_to_non_nullable
as bool,lastAnnounceResult: null == lastAnnounceResult ? _self.lastAnnounceResult : lastAnnounceResult // ignore: cast_nullable_to_non_nullable
as String,lastAnnounceTime: null == lastAnnounceTime ? _self.lastAnnounceTime : lastAnnounceTime // ignore: cast_nullable_to_non_nullable
as int,nextAnnounceTime: null == nextAnnounceTime ? _self.nextAnnounceTime : nextAnnounceTime // ignore: cast_nullable_to_non_nullable
as int,isBackup: null == isBackup ? _self.isBackup : isBackup // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TrackerStat].
extension TrackerStatPatterns on TrackerStat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackerStat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackerStat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackerStat value)  $default,){
final _that = this;
switch (_that) {
case _TrackerStat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackerStat value)?  $default,){
final _that = this;
switch (_that) {
case _TrackerStat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String host,  String sitename,  String announce,  int seederCount,  int leecherCount,  int downloadCount,  bool lastAnnounceSucceeded,  String lastAnnounceResult,  int lastAnnounceTime,  int nextAnnounceTime,  bool isBackup)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackerStat() when $default != null:
return $default(_that.id,_that.host,_that.sitename,_that.announce,_that.seederCount,_that.leecherCount,_that.downloadCount,_that.lastAnnounceSucceeded,_that.lastAnnounceResult,_that.lastAnnounceTime,_that.nextAnnounceTime,_that.isBackup);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String host,  String sitename,  String announce,  int seederCount,  int leecherCount,  int downloadCount,  bool lastAnnounceSucceeded,  String lastAnnounceResult,  int lastAnnounceTime,  int nextAnnounceTime,  bool isBackup)  $default,) {final _that = this;
switch (_that) {
case _TrackerStat():
return $default(_that.id,_that.host,_that.sitename,_that.announce,_that.seederCount,_that.leecherCount,_that.downloadCount,_that.lastAnnounceSucceeded,_that.lastAnnounceResult,_that.lastAnnounceTime,_that.nextAnnounceTime,_that.isBackup);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String host,  String sitename,  String announce,  int seederCount,  int leecherCount,  int downloadCount,  bool lastAnnounceSucceeded,  String lastAnnounceResult,  int lastAnnounceTime,  int nextAnnounceTime,  bool isBackup)?  $default,) {final _that = this;
switch (_that) {
case _TrackerStat() when $default != null:
return $default(_that.id,_that.host,_that.sitename,_that.announce,_that.seederCount,_that.leecherCount,_that.downloadCount,_that.lastAnnounceSucceeded,_that.lastAnnounceResult,_that.lastAnnounceTime,_that.nextAnnounceTime,_that.isBackup);case _:
  return null;

}
}

}

/// @nodoc


class _TrackerStat implements TrackerStat {
  const _TrackerStat({this.id = 0, this.host = '', this.sitename = '', this.announce = '', this.seederCount = 0, this.leecherCount = 0, this.downloadCount = 0, this.lastAnnounceSucceeded = false, this.lastAnnounceResult = '', this.lastAnnounceTime = 0, this.nextAnnounceTime = 0, this.isBackup = false});
  

@override@JsonKey() final  int id;
@override@JsonKey() final  String host;
@override@JsonKey() final  String sitename;
@override@JsonKey() final  String announce;
@override@JsonKey() final  int seederCount;
@override@JsonKey() final  int leecherCount;
@override@JsonKey() final  int downloadCount;
@override@JsonKey() final  bool lastAnnounceSucceeded;
@override@JsonKey() final  String lastAnnounceResult;
@override@JsonKey() final  int lastAnnounceTime;
@override@JsonKey() final  int nextAnnounceTime;
@override@JsonKey() final  bool isBackup;

/// Create a copy of TrackerStat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackerStatCopyWith<_TrackerStat> get copyWith => __$TrackerStatCopyWithImpl<_TrackerStat>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackerStat&&(identical(other.id, id) || other.id == id)&&(identical(other.host, host) || other.host == host)&&(identical(other.sitename, sitename) || other.sitename == sitename)&&(identical(other.announce, announce) || other.announce == announce)&&(identical(other.seederCount, seederCount) || other.seederCount == seederCount)&&(identical(other.leecherCount, leecherCount) || other.leecherCount == leecherCount)&&(identical(other.downloadCount, downloadCount) || other.downloadCount == downloadCount)&&(identical(other.lastAnnounceSucceeded, lastAnnounceSucceeded) || other.lastAnnounceSucceeded == lastAnnounceSucceeded)&&(identical(other.lastAnnounceResult, lastAnnounceResult) || other.lastAnnounceResult == lastAnnounceResult)&&(identical(other.lastAnnounceTime, lastAnnounceTime) || other.lastAnnounceTime == lastAnnounceTime)&&(identical(other.nextAnnounceTime, nextAnnounceTime) || other.nextAnnounceTime == nextAnnounceTime)&&(identical(other.isBackup, isBackup) || other.isBackup == isBackup));
}


@override
int get hashCode => Object.hash(runtimeType,id,host,sitename,announce,seederCount,leecherCount,downloadCount,lastAnnounceSucceeded,lastAnnounceResult,lastAnnounceTime,nextAnnounceTime,isBackup);

@override
String toString() {
  return 'TrackerStat(id: $id, host: $host, sitename: $sitename, announce: $announce, seederCount: $seederCount, leecherCount: $leecherCount, downloadCount: $downloadCount, lastAnnounceSucceeded: $lastAnnounceSucceeded, lastAnnounceResult: $lastAnnounceResult, lastAnnounceTime: $lastAnnounceTime, nextAnnounceTime: $nextAnnounceTime, isBackup: $isBackup)';
}


}

/// @nodoc
abstract mixin class _$TrackerStatCopyWith<$Res> implements $TrackerStatCopyWith<$Res> {
  factory _$TrackerStatCopyWith(_TrackerStat value, $Res Function(_TrackerStat) _then) = __$TrackerStatCopyWithImpl;
@override @useResult
$Res call({
 int id, String host, String sitename, String announce, int seederCount, int leecherCount, int downloadCount, bool lastAnnounceSucceeded, String lastAnnounceResult, int lastAnnounceTime, int nextAnnounceTime, bool isBackup
});




}
/// @nodoc
class __$TrackerStatCopyWithImpl<$Res>
    implements _$TrackerStatCopyWith<$Res> {
  __$TrackerStatCopyWithImpl(this._self, this._then);

  final _TrackerStat _self;
  final $Res Function(_TrackerStat) _then;

/// Create a copy of TrackerStat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? host = null,Object? sitename = null,Object? announce = null,Object? seederCount = null,Object? leecherCount = null,Object? downloadCount = null,Object? lastAnnounceSucceeded = null,Object? lastAnnounceResult = null,Object? lastAnnounceTime = null,Object? nextAnnounceTime = null,Object? isBackup = null,}) {
  return _then(_TrackerStat(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,sitename: null == sitename ? _self.sitename : sitename // ignore: cast_nullable_to_non_nullable
as String,announce: null == announce ? _self.announce : announce // ignore: cast_nullable_to_non_nullable
as String,seederCount: null == seederCount ? _self.seederCount : seederCount // ignore: cast_nullable_to_non_nullable
as int,leecherCount: null == leecherCount ? _self.leecherCount : leecherCount // ignore: cast_nullable_to_non_nullable
as int,downloadCount: null == downloadCount ? _self.downloadCount : downloadCount // ignore: cast_nullable_to_non_nullable
as int,lastAnnounceSucceeded: null == lastAnnounceSucceeded ? _self.lastAnnounceSucceeded : lastAnnounceSucceeded // ignore: cast_nullable_to_non_nullable
as bool,lastAnnounceResult: null == lastAnnounceResult ? _self.lastAnnounceResult : lastAnnounceResult // ignore: cast_nullable_to_non_nullable
as String,lastAnnounceTime: null == lastAnnounceTime ? _self.lastAnnounceTime : lastAnnounceTime // ignore: cast_nullable_to_non_nullable
as int,nextAnnounceTime: null == nextAnnounceTime ? _self.nextAnnounceTime : nextAnnounceTime // ignore: cast_nullable_to_non_nullable
as int,isBackup: null == isBackup ? _self.isBackup : isBackup // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$Torrent {

 int get id; String get name; String get category; String get hashString; double get percentDone; double get percentComplete; int get status; int get rateDownload; int get rateUpload; int get sizeWhenDone; int get totalSize; int get downloadedEver; int get uploadedEver; double get uploadRatio; int get addedDate; int get activityDate; int get doneDate; int get secondsSeeding; int get secondsDownloading; int get queuePosition; bool get isFinished; bool get isStalled; bool get downloadLimited; bool get uploadLimited; bool get forceStart; bool get autoTmm; bool get superSeeding; String get contentPath; int get downloadLimit; int get uploadLimit; double get seedRatioLimit; int get seedRatioMode; int get leftUntilDone; int get error; String get errorString; String get downloadDir; String get comment; String get magnetLink; String get torrentFile; List<String> get labels; List<TrackerStat> get trackerStats; int get peersGettingFromUs; int get peersSendingToUs; int get bandwidthPriority; double get recheckProgress; int get startDate; String get trackerUrl;
/// Create a copy of Torrent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TorrentCopyWith<Torrent> get copyWith => _$TorrentCopyWithImpl<Torrent>(this as Torrent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Torrent&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.hashString, hashString) || other.hashString == hashString)&&(identical(other.percentDone, percentDone) || other.percentDone == percentDone)&&(identical(other.percentComplete, percentComplete) || other.percentComplete == percentComplete)&&(identical(other.status, status) || other.status == status)&&(identical(other.rateDownload, rateDownload) || other.rateDownload == rateDownload)&&(identical(other.rateUpload, rateUpload) || other.rateUpload == rateUpload)&&(identical(other.sizeWhenDone, sizeWhenDone) || other.sizeWhenDone == sizeWhenDone)&&(identical(other.totalSize, totalSize) || other.totalSize == totalSize)&&(identical(other.downloadedEver, downloadedEver) || other.downloadedEver == downloadedEver)&&(identical(other.uploadedEver, uploadedEver) || other.uploadedEver == uploadedEver)&&(identical(other.uploadRatio, uploadRatio) || other.uploadRatio == uploadRatio)&&(identical(other.addedDate, addedDate) || other.addedDate == addedDate)&&(identical(other.activityDate, activityDate) || other.activityDate == activityDate)&&(identical(other.doneDate, doneDate) || other.doneDate == doneDate)&&(identical(other.secondsSeeding, secondsSeeding) || other.secondsSeeding == secondsSeeding)&&(identical(other.secondsDownloading, secondsDownloading) || other.secondsDownloading == secondsDownloading)&&(identical(other.queuePosition, queuePosition) || other.queuePosition == queuePosition)&&(identical(other.isFinished, isFinished) || other.isFinished == isFinished)&&(identical(other.isStalled, isStalled) || other.isStalled == isStalled)&&(identical(other.downloadLimited, downloadLimited) || other.downloadLimited == downloadLimited)&&(identical(other.uploadLimited, uploadLimited) || other.uploadLimited == uploadLimited)&&(identical(other.forceStart, forceStart) || other.forceStart == forceStart)&&(identical(other.autoTmm, autoTmm) || other.autoTmm == autoTmm)&&(identical(other.superSeeding, superSeeding) || other.superSeeding == superSeeding)&&(identical(other.contentPath, contentPath) || other.contentPath == contentPath)&&(identical(other.downloadLimit, downloadLimit) || other.downloadLimit == downloadLimit)&&(identical(other.uploadLimit, uploadLimit) || other.uploadLimit == uploadLimit)&&(identical(other.seedRatioLimit, seedRatioLimit) || other.seedRatioLimit == seedRatioLimit)&&(identical(other.seedRatioMode, seedRatioMode) || other.seedRatioMode == seedRatioMode)&&(identical(other.leftUntilDone, leftUntilDone) || other.leftUntilDone == leftUntilDone)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorString, errorString) || other.errorString == errorString)&&(identical(other.downloadDir, downloadDir) || other.downloadDir == downloadDir)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.magnetLink, magnetLink) || other.magnetLink == magnetLink)&&(identical(other.torrentFile, torrentFile) || other.torrentFile == torrentFile)&&const DeepCollectionEquality().equals(other.labels, labels)&&const DeepCollectionEquality().equals(other.trackerStats, trackerStats)&&(identical(other.peersGettingFromUs, peersGettingFromUs) || other.peersGettingFromUs == peersGettingFromUs)&&(identical(other.peersSendingToUs, peersSendingToUs) || other.peersSendingToUs == peersSendingToUs)&&(identical(other.bandwidthPriority, bandwidthPriority) || other.bandwidthPriority == bandwidthPriority)&&(identical(other.recheckProgress, recheckProgress) || other.recheckProgress == recheckProgress)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.trackerUrl, trackerUrl) || other.trackerUrl == trackerUrl));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,name,category,hashString,percentDone,percentComplete,status,rateDownload,rateUpload,sizeWhenDone,totalSize,downloadedEver,uploadedEver,uploadRatio,addedDate,activityDate,doneDate,secondsSeeding,secondsDownloading,queuePosition,isFinished,isStalled,downloadLimited,uploadLimited,forceStart,autoTmm,superSeeding,contentPath,downloadLimit,uploadLimit,seedRatioLimit,seedRatioMode,leftUntilDone,error,errorString,downloadDir,comment,magnetLink,torrentFile,const DeepCollectionEquality().hash(labels),const DeepCollectionEquality().hash(trackerStats),peersGettingFromUs,peersSendingToUs,bandwidthPriority,recheckProgress,startDate,trackerUrl]);

@override
String toString() {
  return 'Torrent(id: $id, name: $name, category: $category, hashString: $hashString, percentDone: $percentDone, percentComplete: $percentComplete, status: $status, rateDownload: $rateDownload, rateUpload: $rateUpload, sizeWhenDone: $sizeWhenDone, totalSize: $totalSize, downloadedEver: $downloadedEver, uploadedEver: $uploadedEver, uploadRatio: $uploadRatio, addedDate: $addedDate, activityDate: $activityDate, doneDate: $doneDate, secondsSeeding: $secondsSeeding, secondsDownloading: $secondsDownloading, queuePosition: $queuePosition, isFinished: $isFinished, isStalled: $isStalled, downloadLimited: $downloadLimited, uploadLimited: $uploadLimited, forceStart: $forceStart, autoTmm: $autoTmm, superSeeding: $superSeeding, contentPath: $contentPath, downloadLimit: $downloadLimit, uploadLimit: $uploadLimit, seedRatioLimit: $seedRatioLimit, seedRatioMode: $seedRatioMode, leftUntilDone: $leftUntilDone, error: $error, errorString: $errorString, downloadDir: $downloadDir, comment: $comment, magnetLink: $magnetLink, torrentFile: $torrentFile, labels: $labels, trackerStats: $trackerStats, peersGettingFromUs: $peersGettingFromUs, peersSendingToUs: $peersSendingToUs, bandwidthPriority: $bandwidthPriority, recheckProgress: $recheckProgress, startDate: $startDate, trackerUrl: $trackerUrl)';
}


}

/// @nodoc
abstract mixin class $TorrentCopyWith<$Res>  {
  factory $TorrentCopyWith(Torrent value, $Res Function(Torrent) _then) = _$TorrentCopyWithImpl;
@useResult
$Res call({
 int id, String name, String category, String hashString, double percentDone, double percentComplete, int status, int rateDownload, int rateUpload, int sizeWhenDone, int totalSize, int downloadedEver, int uploadedEver, double uploadRatio, int addedDate, int activityDate, int doneDate, int secondsSeeding, int secondsDownloading, int queuePosition, bool isFinished, bool isStalled, bool downloadLimited, bool uploadLimited, bool forceStart, bool autoTmm, bool superSeeding, String contentPath, int downloadLimit, int uploadLimit, double seedRatioLimit, int seedRatioMode, int leftUntilDone, int error, String errorString, String downloadDir, String comment, String magnetLink, String torrentFile, List<String> labels, List<TrackerStat> trackerStats, int peersGettingFromUs, int peersSendingToUs, int bandwidthPriority, double recheckProgress, int startDate, String trackerUrl
});




}
/// @nodoc
class _$TorrentCopyWithImpl<$Res>
    implements $TorrentCopyWith<$Res> {
  _$TorrentCopyWithImpl(this._self, this._then);

  final Torrent _self;
  final $Res Function(Torrent) _then;

/// Create a copy of Torrent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? category = null,Object? hashString = null,Object? percentDone = null,Object? percentComplete = null,Object? status = null,Object? rateDownload = null,Object? rateUpload = null,Object? sizeWhenDone = null,Object? totalSize = null,Object? downloadedEver = null,Object? uploadedEver = null,Object? uploadRatio = null,Object? addedDate = null,Object? activityDate = null,Object? doneDate = null,Object? secondsSeeding = null,Object? secondsDownloading = null,Object? queuePosition = null,Object? isFinished = null,Object? isStalled = null,Object? downloadLimited = null,Object? uploadLimited = null,Object? forceStart = null,Object? autoTmm = null,Object? superSeeding = null,Object? contentPath = null,Object? downloadLimit = null,Object? uploadLimit = null,Object? seedRatioLimit = null,Object? seedRatioMode = null,Object? leftUntilDone = null,Object? error = null,Object? errorString = null,Object? downloadDir = null,Object? comment = null,Object? magnetLink = null,Object? torrentFile = null,Object? labels = null,Object? trackerStats = null,Object? peersGettingFromUs = null,Object? peersSendingToUs = null,Object? bandwidthPriority = null,Object? recheckProgress = null,Object? startDate = null,Object? trackerUrl = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,hashString: null == hashString ? _self.hashString : hashString // ignore: cast_nullable_to_non_nullable
as String,percentDone: null == percentDone ? _self.percentDone : percentDone // ignore: cast_nullable_to_non_nullable
as double,percentComplete: null == percentComplete ? _self.percentComplete : percentComplete // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,rateDownload: null == rateDownload ? _self.rateDownload : rateDownload // ignore: cast_nullable_to_non_nullable
as int,rateUpload: null == rateUpload ? _self.rateUpload : rateUpload // ignore: cast_nullable_to_non_nullable
as int,sizeWhenDone: null == sizeWhenDone ? _self.sizeWhenDone : sizeWhenDone // ignore: cast_nullable_to_non_nullable
as int,totalSize: null == totalSize ? _self.totalSize : totalSize // ignore: cast_nullable_to_non_nullable
as int,downloadedEver: null == downloadedEver ? _self.downloadedEver : downloadedEver // ignore: cast_nullable_to_non_nullable
as int,uploadedEver: null == uploadedEver ? _self.uploadedEver : uploadedEver // ignore: cast_nullable_to_non_nullable
as int,uploadRatio: null == uploadRatio ? _self.uploadRatio : uploadRatio // ignore: cast_nullable_to_non_nullable
as double,addedDate: null == addedDate ? _self.addedDate : addedDate // ignore: cast_nullable_to_non_nullable
as int,activityDate: null == activityDate ? _self.activityDate : activityDate // ignore: cast_nullable_to_non_nullable
as int,doneDate: null == doneDate ? _self.doneDate : doneDate // ignore: cast_nullable_to_non_nullable
as int,secondsSeeding: null == secondsSeeding ? _self.secondsSeeding : secondsSeeding // ignore: cast_nullable_to_non_nullable
as int,secondsDownloading: null == secondsDownloading ? _self.secondsDownloading : secondsDownloading // ignore: cast_nullable_to_non_nullable
as int,queuePosition: null == queuePosition ? _self.queuePosition : queuePosition // ignore: cast_nullable_to_non_nullable
as int,isFinished: null == isFinished ? _self.isFinished : isFinished // ignore: cast_nullable_to_non_nullable
as bool,isStalled: null == isStalled ? _self.isStalled : isStalled // ignore: cast_nullable_to_non_nullable
as bool,downloadLimited: null == downloadLimited ? _self.downloadLimited : downloadLimited // ignore: cast_nullable_to_non_nullable
as bool,uploadLimited: null == uploadLimited ? _self.uploadLimited : uploadLimited // ignore: cast_nullable_to_non_nullable
as bool,forceStart: null == forceStart ? _self.forceStart : forceStart // ignore: cast_nullable_to_non_nullable
as bool,autoTmm: null == autoTmm ? _self.autoTmm : autoTmm // ignore: cast_nullable_to_non_nullable
as bool,superSeeding: null == superSeeding ? _self.superSeeding : superSeeding // ignore: cast_nullable_to_non_nullable
as bool,contentPath: null == contentPath ? _self.contentPath : contentPath // ignore: cast_nullable_to_non_nullable
as String,downloadLimit: null == downloadLimit ? _self.downloadLimit : downloadLimit // ignore: cast_nullable_to_non_nullable
as int,uploadLimit: null == uploadLimit ? _self.uploadLimit : uploadLimit // ignore: cast_nullable_to_non_nullable
as int,seedRatioLimit: null == seedRatioLimit ? _self.seedRatioLimit : seedRatioLimit // ignore: cast_nullable_to_non_nullable
as double,seedRatioMode: null == seedRatioMode ? _self.seedRatioMode : seedRatioMode // ignore: cast_nullable_to_non_nullable
as int,leftUntilDone: null == leftUntilDone ? _self.leftUntilDone : leftUntilDone // ignore: cast_nullable_to_non_nullable
as int,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as int,errorString: null == errorString ? _self.errorString : errorString // ignore: cast_nullable_to_non_nullable
as String,downloadDir: null == downloadDir ? _self.downloadDir : downloadDir // ignore: cast_nullable_to_non_nullable
as String,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,magnetLink: null == magnetLink ? _self.magnetLink : magnetLink // ignore: cast_nullable_to_non_nullable
as String,torrentFile: null == torrentFile ? _self.torrentFile : torrentFile // ignore: cast_nullable_to_non_nullable
as String,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>,trackerStats: null == trackerStats ? _self.trackerStats : trackerStats // ignore: cast_nullable_to_non_nullable
as List<TrackerStat>,peersGettingFromUs: null == peersGettingFromUs ? _self.peersGettingFromUs : peersGettingFromUs // ignore: cast_nullable_to_non_nullable
as int,peersSendingToUs: null == peersSendingToUs ? _self.peersSendingToUs : peersSendingToUs // ignore: cast_nullable_to_non_nullable
as int,bandwidthPriority: null == bandwidthPriority ? _self.bandwidthPriority : bandwidthPriority // ignore: cast_nullable_to_non_nullable
as int,recheckProgress: null == recheckProgress ? _self.recheckProgress : recheckProgress // ignore: cast_nullable_to_non_nullable
as double,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as int,trackerUrl: null == trackerUrl ? _self.trackerUrl : trackerUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Torrent].
extension TorrentPatterns on Torrent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Torrent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Torrent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Torrent value)  $default,){
final _that = this;
switch (_that) {
case _Torrent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Torrent value)?  $default,){
final _that = this;
switch (_that) {
case _Torrent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String category,  String hashString,  double percentDone,  double percentComplete,  int status,  int rateDownload,  int rateUpload,  int sizeWhenDone,  int totalSize,  int downloadedEver,  int uploadedEver,  double uploadRatio,  int addedDate,  int activityDate,  int doneDate,  int secondsSeeding,  int secondsDownloading,  int queuePosition,  bool isFinished,  bool isStalled,  bool downloadLimited,  bool uploadLimited,  bool forceStart,  bool autoTmm,  bool superSeeding,  String contentPath,  int downloadLimit,  int uploadLimit,  double seedRatioLimit,  int seedRatioMode,  int leftUntilDone,  int error,  String errorString,  String downloadDir,  String comment,  String magnetLink,  String torrentFile,  List<String> labels,  List<TrackerStat> trackerStats,  int peersGettingFromUs,  int peersSendingToUs,  int bandwidthPriority,  double recheckProgress,  int startDate,  String trackerUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Torrent() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.hashString,_that.percentDone,_that.percentComplete,_that.status,_that.rateDownload,_that.rateUpload,_that.sizeWhenDone,_that.totalSize,_that.downloadedEver,_that.uploadedEver,_that.uploadRatio,_that.addedDate,_that.activityDate,_that.doneDate,_that.secondsSeeding,_that.secondsDownloading,_that.queuePosition,_that.isFinished,_that.isStalled,_that.downloadLimited,_that.uploadLimited,_that.forceStart,_that.autoTmm,_that.superSeeding,_that.contentPath,_that.downloadLimit,_that.uploadLimit,_that.seedRatioLimit,_that.seedRatioMode,_that.leftUntilDone,_that.error,_that.errorString,_that.downloadDir,_that.comment,_that.magnetLink,_that.torrentFile,_that.labels,_that.trackerStats,_that.peersGettingFromUs,_that.peersSendingToUs,_that.bandwidthPriority,_that.recheckProgress,_that.startDate,_that.trackerUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String category,  String hashString,  double percentDone,  double percentComplete,  int status,  int rateDownload,  int rateUpload,  int sizeWhenDone,  int totalSize,  int downloadedEver,  int uploadedEver,  double uploadRatio,  int addedDate,  int activityDate,  int doneDate,  int secondsSeeding,  int secondsDownloading,  int queuePosition,  bool isFinished,  bool isStalled,  bool downloadLimited,  bool uploadLimited,  bool forceStart,  bool autoTmm,  bool superSeeding,  String contentPath,  int downloadLimit,  int uploadLimit,  double seedRatioLimit,  int seedRatioMode,  int leftUntilDone,  int error,  String errorString,  String downloadDir,  String comment,  String magnetLink,  String torrentFile,  List<String> labels,  List<TrackerStat> trackerStats,  int peersGettingFromUs,  int peersSendingToUs,  int bandwidthPriority,  double recheckProgress,  int startDate,  String trackerUrl)  $default,) {final _that = this;
switch (_that) {
case _Torrent():
return $default(_that.id,_that.name,_that.category,_that.hashString,_that.percentDone,_that.percentComplete,_that.status,_that.rateDownload,_that.rateUpload,_that.sizeWhenDone,_that.totalSize,_that.downloadedEver,_that.uploadedEver,_that.uploadRatio,_that.addedDate,_that.activityDate,_that.doneDate,_that.secondsSeeding,_that.secondsDownloading,_that.queuePosition,_that.isFinished,_that.isStalled,_that.downloadLimited,_that.uploadLimited,_that.forceStart,_that.autoTmm,_that.superSeeding,_that.contentPath,_that.downloadLimit,_that.uploadLimit,_that.seedRatioLimit,_that.seedRatioMode,_that.leftUntilDone,_that.error,_that.errorString,_that.downloadDir,_that.comment,_that.magnetLink,_that.torrentFile,_that.labels,_that.trackerStats,_that.peersGettingFromUs,_that.peersSendingToUs,_that.bandwidthPriority,_that.recheckProgress,_that.startDate,_that.trackerUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String category,  String hashString,  double percentDone,  double percentComplete,  int status,  int rateDownload,  int rateUpload,  int sizeWhenDone,  int totalSize,  int downloadedEver,  int uploadedEver,  double uploadRatio,  int addedDate,  int activityDate,  int doneDate,  int secondsSeeding,  int secondsDownloading,  int queuePosition,  bool isFinished,  bool isStalled,  bool downloadLimited,  bool uploadLimited,  bool forceStart,  bool autoTmm,  bool superSeeding,  String contentPath,  int downloadLimit,  int uploadLimit,  double seedRatioLimit,  int seedRatioMode,  int leftUntilDone,  int error,  String errorString,  String downloadDir,  String comment,  String magnetLink,  String torrentFile,  List<String> labels,  List<TrackerStat> trackerStats,  int peersGettingFromUs,  int peersSendingToUs,  int bandwidthPriority,  double recheckProgress,  int startDate,  String trackerUrl)?  $default,) {final _that = this;
switch (_that) {
case _Torrent() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.hashString,_that.percentDone,_that.percentComplete,_that.status,_that.rateDownload,_that.rateUpload,_that.sizeWhenDone,_that.totalSize,_that.downloadedEver,_that.uploadedEver,_that.uploadRatio,_that.addedDate,_that.activityDate,_that.doneDate,_that.secondsSeeding,_that.secondsDownloading,_that.queuePosition,_that.isFinished,_that.isStalled,_that.downloadLimited,_that.uploadLimited,_that.forceStart,_that.autoTmm,_that.superSeeding,_that.contentPath,_that.downloadLimit,_that.uploadLimit,_that.seedRatioLimit,_that.seedRatioMode,_that.leftUntilDone,_that.error,_that.errorString,_that.downloadDir,_that.comment,_that.magnetLink,_that.torrentFile,_that.labels,_that.trackerStats,_that.peersGettingFromUs,_that.peersSendingToUs,_that.bandwidthPriority,_that.recheckProgress,_that.startDate,_that.trackerUrl);case _:
  return null;

}
}

}

/// @nodoc


class _Torrent extends Torrent {
  const _Torrent({this.id = 0, this.name = '', this.category = '', this.hashString = '', this.percentDone = 0.0, this.percentComplete = 0.0, this.status = 0, this.rateDownload = 0, this.rateUpload = 0, this.sizeWhenDone = 0, this.totalSize = 0, this.downloadedEver = 0, this.uploadedEver = 0, this.uploadRatio = 0.0, this.addedDate = 0, this.activityDate = 0, this.doneDate = 0, this.secondsSeeding = 0, this.secondsDownloading = 0, this.queuePosition = 0, this.isFinished = false, this.isStalled = false, this.downloadLimited = false, this.uploadLimited = false, this.forceStart = false, this.autoTmm = false, this.superSeeding = false, this.contentPath = '', this.downloadLimit = 0, this.uploadLimit = 0, this.seedRatioLimit = 0.0, this.seedRatioMode = 0, this.leftUntilDone = 0, this.error = 0, this.errorString = '', this.downloadDir = '', this.comment = '', this.magnetLink = '', this.torrentFile = '', final  List<String> labels = const [], final  List<TrackerStat> trackerStats = const [], this.peersGettingFromUs = 0, this.peersSendingToUs = 0, this.bandwidthPriority = 0, this.recheckProgress = 0.0, this.startDate = 0, this.trackerUrl = ''}): _labels = labels,_trackerStats = trackerStats,super._();
  

@override@JsonKey() final  int id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String category;
@override@JsonKey() final  String hashString;
@override@JsonKey() final  double percentDone;
@override@JsonKey() final  double percentComplete;
@override@JsonKey() final  int status;
@override@JsonKey() final  int rateDownload;
@override@JsonKey() final  int rateUpload;
@override@JsonKey() final  int sizeWhenDone;
@override@JsonKey() final  int totalSize;
@override@JsonKey() final  int downloadedEver;
@override@JsonKey() final  int uploadedEver;
@override@JsonKey() final  double uploadRatio;
@override@JsonKey() final  int addedDate;
@override@JsonKey() final  int activityDate;
@override@JsonKey() final  int doneDate;
@override@JsonKey() final  int secondsSeeding;
@override@JsonKey() final  int secondsDownloading;
@override@JsonKey() final  int queuePosition;
@override@JsonKey() final  bool isFinished;
@override@JsonKey() final  bool isStalled;
@override@JsonKey() final  bool downloadLimited;
@override@JsonKey() final  bool uploadLimited;
@override@JsonKey() final  bool forceStart;
@override@JsonKey() final  bool autoTmm;
@override@JsonKey() final  bool superSeeding;
@override@JsonKey() final  String contentPath;
@override@JsonKey() final  int downloadLimit;
@override@JsonKey() final  int uploadLimit;
@override@JsonKey() final  double seedRatioLimit;
@override@JsonKey() final  int seedRatioMode;
@override@JsonKey() final  int leftUntilDone;
@override@JsonKey() final  int error;
@override@JsonKey() final  String errorString;
@override@JsonKey() final  String downloadDir;
@override@JsonKey() final  String comment;
@override@JsonKey() final  String magnetLink;
@override@JsonKey() final  String torrentFile;
 final  List<String> _labels;
@override@JsonKey() List<String> get labels {
  if (_labels is EqualUnmodifiableListView) return _labels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_labels);
}

 final  List<TrackerStat> _trackerStats;
@override@JsonKey() List<TrackerStat> get trackerStats {
  if (_trackerStats is EqualUnmodifiableListView) return _trackerStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trackerStats);
}

@override@JsonKey() final  int peersGettingFromUs;
@override@JsonKey() final  int peersSendingToUs;
@override@JsonKey() final  int bandwidthPriority;
@override@JsonKey() final  double recheckProgress;
@override@JsonKey() final  int startDate;
@override@JsonKey() final  String trackerUrl;

/// Create a copy of Torrent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TorrentCopyWith<_Torrent> get copyWith => __$TorrentCopyWithImpl<_Torrent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Torrent&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.hashString, hashString) || other.hashString == hashString)&&(identical(other.percentDone, percentDone) || other.percentDone == percentDone)&&(identical(other.percentComplete, percentComplete) || other.percentComplete == percentComplete)&&(identical(other.status, status) || other.status == status)&&(identical(other.rateDownload, rateDownload) || other.rateDownload == rateDownload)&&(identical(other.rateUpload, rateUpload) || other.rateUpload == rateUpload)&&(identical(other.sizeWhenDone, sizeWhenDone) || other.sizeWhenDone == sizeWhenDone)&&(identical(other.totalSize, totalSize) || other.totalSize == totalSize)&&(identical(other.downloadedEver, downloadedEver) || other.downloadedEver == downloadedEver)&&(identical(other.uploadedEver, uploadedEver) || other.uploadedEver == uploadedEver)&&(identical(other.uploadRatio, uploadRatio) || other.uploadRatio == uploadRatio)&&(identical(other.addedDate, addedDate) || other.addedDate == addedDate)&&(identical(other.activityDate, activityDate) || other.activityDate == activityDate)&&(identical(other.doneDate, doneDate) || other.doneDate == doneDate)&&(identical(other.secondsSeeding, secondsSeeding) || other.secondsSeeding == secondsSeeding)&&(identical(other.secondsDownloading, secondsDownloading) || other.secondsDownloading == secondsDownloading)&&(identical(other.queuePosition, queuePosition) || other.queuePosition == queuePosition)&&(identical(other.isFinished, isFinished) || other.isFinished == isFinished)&&(identical(other.isStalled, isStalled) || other.isStalled == isStalled)&&(identical(other.downloadLimited, downloadLimited) || other.downloadLimited == downloadLimited)&&(identical(other.uploadLimited, uploadLimited) || other.uploadLimited == uploadLimited)&&(identical(other.forceStart, forceStart) || other.forceStart == forceStart)&&(identical(other.autoTmm, autoTmm) || other.autoTmm == autoTmm)&&(identical(other.superSeeding, superSeeding) || other.superSeeding == superSeeding)&&(identical(other.contentPath, contentPath) || other.contentPath == contentPath)&&(identical(other.downloadLimit, downloadLimit) || other.downloadLimit == downloadLimit)&&(identical(other.uploadLimit, uploadLimit) || other.uploadLimit == uploadLimit)&&(identical(other.seedRatioLimit, seedRatioLimit) || other.seedRatioLimit == seedRatioLimit)&&(identical(other.seedRatioMode, seedRatioMode) || other.seedRatioMode == seedRatioMode)&&(identical(other.leftUntilDone, leftUntilDone) || other.leftUntilDone == leftUntilDone)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorString, errorString) || other.errorString == errorString)&&(identical(other.downloadDir, downloadDir) || other.downloadDir == downloadDir)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.magnetLink, magnetLink) || other.magnetLink == magnetLink)&&(identical(other.torrentFile, torrentFile) || other.torrentFile == torrentFile)&&const DeepCollectionEquality().equals(other._labels, _labels)&&const DeepCollectionEquality().equals(other._trackerStats, _trackerStats)&&(identical(other.peersGettingFromUs, peersGettingFromUs) || other.peersGettingFromUs == peersGettingFromUs)&&(identical(other.peersSendingToUs, peersSendingToUs) || other.peersSendingToUs == peersSendingToUs)&&(identical(other.bandwidthPriority, bandwidthPriority) || other.bandwidthPriority == bandwidthPriority)&&(identical(other.recheckProgress, recheckProgress) || other.recheckProgress == recheckProgress)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.trackerUrl, trackerUrl) || other.trackerUrl == trackerUrl));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,name,category,hashString,percentDone,percentComplete,status,rateDownload,rateUpload,sizeWhenDone,totalSize,downloadedEver,uploadedEver,uploadRatio,addedDate,activityDate,doneDate,secondsSeeding,secondsDownloading,queuePosition,isFinished,isStalled,downloadLimited,uploadLimited,forceStart,autoTmm,superSeeding,contentPath,downloadLimit,uploadLimit,seedRatioLimit,seedRatioMode,leftUntilDone,error,errorString,downloadDir,comment,magnetLink,torrentFile,const DeepCollectionEquality().hash(_labels),const DeepCollectionEquality().hash(_trackerStats),peersGettingFromUs,peersSendingToUs,bandwidthPriority,recheckProgress,startDate,trackerUrl]);

@override
String toString() {
  return 'Torrent(id: $id, name: $name, category: $category, hashString: $hashString, percentDone: $percentDone, percentComplete: $percentComplete, status: $status, rateDownload: $rateDownload, rateUpload: $rateUpload, sizeWhenDone: $sizeWhenDone, totalSize: $totalSize, downloadedEver: $downloadedEver, uploadedEver: $uploadedEver, uploadRatio: $uploadRatio, addedDate: $addedDate, activityDate: $activityDate, doneDate: $doneDate, secondsSeeding: $secondsSeeding, secondsDownloading: $secondsDownloading, queuePosition: $queuePosition, isFinished: $isFinished, isStalled: $isStalled, downloadLimited: $downloadLimited, uploadLimited: $uploadLimited, forceStart: $forceStart, autoTmm: $autoTmm, superSeeding: $superSeeding, contentPath: $contentPath, downloadLimit: $downloadLimit, uploadLimit: $uploadLimit, seedRatioLimit: $seedRatioLimit, seedRatioMode: $seedRatioMode, leftUntilDone: $leftUntilDone, error: $error, errorString: $errorString, downloadDir: $downloadDir, comment: $comment, magnetLink: $magnetLink, torrentFile: $torrentFile, labels: $labels, trackerStats: $trackerStats, peersGettingFromUs: $peersGettingFromUs, peersSendingToUs: $peersSendingToUs, bandwidthPriority: $bandwidthPriority, recheckProgress: $recheckProgress, startDate: $startDate, trackerUrl: $trackerUrl)';
}


}

/// @nodoc
abstract mixin class _$TorrentCopyWith<$Res> implements $TorrentCopyWith<$Res> {
  factory _$TorrentCopyWith(_Torrent value, $Res Function(_Torrent) _then) = __$TorrentCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String category, String hashString, double percentDone, double percentComplete, int status, int rateDownload, int rateUpload, int sizeWhenDone, int totalSize, int downloadedEver, int uploadedEver, double uploadRatio, int addedDate, int activityDate, int doneDate, int secondsSeeding, int secondsDownloading, int queuePosition, bool isFinished, bool isStalled, bool downloadLimited, bool uploadLimited, bool forceStart, bool autoTmm, bool superSeeding, String contentPath, int downloadLimit, int uploadLimit, double seedRatioLimit, int seedRatioMode, int leftUntilDone, int error, String errorString, String downloadDir, String comment, String magnetLink, String torrentFile, List<String> labels, List<TrackerStat> trackerStats, int peersGettingFromUs, int peersSendingToUs, int bandwidthPriority, double recheckProgress, int startDate, String trackerUrl
});




}
/// @nodoc
class __$TorrentCopyWithImpl<$Res>
    implements _$TorrentCopyWith<$Res> {
  __$TorrentCopyWithImpl(this._self, this._then);

  final _Torrent _self;
  final $Res Function(_Torrent) _then;

/// Create a copy of Torrent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? category = null,Object? hashString = null,Object? percentDone = null,Object? percentComplete = null,Object? status = null,Object? rateDownload = null,Object? rateUpload = null,Object? sizeWhenDone = null,Object? totalSize = null,Object? downloadedEver = null,Object? uploadedEver = null,Object? uploadRatio = null,Object? addedDate = null,Object? activityDate = null,Object? doneDate = null,Object? secondsSeeding = null,Object? secondsDownloading = null,Object? queuePosition = null,Object? isFinished = null,Object? isStalled = null,Object? downloadLimited = null,Object? uploadLimited = null,Object? forceStart = null,Object? autoTmm = null,Object? superSeeding = null,Object? contentPath = null,Object? downloadLimit = null,Object? uploadLimit = null,Object? seedRatioLimit = null,Object? seedRatioMode = null,Object? leftUntilDone = null,Object? error = null,Object? errorString = null,Object? downloadDir = null,Object? comment = null,Object? magnetLink = null,Object? torrentFile = null,Object? labels = null,Object? trackerStats = null,Object? peersGettingFromUs = null,Object? peersSendingToUs = null,Object? bandwidthPriority = null,Object? recheckProgress = null,Object? startDate = null,Object? trackerUrl = null,}) {
  return _then(_Torrent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,hashString: null == hashString ? _self.hashString : hashString // ignore: cast_nullable_to_non_nullable
as String,percentDone: null == percentDone ? _self.percentDone : percentDone // ignore: cast_nullable_to_non_nullable
as double,percentComplete: null == percentComplete ? _self.percentComplete : percentComplete // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,rateDownload: null == rateDownload ? _self.rateDownload : rateDownload // ignore: cast_nullable_to_non_nullable
as int,rateUpload: null == rateUpload ? _self.rateUpload : rateUpload // ignore: cast_nullable_to_non_nullable
as int,sizeWhenDone: null == sizeWhenDone ? _self.sizeWhenDone : sizeWhenDone // ignore: cast_nullable_to_non_nullable
as int,totalSize: null == totalSize ? _self.totalSize : totalSize // ignore: cast_nullable_to_non_nullable
as int,downloadedEver: null == downloadedEver ? _self.downloadedEver : downloadedEver // ignore: cast_nullable_to_non_nullable
as int,uploadedEver: null == uploadedEver ? _self.uploadedEver : uploadedEver // ignore: cast_nullable_to_non_nullable
as int,uploadRatio: null == uploadRatio ? _self.uploadRatio : uploadRatio // ignore: cast_nullable_to_non_nullable
as double,addedDate: null == addedDate ? _self.addedDate : addedDate // ignore: cast_nullable_to_non_nullable
as int,activityDate: null == activityDate ? _self.activityDate : activityDate // ignore: cast_nullable_to_non_nullable
as int,doneDate: null == doneDate ? _self.doneDate : doneDate // ignore: cast_nullable_to_non_nullable
as int,secondsSeeding: null == secondsSeeding ? _self.secondsSeeding : secondsSeeding // ignore: cast_nullable_to_non_nullable
as int,secondsDownloading: null == secondsDownloading ? _self.secondsDownloading : secondsDownloading // ignore: cast_nullable_to_non_nullable
as int,queuePosition: null == queuePosition ? _self.queuePosition : queuePosition // ignore: cast_nullable_to_non_nullable
as int,isFinished: null == isFinished ? _self.isFinished : isFinished // ignore: cast_nullable_to_non_nullable
as bool,isStalled: null == isStalled ? _self.isStalled : isStalled // ignore: cast_nullable_to_non_nullable
as bool,downloadLimited: null == downloadLimited ? _self.downloadLimited : downloadLimited // ignore: cast_nullable_to_non_nullable
as bool,uploadLimited: null == uploadLimited ? _self.uploadLimited : uploadLimited // ignore: cast_nullable_to_non_nullable
as bool,forceStart: null == forceStart ? _self.forceStart : forceStart // ignore: cast_nullable_to_non_nullable
as bool,autoTmm: null == autoTmm ? _self.autoTmm : autoTmm // ignore: cast_nullable_to_non_nullable
as bool,superSeeding: null == superSeeding ? _self.superSeeding : superSeeding // ignore: cast_nullable_to_non_nullable
as bool,contentPath: null == contentPath ? _self.contentPath : contentPath // ignore: cast_nullable_to_non_nullable
as String,downloadLimit: null == downloadLimit ? _self.downloadLimit : downloadLimit // ignore: cast_nullable_to_non_nullable
as int,uploadLimit: null == uploadLimit ? _self.uploadLimit : uploadLimit // ignore: cast_nullable_to_non_nullable
as int,seedRatioLimit: null == seedRatioLimit ? _self.seedRatioLimit : seedRatioLimit // ignore: cast_nullable_to_non_nullable
as double,seedRatioMode: null == seedRatioMode ? _self.seedRatioMode : seedRatioMode // ignore: cast_nullable_to_non_nullable
as int,leftUntilDone: null == leftUntilDone ? _self.leftUntilDone : leftUntilDone // ignore: cast_nullable_to_non_nullable
as int,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as int,errorString: null == errorString ? _self.errorString : errorString // ignore: cast_nullable_to_non_nullable
as String,downloadDir: null == downloadDir ? _self.downloadDir : downloadDir // ignore: cast_nullable_to_non_nullable
as String,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,magnetLink: null == magnetLink ? _self.magnetLink : magnetLink // ignore: cast_nullable_to_non_nullable
as String,torrentFile: null == torrentFile ? _self.torrentFile : torrentFile // ignore: cast_nullable_to_non_nullable
as String,labels: null == labels ? _self._labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>,trackerStats: null == trackerStats ? _self._trackerStats : trackerStats // ignore: cast_nullable_to_non_nullable
as List<TrackerStat>,peersGettingFromUs: null == peersGettingFromUs ? _self.peersGettingFromUs : peersGettingFromUs // ignore: cast_nullable_to_non_nullable
as int,peersSendingToUs: null == peersSendingToUs ? _self.peersSendingToUs : peersSendingToUs // ignore: cast_nullable_to_non_nullable
as int,bandwidthPriority: null == bandwidthPriority ? _self.bandwidthPriority : bandwidthPriority // ignore: cast_nullable_to_non_nullable
as int,recheckProgress: null == recheckProgress ? _self.recheckProgress : recheckProgress // ignore: cast_nullable_to_non_nullable
as double,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as int,trackerUrl: null == trackerUrl ? _self.trackerUrl : trackerUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$SessionStats {

 int get downloadedBytes; int get uploadedBytes; int get filesAdded; int get secondsActive; int get sessionCount;
/// Create a copy of SessionStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionStatsCopyWith<SessionStats> get copyWith => _$SessionStatsCopyWithImpl<SessionStats>(this as SessionStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionStats&&(identical(other.downloadedBytes, downloadedBytes) || other.downloadedBytes == downloadedBytes)&&(identical(other.uploadedBytes, uploadedBytes) || other.uploadedBytes == uploadedBytes)&&(identical(other.filesAdded, filesAdded) || other.filesAdded == filesAdded)&&(identical(other.secondsActive, secondsActive) || other.secondsActive == secondsActive)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount));
}


@override
int get hashCode => Object.hash(runtimeType,downloadedBytes,uploadedBytes,filesAdded,secondsActive,sessionCount);

@override
String toString() {
  return 'SessionStats(downloadedBytes: $downloadedBytes, uploadedBytes: $uploadedBytes, filesAdded: $filesAdded, secondsActive: $secondsActive, sessionCount: $sessionCount)';
}


}

/// @nodoc
abstract mixin class $SessionStatsCopyWith<$Res>  {
  factory $SessionStatsCopyWith(SessionStats value, $Res Function(SessionStats) _then) = _$SessionStatsCopyWithImpl;
@useResult
$Res call({
 int downloadedBytes, int uploadedBytes, int filesAdded, int secondsActive, int sessionCount
});




}
/// @nodoc
class _$SessionStatsCopyWithImpl<$Res>
    implements $SessionStatsCopyWith<$Res> {
  _$SessionStatsCopyWithImpl(this._self, this._then);

  final SessionStats _self;
  final $Res Function(SessionStats) _then;

/// Create a copy of SessionStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? downloadedBytes = null,Object? uploadedBytes = null,Object? filesAdded = null,Object? secondsActive = null,Object? sessionCount = null,}) {
  return _then(_self.copyWith(
downloadedBytes: null == downloadedBytes ? _self.downloadedBytes : downloadedBytes // ignore: cast_nullable_to_non_nullable
as int,uploadedBytes: null == uploadedBytes ? _self.uploadedBytes : uploadedBytes // ignore: cast_nullable_to_non_nullable
as int,filesAdded: null == filesAdded ? _self.filesAdded : filesAdded // ignore: cast_nullable_to_non_nullable
as int,secondsActive: null == secondsActive ? _self.secondsActive : secondsActive // ignore: cast_nullable_to_non_nullable
as int,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionStats].
extension SessionStatsPatterns on SessionStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionStats value)  $default,){
final _that = this;
switch (_that) {
case _SessionStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionStats value)?  $default,){
final _that = this;
switch (_that) {
case _SessionStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int downloadedBytes,  int uploadedBytes,  int filesAdded,  int secondsActive,  int sessionCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionStats() when $default != null:
return $default(_that.downloadedBytes,_that.uploadedBytes,_that.filesAdded,_that.secondsActive,_that.sessionCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int downloadedBytes,  int uploadedBytes,  int filesAdded,  int secondsActive,  int sessionCount)  $default,) {final _that = this;
switch (_that) {
case _SessionStats():
return $default(_that.downloadedBytes,_that.uploadedBytes,_that.filesAdded,_that.secondsActive,_that.sessionCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int downloadedBytes,  int uploadedBytes,  int filesAdded,  int secondsActive,  int sessionCount)?  $default,) {final _that = this;
switch (_that) {
case _SessionStats() when $default != null:
return $default(_that.downloadedBytes,_that.uploadedBytes,_that.filesAdded,_that.secondsActive,_that.sessionCount);case _:
  return null;

}
}

}

/// @nodoc


class _SessionStats implements SessionStats {
  const _SessionStats({this.downloadedBytes = 0, this.uploadedBytes = 0, this.filesAdded = 0, this.secondsActive = 0, this.sessionCount = 0});
  

@override@JsonKey() final  int downloadedBytes;
@override@JsonKey() final  int uploadedBytes;
@override@JsonKey() final  int filesAdded;
@override@JsonKey() final  int secondsActive;
@override@JsonKey() final  int sessionCount;

/// Create a copy of SessionStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionStatsCopyWith<_SessionStats> get copyWith => __$SessionStatsCopyWithImpl<_SessionStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionStats&&(identical(other.downloadedBytes, downloadedBytes) || other.downloadedBytes == downloadedBytes)&&(identical(other.uploadedBytes, uploadedBytes) || other.uploadedBytes == uploadedBytes)&&(identical(other.filesAdded, filesAdded) || other.filesAdded == filesAdded)&&(identical(other.secondsActive, secondsActive) || other.secondsActive == secondsActive)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount));
}


@override
int get hashCode => Object.hash(runtimeType,downloadedBytes,uploadedBytes,filesAdded,secondsActive,sessionCount);

@override
String toString() {
  return 'SessionStats(downloadedBytes: $downloadedBytes, uploadedBytes: $uploadedBytes, filesAdded: $filesAdded, secondsActive: $secondsActive, sessionCount: $sessionCount)';
}


}

/// @nodoc
abstract mixin class _$SessionStatsCopyWith<$Res> implements $SessionStatsCopyWith<$Res> {
  factory _$SessionStatsCopyWith(_SessionStats value, $Res Function(_SessionStats) _then) = __$SessionStatsCopyWithImpl;
@override @useResult
$Res call({
 int downloadedBytes, int uploadedBytes, int filesAdded, int secondsActive, int sessionCount
});




}
/// @nodoc
class __$SessionStatsCopyWithImpl<$Res>
    implements _$SessionStatsCopyWith<$Res> {
  __$SessionStatsCopyWithImpl(this._self, this._then);

  final _SessionStats _self;
  final $Res Function(_SessionStats) _then;

/// Create a copy of SessionStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? downloadedBytes = null,Object? uploadedBytes = null,Object? filesAdded = null,Object? secondsActive = null,Object? sessionCount = null,}) {
  return _then(_SessionStats(
downloadedBytes: null == downloadedBytes ? _self.downloadedBytes : downloadedBytes // ignore: cast_nullable_to_non_nullable
as int,uploadedBytes: null == uploadedBytes ? _self.uploadedBytes : uploadedBytes // ignore: cast_nullable_to_non_nullable
as int,filesAdded: null == filesAdded ? _self.filesAdded : filesAdded // ignore: cast_nullable_to_non_nullable
as int,secondsActive: null == secondsActive ? _self.secondsActive : secondsActive // ignore: cast_nullable_to_non_nullable
as int,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$DownloaderStatus {

 int get activeTorrentCount; int get pausedTorrentCount; int get torrentCount; int get downloadSpeed; int get uploadSpeed; SessionStats get cumulativeStats; SessionStats get currentStats;
/// Create a copy of DownloaderStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloaderStatusCopyWith<DownloaderStatus> get copyWith => _$DownloaderStatusCopyWithImpl<DownloaderStatus>(this as DownloaderStatus, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloaderStatus&&(identical(other.activeTorrentCount, activeTorrentCount) || other.activeTorrentCount == activeTorrentCount)&&(identical(other.pausedTorrentCount, pausedTorrentCount) || other.pausedTorrentCount == pausedTorrentCount)&&(identical(other.torrentCount, torrentCount) || other.torrentCount == torrentCount)&&(identical(other.downloadSpeed, downloadSpeed) || other.downloadSpeed == downloadSpeed)&&(identical(other.uploadSpeed, uploadSpeed) || other.uploadSpeed == uploadSpeed)&&(identical(other.cumulativeStats, cumulativeStats) || other.cumulativeStats == cumulativeStats)&&(identical(other.currentStats, currentStats) || other.currentStats == currentStats));
}


@override
int get hashCode => Object.hash(runtimeType,activeTorrentCount,pausedTorrentCount,torrentCount,downloadSpeed,uploadSpeed,cumulativeStats,currentStats);

@override
String toString() {
  return 'DownloaderStatus(activeTorrentCount: $activeTorrentCount, pausedTorrentCount: $pausedTorrentCount, torrentCount: $torrentCount, downloadSpeed: $downloadSpeed, uploadSpeed: $uploadSpeed, cumulativeStats: $cumulativeStats, currentStats: $currentStats)';
}


}

/// @nodoc
abstract mixin class $DownloaderStatusCopyWith<$Res>  {
  factory $DownloaderStatusCopyWith(DownloaderStatus value, $Res Function(DownloaderStatus) _then) = _$DownloaderStatusCopyWithImpl;
@useResult
$Res call({
 int activeTorrentCount, int pausedTorrentCount, int torrentCount, int downloadSpeed, int uploadSpeed, SessionStats cumulativeStats, SessionStats currentStats
});


$SessionStatsCopyWith<$Res> get cumulativeStats;$SessionStatsCopyWith<$Res> get currentStats;

}
/// @nodoc
class _$DownloaderStatusCopyWithImpl<$Res>
    implements $DownloaderStatusCopyWith<$Res> {
  _$DownloaderStatusCopyWithImpl(this._self, this._then);

  final DownloaderStatus _self;
  final $Res Function(DownloaderStatus) _then;

/// Create a copy of DownloaderStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activeTorrentCount = null,Object? pausedTorrentCount = null,Object? torrentCount = null,Object? downloadSpeed = null,Object? uploadSpeed = null,Object? cumulativeStats = null,Object? currentStats = null,}) {
  return _then(_self.copyWith(
activeTorrentCount: null == activeTorrentCount ? _self.activeTorrentCount : activeTorrentCount // ignore: cast_nullable_to_non_nullable
as int,pausedTorrentCount: null == pausedTorrentCount ? _self.pausedTorrentCount : pausedTorrentCount // ignore: cast_nullable_to_non_nullable
as int,torrentCount: null == torrentCount ? _self.torrentCount : torrentCount // ignore: cast_nullable_to_non_nullable
as int,downloadSpeed: null == downloadSpeed ? _self.downloadSpeed : downloadSpeed // ignore: cast_nullable_to_non_nullable
as int,uploadSpeed: null == uploadSpeed ? _self.uploadSpeed : uploadSpeed // ignore: cast_nullable_to_non_nullable
as int,cumulativeStats: null == cumulativeStats ? _self.cumulativeStats : cumulativeStats // ignore: cast_nullable_to_non_nullable
as SessionStats,currentStats: null == currentStats ? _self.currentStats : currentStats // ignore: cast_nullable_to_non_nullable
as SessionStats,
  ));
}
/// Create a copy of DownloaderStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionStatsCopyWith<$Res> get cumulativeStats {
  
  return $SessionStatsCopyWith<$Res>(_self.cumulativeStats, (value) {
    return _then(_self.copyWith(cumulativeStats: value));
  });
}/// Create a copy of DownloaderStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionStatsCopyWith<$Res> get currentStats {
  
  return $SessionStatsCopyWith<$Res>(_self.currentStats, (value) {
    return _then(_self.copyWith(currentStats: value));
  });
}
}


/// Adds pattern-matching-related methods to [DownloaderStatus].
extension DownloaderStatusPatterns on DownloaderStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DownloaderStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DownloaderStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DownloaderStatus value)  $default,){
final _that = this;
switch (_that) {
case _DownloaderStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DownloaderStatus value)?  $default,){
final _that = this;
switch (_that) {
case _DownloaderStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int activeTorrentCount,  int pausedTorrentCount,  int torrentCount,  int downloadSpeed,  int uploadSpeed,  SessionStats cumulativeStats,  SessionStats currentStats)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DownloaderStatus() when $default != null:
return $default(_that.activeTorrentCount,_that.pausedTorrentCount,_that.torrentCount,_that.downloadSpeed,_that.uploadSpeed,_that.cumulativeStats,_that.currentStats);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int activeTorrentCount,  int pausedTorrentCount,  int torrentCount,  int downloadSpeed,  int uploadSpeed,  SessionStats cumulativeStats,  SessionStats currentStats)  $default,) {final _that = this;
switch (_that) {
case _DownloaderStatus():
return $default(_that.activeTorrentCount,_that.pausedTorrentCount,_that.torrentCount,_that.downloadSpeed,_that.uploadSpeed,_that.cumulativeStats,_that.currentStats);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int activeTorrentCount,  int pausedTorrentCount,  int torrentCount,  int downloadSpeed,  int uploadSpeed,  SessionStats cumulativeStats,  SessionStats currentStats)?  $default,) {final _that = this;
switch (_that) {
case _DownloaderStatus() when $default != null:
return $default(_that.activeTorrentCount,_that.pausedTorrentCount,_that.torrentCount,_that.downloadSpeed,_that.uploadSpeed,_that.cumulativeStats,_that.currentStats);case _:
  return null;

}
}

}

/// @nodoc


class _DownloaderStatus implements DownloaderStatus {
  const _DownloaderStatus({this.activeTorrentCount = 0, this.pausedTorrentCount = 0, this.torrentCount = 0, this.downloadSpeed = 0, this.uploadSpeed = 0, this.cumulativeStats = const SessionStats(), this.currentStats = const SessionStats()});
  

@override@JsonKey() final  int activeTorrentCount;
@override@JsonKey() final  int pausedTorrentCount;
@override@JsonKey() final  int torrentCount;
@override@JsonKey() final  int downloadSpeed;
@override@JsonKey() final  int uploadSpeed;
@override@JsonKey() final  SessionStats cumulativeStats;
@override@JsonKey() final  SessionStats currentStats;

/// Create a copy of DownloaderStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloaderStatusCopyWith<_DownloaderStatus> get copyWith => __$DownloaderStatusCopyWithImpl<_DownloaderStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DownloaderStatus&&(identical(other.activeTorrentCount, activeTorrentCount) || other.activeTorrentCount == activeTorrentCount)&&(identical(other.pausedTorrentCount, pausedTorrentCount) || other.pausedTorrentCount == pausedTorrentCount)&&(identical(other.torrentCount, torrentCount) || other.torrentCount == torrentCount)&&(identical(other.downloadSpeed, downloadSpeed) || other.downloadSpeed == downloadSpeed)&&(identical(other.uploadSpeed, uploadSpeed) || other.uploadSpeed == uploadSpeed)&&(identical(other.cumulativeStats, cumulativeStats) || other.cumulativeStats == cumulativeStats)&&(identical(other.currentStats, currentStats) || other.currentStats == currentStats));
}


@override
int get hashCode => Object.hash(runtimeType,activeTorrentCount,pausedTorrentCount,torrentCount,downloadSpeed,uploadSpeed,cumulativeStats,currentStats);

@override
String toString() {
  return 'DownloaderStatus(activeTorrentCount: $activeTorrentCount, pausedTorrentCount: $pausedTorrentCount, torrentCount: $torrentCount, downloadSpeed: $downloadSpeed, uploadSpeed: $uploadSpeed, cumulativeStats: $cumulativeStats, currentStats: $currentStats)';
}


}

/// @nodoc
abstract mixin class _$DownloaderStatusCopyWith<$Res> implements $DownloaderStatusCopyWith<$Res> {
  factory _$DownloaderStatusCopyWith(_DownloaderStatus value, $Res Function(_DownloaderStatus) _then) = __$DownloaderStatusCopyWithImpl;
@override @useResult
$Res call({
 int activeTorrentCount, int pausedTorrentCount, int torrentCount, int downloadSpeed, int uploadSpeed, SessionStats cumulativeStats, SessionStats currentStats
});


@override $SessionStatsCopyWith<$Res> get cumulativeStats;@override $SessionStatsCopyWith<$Res> get currentStats;

}
/// @nodoc
class __$DownloaderStatusCopyWithImpl<$Res>
    implements _$DownloaderStatusCopyWith<$Res> {
  __$DownloaderStatusCopyWithImpl(this._self, this._then);

  final _DownloaderStatus _self;
  final $Res Function(_DownloaderStatus) _then;

/// Create a copy of DownloaderStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activeTorrentCount = null,Object? pausedTorrentCount = null,Object? torrentCount = null,Object? downloadSpeed = null,Object? uploadSpeed = null,Object? cumulativeStats = null,Object? currentStats = null,}) {
  return _then(_DownloaderStatus(
activeTorrentCount: null == activeTorrentCount ? _self.activeTorrentCount : activeTorrentCount // ignore: cast_nullable_to_non_nullable
as int,pausedTorrentCount: null == pausedTorrentCount ? _self.pausedTorrentCount : pausedTorrentCount // ignore: cast_nullable_to_non_nullable
as int,torrentCount: null == torrentCount ? _self.torrentCount : torrentCount // ignore: cast_nullable_to_non_nullable
as int,downloadSpeed: null == downloadSpeed ? _self.downloadSpeed : downloadSpeed // ignore: cast_nullable_to_non_nullable
as int,uploadSpeed: null == uploadSpeed ? _self.uploadSpeed : uploadSpeed // ignore: cast_nullable_to_non_nullable
as int,cumulativeStats: null == cumulativeStats ? _self.cumulativeStats : cumulativeStats // ignore: cast_nullable_to_non_nullable
as SessionStats,currentStats: null == currentStats ? _self.currentStats : currentStats // ignore: cast_nullable_to_non_nullable
as SessionStats,
  ));
}

/// Create a copy of DownloaderStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionStatsCopyWith<$Res> get cumulativeStats {
  
  return $SessionStatsCopyWith<$Res>(_self.cumulativeStats, (value) {
    return _then(_self.copyWith(cumulativeStats: value));
  });
}/// Create a copy of DownloaderStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionStatsCopyWith<$Res> get currentStats {
  
  return $SessionStatsCopyWith<$Res>(_self.currentStats, (value) {
    return _then(_self.copyWith(currentStats: value));
  });
}
}

/// @nodoc
mixin _$DownloaderData {

 List<Torrent> get torrents; DownloaderStatus? get status;
/// Create a copy of DownloaderData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloaderDataCopyWith<DownloaderData> get copyWith => _$DownloaderDataCopyWithImpl<DownloaderData>(this as DownloaderData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloaderData&&const DeepCollectionEquality().equals(other.torrents, torrents)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(torrents),status);

@override
String toString() {
  return 'DownloaderData(torrents: $torrents, status: $status)';
}


}

/// @nodoc
abstract mixin class $DownloaderDataCopyWith<$Res>  {
  factory $DownloaderDataCopyWith(DownloaderData value, $Res Function(DownloaderData) _then) = _$DownloaderDataCopyWithImpl;
@useResult
$Res call({
 List<Torrent> torrents, DownloaderStatus? status
});


$DownloaderStatusCopyWith<$Res>? get status;

}
/// @nodoc
class _$DownloaderDataCopyWithImpl<$Res>
    implements $DownloaderDataCopyWith<$Res> {
  _$DownloaderDataCopyWithImpl(this._self, this._then);

  final DownloaderData _self;
  final $Res Function(DownloaderData) _then;

/// Create a copy of DownloaderData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? torrents = null,Object? status = freezed,}) {
  return _then(_self.copyWith(
torrents: null == torrents ? _self.torrents : torrents // ignore: cast_nullable_to_non_nullable
as List<Torrent>,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DownloaderStatus?,
  ));
}
/// Create a copy of DownloaderData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DownloaderStatusCopyWith<$Res>? get status {
    if (_self.status == null) {
    return null;
  }

  return $DownloaderStatusCopyWith<$Res>(_self.status!, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}


/// Adds pattern-matching-related methods to [DownloaderData].
extension DownloaderDataPatterns on DownloaderData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DownloaderData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DownloaderData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DownloaderData value)  $default,){
final _that = this;
switch (_that) {
case _DownloaderData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DownloaderData value)?  $default,){
final _that = this;
switch (_that) {
case _DownloaderData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Torrent> torrents,  DownloaderStatus? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DownloaderData() when $default != null:
return $default(_that.torrents,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Torrent> torrents,  DownloaderStatus? status)  $default,) {final _that = this;
switch (_that) {
case _DownloaderData():
return $default(_that.torrents,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Torrent> torrents,  DownloaderStatus? status)?  $default,) {final _that = this;
switch (_that) {
case _DownloaderData() when $default != null:
return $default(_that.torrents,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _DownloaderData implements DownloaderData {
  const _DownloaderData({final  List<Torrent> torrents = const [], this.status}): _torrents = torrents;
  

 final  List<Torrent> _torrents;
@override@JsonKey() List<Torrent> get torrents {
  if (_torrents is EqualUnmodifiableListView) return _torrents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_torrents);
}

@override final  DownloaderStatus? status;

/// Create a copy of DownloaderData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloaderDataCopyWith<_DownloaderData> get copyWith => __$DownloaderDataCopyWithImpl<_DownloaderData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DownloaderData&&const DeepCollectionEquality().equals(other._torrents, _torrents)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_torrents),status);

@override
String toString() {
  return 'DownloaderData(torrents: $torrents, status: $status)';
}


}

/// @nodoc
abstract mixin class _$DownloaderDataCopyWith<$Res> implements $DownloaderDataCopyWith<$Res> {
  factory _$DownloaderDataCopyWith(_DownloaderData value, $Res Function(_DownloaderData) _then) = __$DownloaderDataCopyWithImpl;
@override @useResult
$Res call({
 List<Torrent> torrents, DownloaderStatus? status
});


@override $DownloaderStatusCopyWith<$Res>? get status;

}
/// @nodoc
class __$DownloaderDataCopyWithImpl<$Res>
    implements _$DownloaderDataCopyWith<$Res> {
  __$DownloaderDataCopyWithImpl(this._self, this._then);

  final _DownloaderData _self;
  final $Res Function(_DownloaderData) _then;

/// Create a copy of DownloaderData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? torrents = null,Object? status = freezed,}) {
  return _then(_DownloaderData(
torrents: null == torrents ? _self._torrents : torrents // ignore: cast_nullable_to_non_nullable
as List<Torrent>,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DownloaderStatus?,
  ));
}

/// Create a copy of DownloaderData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DownloaderStatusCopyWith<$Res>? get status {
    if (_self.status == null) {
    return null;
  }

  return $DownloaderStatusCopyWith<$Res>(_self.status!, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}

// dart format on
