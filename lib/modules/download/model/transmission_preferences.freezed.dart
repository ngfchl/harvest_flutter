// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transmission_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransmissionPreferences {

@JsonKey(name: 'rpc-version') int get rpcVersion;@JsonKey(name: 'rpc-version-semver') String get rpcVersionSemver;@JsonKey(name: 'rpc-version-minimum') int get rpcVersionMinimum; String get version;@JsonKey(name: 'alt-speed-down') int get altSpeedDown;@JsonKey(name: 'alt-speed-enabled') bool get altSpeedEnabled;@JsonKey(name: 'alt-speed-time-begin') int get altSpeedTimeBegin;@JsonKey(name: 'alt-speed-time-day') int get altSpeedTimeDay;@JsonKey(name: 'alt-speed-time-enabled') bool get altSpeedTimeEnabled;@JsonKey(name: 'alt-speed-time-end') int get altSpeedTimeEnd;@JsonKey(name: 'alt-speed-up') int get altSpeedUp;@JsonKey(name: 'anti-brute-force-enabled') bool get antiBruteForceEnabled;@JsonKey(name: 'anti-brute-force-threshold') int get antiBruteForceThreshold;@JsonKey(name: 'blocklist-enabled') bool get blocklistEnabled;@JsonKey(name: 'blocklist-size') int get blocklistSize;@JsonKey(name: 'blocklist-url') String get blocklistUrl;@JsonKey(name: 'cache-size-mb') int get cacheSizeMb;@JsonKey(name: 'config-dir') String get configDir;@JsonKey(name: 'default-trackers') String get defaultTrackers;@JsonKey(name: 'dht-enabled') bool get dhtEnabled;@JsonKey(name: 'download-dir') String get downloadDir;@JsonKey(name: 'download-dir-free-space') int get downloadDirFreeSpace;@JsonKey(name: 'download-queue-enabled') bool get downloadQueueEnabled;@JsonKey(name: 'download-queue-size') int get downloadQueueSize; String get encryption;@JsonKey(name: 'idle-seeding-limit') int get idleSeedingLimit;@JsonKey(name: 'idle-seeding-limit-enabled') bool get idleSeedingLimitEnabled;@JsonKey(name: 'incomplete-dir') String get incompleteDir;@JsonKey(name: 'incomplete-dir-enabled') bool get incompleteDirEnabled;@JsonKey(name: 'lpd-enabled') bool get lpdEnabled;@JsonKey(name: 'peer-limit-global') int get peerLimitGlobal;@JsonKey(name: 'peer-limit-per-torrent') int get peerLimitPerTorrent;@JsonKey(name: 'peer-port') int get peerPort;@JsonKey(name: 'peer-port-random-on-start') bool get peerPortRandomOnStart;@JsonKey(name: 'pex-enabled') bool get pexEnabled;@JsonKey(name: 'port-forwarding-enabled') bool get portForwardingEnabled;@JsonKey(name: 'queue-stalled-enabled') bool get queueStalledEnabled;@JsonKey(name: 'queue-stalled-minutes') int get queueStalledMinutes;@JsonKey(name: 'rename-partial-files') bool get renamePartialFiles;@JsonKey(name: 'script-torrent-added-enabled') bool get scriptTorrentAddedEnabled;@JsonKey(name: 'script-torrent-added-filename') String get scriptTorrentAddedFilename;@JsonKey(name: 'script-torrent-done-enabled') bool get scriptTorrentDoneEnabled;@JsonKey(name: 'script-torrent-done-filename') String get scriptTorrentDoneFilename;@JsonKey(name: 'script-torrent-done-seeding-enabled') bool get scriptTorrentDoneSeedingEnabled;@JsonKey(name: 'script-torrent-done-seeding-filename') String get scriptTorrentDoneSeedingFilename;@JsonKey(name: 'seed-queue-enabled') bool get seedQueueEnabled;@JsonKey(name: 'seed-queue-size') int get seedQueueSize;@JsonKey(name: 'seedRatioLimit') double get seedRatioLimit;@JsonKey(name: 'seedRatioLimited') bool get seedRatioLimited;@JsonKey(name: 'session-id') String get sessionId;@JsonKey(name: 'speed-limit-down') int get speedLimitDown;@JsonKey(name: 'speed-limit-down-enabled') bool get speedLimitDownEnabled;@JsonKey(name: 'speed-limit-up') int get speedLimitUp;@JsonKey(name: 'speed-limit-up-enabled') bool get speedLimitUpEnabled;@JsonKey(name: 'start-added-torrents') bool get startAddedTorrents;@JsonKey(name: 'tcp-enabled') bool get tcpEnabled;@JsonKey(name: 'trash-original-torrent-files') bool get trashOriginalTorrentFiles;@JsonKey(name: 'utp-enabled') bool get utpEnabled;
/// Create a copy of TransmissionPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransmissionPreferencesCopyWith<TransmissionPreferences> get copyWith => _$TransmissionPreferencesCopyWithImpl<TransmissionPreferences>(this as TransmissionPreferences, _$identity);

  /// Serializes this TransmissionPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransmissionPreferences&&(identical(other.rpcVersion, rpcVersion) || other.rpcVersion == rpcVersion)&&(identical(other.rpcVersionSemver, rpcVersionSemver) || other.rpcVersionSemver == rpcVersionSemver)&&(identical(other.rpcVersionMinimum, rpcVersionMinimum) || other.rpcVersionMinimum == rpcVersionMinimum)&&(identical(other.version, version) || other.version == version)&&(identical(other.altSpeedDown, altSpeedDown) || other.altSpeedDown == altSpeedDown)&&(identical(other.altSpeedEnabled, altSpeedEnabled) || other.altSpeedEnabled == altSpeedEnabled)&&(identical(other.altSpeedTimeBegin, altSpeedTimeBegin) || other.altSpeedTimeBegin == altSpeedTimeBegin)&&(identical(other.altSpeedTimeDay, altSpeedTimeDay) || other.altSpeedTimeDay == altSpeedTimeDay)&&(identical(other.altSpeedTimeEnabled, altSpeedTimeEnabled) || other.altSpeedTimeEnabled == altSpeedTimeEnabled)&&(identical(other.altSpeedTimeEnd, altSpeedTimeEnd) || other.altSpeedTimeEnd == altSpeedTimeEnd)&&(identical(other.altSpeedUp, altSpeedUp) || other.altSpeedUp == altSpeedUp)&&(identical(other.antiBruteForceEnabled, antiBruteForceEnabled) || other.antiBruteForceEnabled == antiBruteForceEnabled)&&(identical(other.antiBruteForceThreshold, antiBruteForceThreshold) || other.antiBruteForceThreshold == antiBruteForceThreshold)&&(identical(other.blocklistEnabled, blocklistEnabled) || other.blocklistEnabled == blocklistEnabled)&&(identical(other.blocklistSize, blocklistSize) || other.blocklistSize == blocklistSize)&&(identical(other.blocklistUrl, blocklistUrl) || other.blocklistUrl == blocklistUrl)&&(identical(other.cacheSizeMb, cacheSizeMb) || other.cacheSizeMb == cacheSizeMb)&&(identical(other.configDir, configDir) || other.configDir == configDir)&&(identical(other.defaultTrackers, defaultTrackers) || other.defaultTrackers == defaultTrackers)&&(identical(other.dhtEnabled, dhtEnabled) || other.dhtEnabled == dhtEnabled)&&(identical(other.downloadDir, downloadDir) || other.downloadDir == downloadDir)&&(identical(other.downloadDirFreeSpace, downloadDirFreeSpace) || other.downloadDirFreeSpace == downloadDirFreeSpace)&&(identical(other.downloadQueueEnabled, downloadQueueEnabled) || other.downloadQueueEnabled == downloadQueueEnabled)&&(identical(other.downloadQueueSize, downloadQueueSize) || other.downloadQueueSize == downloadQueueSize)&&(identical(other.encryption, encryption) || other.encryption == encryption)&&(identical(other.idleSeedingLimit, idleSeedingLimit) || other.idleSeedingLimit == idleSeedingLimit)&&(identical(other.idleSeedingLimitEnabled, idleSeedingLimitEnabled) || other.idleSeedingLimitEnabled == idleSeedingLimitEnabled)&&(identical(other.incompleteDir, incompleteDir) || other.incompleteDir == incompleteDir)&&(identical(other.incompleteDirEnabled, incompleteDirEnabled) || other.incompleteDirEnabled == incompleteDirEnabled)&&(identical(other.lpdEnabled, lpdEnabled) || other.lpdEnabled == lpdEnabled)&&(identical(other.peerLimitGlobal, peerLimitGlobal) || other.peerLimitGlobal == peerLimitGlobal)&&(identical(other.peerLimitPerTorrent, peerLimitPerTorrent) || other.peerLimitPerTorrent == peerLimitPerTorrent)&&(identical(other.peerPort, peerPort) || other.peerPort == peerPort)&&(identical(other.peerPortRandomOnStart, peerPortRandomOnStart) || other.peerPortRandomOnStart == peerPortRandomOnStart)&&(identical(other.pexEnabled, pexEnabled) || other.pexEnabled == pexEnabled)&&(identical(other.portForwardingEnabled, portForwardingEnabled) || other.portForwardingEnabled == portForwardingEnabled)&&(identical(other.queueStalledEnabled, queueStalledEnabled) || other.queueStalledEnabled == queueStalledEnabled)&&(identical(other.queueStalledMinutes, queueStalledMinutes) || other.queueStalledMinutes == queueStalledMinutes)&&(identical(other.renamePartialFiles, renamePartialFiles) || other.renamePartialFiles == renamePartialFiles)&&(identical(other.scriptTorrentAddedEnabled, scriptTorrentAddedEnabled) || other.scriptTorrentAddedEnabled == scriptTorrentAddedEnabled)&&(identical(other.scriptTorrentAddedFilename, scriptTorrentAddedFilename) || other.scriptTorrentAddedFilename == scriptTorrentAddedFilename)&&(identical(other.scriptTorrentDoneEnabled, scriptTorrentDoneEnabled) || other.scriptTorrentDoneEnabled == scriptTorrentDoneEnabled)&&(identical(other.scriptTorrentDoneFilename, scriptTorrentDoneFilename) || other.scriptTorrentDoneFilename == scriptTorrentDoneFilename)&&(identical(other.scriptTorrentDoneSeedingEnabled, scriptTorrentDoneSeedingEnabled) || other.scriptTorrentDoneSeedingEnabled == scriptTorrentDoneSeedingEnabled)&&(identical(other.scriptTorrentDoneSeedingFilename, scriptTorrentDoneSeedingFilename) || other.scriptTorrentDoneSeedingFilename == scriptTorrentDoneSeedingFilename)&&(identical(other.seedQueueEnabled, seedQueueEnabled) || other.seedQueueEnabled == seedQueueEnabled)&&(identical(other.seedQueueSize, seedQueueSize) || other.seedQueueSize == seedQueueSize)&&(identical(other.seedRatioLimit, seedRatioLimit) || other.seedRatioLimit == seedRatioLimit)&&(identical(other.seedRatioLimited, seedRatioLimited) || other.seedRatioLimited == seedRatioLimited)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.speedLimitDown, speedLimitDown) || other.speedLimitDown == speedLimitDown)&&(identical(other.speedLimitDownEnabled, speedLimitDownEnabled) || other.speedLimitDownEnabled == speedLimitDownEnabled)&&(identical(other.speedLimitUp, speedLimitUp) || other.speedLimitUp == speedLimitUp)&&(identical(other.speedLimitUpEnabled, speedLimitUpEnabled) || other.speedLimitUpEnabled == speedLimitUpEnabled)&&(identical(other.startAddedTorrents, startAddedTorrents) || other.startAddedTorrents == startAddedTorrents)&&(identical(other.tcpEnabled, tcpEnabled) || other.tcpEnabled == tcpEnabled)&&(identical(other.trashOriginalTorrentFiles, trashOriginalTorrentFiles) || other.trashOriginalTorrentFiles == trashOriginalTorrentFiles)&&(identical(other.utpEnabled, utpEnabled) || other.utpEnabled == utpEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,rpcVersion,rpcVersionSemver,rpcVersionMinimum,version,altSpeedDown,altSpeedEnabled,altSpeedTimeBegin,altSpeedTimeDay,altSpeedTimeEnabled,altSpeedTimeEnd,altSpeedUp,antiBruteForceEnabled,antiBruteForceThreshold,blocklistEnabled,blocklistSize,blocklistUrl,cacheSizeMb,configDir,defaultTrackers,dhtEnabled,downloadDir,downloadDirFreeSpace,downloadQueueEnabled,downloadQueueSize,encryption,idleSeedingLimit,idleSeedingLimitEnabled,incompleteDir,incompleteDirEnabled,lpdEnabled,peerLimitGlobal,peerLimitPerTorrent,peerPort,peerPortRandomOnStart,pexEnabled,portForwardingEnabled,queueStalledEnabled,queueStalledMinutes,renamePartialFiles,scriptTorrentAddedEnabled,scriptTorrentAddedFilename,scriptTorrentDoneEnabled,scriptTorrentDoneFilename,scriptTorrentDoneSeedingEnabled,scriptTorrentDoneSeedingFilename,seedQueueEnabled,seedQueueSize,seedRatioLimit,seedRatioLimited,sessionId,speedLimitDown,speedLimitDownEnabled,speedLimitUp,speedLimitUpEnabled,startAddedTorrents,tcpEnabled,trashOriginalTorrentFiles,utpEnabled]);

@override
String toString() {
  return 'TransmissionPreferences(rpcVersion: $rpcVersion, rpcVersionSemver: $rpcVersionSemver, rpcVersionMinimum: $rpcVersionMinimum, version: $version, altSpeedDown: $altSpeedDown, altSpeedEnabled: $altSpeedEnabled, altSpeedTimeBegin: $altSpeedTimeBegin, altSpeedTimeDay: $altSpeedTimeDay, altSpeedTimeEnabled: $altSpeedTimeEnabled, altSpeedTimeEnd: $altSpeedTimeEnd, altSpeedUp: $altSpeedUp, antiBruteForceEnabled: $antiBruteForceEnabled, antiBruteForceThreshold: $antiBruteForceThreshold, blocklistEnabled: $blocklistEnabled, blocklistSize: $blocklistSize, blocklistUrl: $blocklistUrl, cacheSizeMb: $cacheSizeMb, configDir: $configDir, defaultTrackers: $defaultTrackers, dhtEnabled: $dhtEnabled, downloadDir: $downloadDir, downloadDirFreeSpace: $downloadDirFreeSpace, downloadQueueEnabled: $downloadQueueEnabled, downloadQueueSize: $downloadQueueSize, encryption: $encryption, idleSeedingLimit: $idleSeedingLimit, idleSeedingLimitEnabled: $idleSeedingLimitEnabled, incompleteDir: $incompleteDir, incompleteDirEnabled: $incompleteDirEnabled, lpdEnabled: $lpdEnabled, peerLimitGlobal: $peerLimitGlobal, peerLimitPerTorrent: $peerLimitPerTorrent, peerPort: $peerPort, peerPortRandomOnStart: $peerPortRandomOnStart, pexEnabled: $pexEnabled, portForwardingEnabled: $portForwardingEnabled, queueStalledEnabled: $queueStalledEnabled, queueStalledMinutes: $queueStalledMinutes, renamePartialFiles: $renamePartialFiles, scriptTorrentAddedEnabled: $scriptTorrentAddedEnabled, scriptTorrentAddedFilename: $scriptTorrentAddedFilename, scriptTorrentDoneEnabled: $scriptTorrentDoneEnabled, scriptTorrentDoneFilename: $scriptTorrentDoneFilename, scriptTorrentDoneSeedingEnabled: $scriptTorrentDoneSeedingEnabled, scriptTorrentDoneSeedingFilename: $scriptTorrentDoneSeedingFilename, seedQueueEnabled: $seedQueueEnabled, seedQueueSize: $seedQueueSize, seedRatioLimit: $seedRatioLimit, seedRatioLimited: $seedRatioLimited, sessionId: $sessionId, speedLimitDown: $speedLimitDown, speedLimitDownEnabled: $speedLimitDownEnabled, speedLimitUp: $speedLimitUp, speedLimitUpEnabled: $speedLimitUpEnabled, startAddedTorrents: $startAddedTorrents, tcpEnabled: $tcpEnabled, trashOriginalTorrentFiles: $trashOriginalTorrentFiles, utpEnabled: $utpEnabled)';
}


}

/// @nodoc
abstract mixin class $TransmissionPreferencesCopyWith<$Res>  {
  factory $TransmissionPreferencesCopyWith(TransmissionPreferences value, $Res Function(TransmissionPreferences) _then) = _$TransmissionPreferencesCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'rpc-version') int rpcVersion,@JsonKey(name: 'rpc-version-semver') String rpcVersionSemver,@JsonKey(name: 'rpc-version-minimum') int rpcVersionMinimum, String version,@JsonKey(name: 'alt-speed-down') int altSpeedDown,@JsonKey(name: 'alt-speed-enabled') bool altSpeedEnabled,@JsonKey(name: 'alt-speed-time-begin') int altSpeedTimeBegin,@JsonKey(name: 'alt-speed-time-day') int altSpeedTimeDay,@JsonKey(name: 'alt-speed-time-enabled') bool altSpeedTimeEnabled,@JsonKey(name: 'alt-speed-time-end') int altSpeedTimeEnd,@JsonKey(name: 'alt-speed-up') int altSpeedUp,@JsonKey(name: 'anti-brute-force-enabled') bool antiBruteForceEnabled,@JsonKey(name: 'anti-brute-force-threshold') int antiBruteForceThreshold,@JsonKey(name: 'blocklist-enabled') bool blocklistEnabled,@JsonKey(name: 'blocklist-size') int blocklistSize,@JsonKey(name: 'blocklist-url') String blocklistUrl,@JsonKey(name: 'cache-size-mb') int cacheSizeMb,@JsonKey(name: 'config-dir') String configDir,@JsonKey(name: 'default-trackers') String defaultTrackers,@JsonKey(name: 'dht-enabled') bool dhtEnabled,@JsonKey(name: 'download-dir') String downloadDir,@JsonKey(name: 'download-dir-free-space') int downloadDirFreeSpace,@JsonKey(name: 'download-queue-enabled') bool downloadQueueEnabled,@JsonKey(name: 'download-queue-size') int downloadQueueSize, String encryption,@JsonKey(name: 'idle-seeding-limit') int idleSeedingLimit,@JsonKey(name: 'idle-seeding-limit-enabled') bool idleSeedingLimitEnabled,@JsonKey(name: 'incomplete-dir') String incompleteDir,@JsonKey(name: 'incomplete-dir-enabled') bool incompleteDirEnabled,@JsonKey(name: 'lpd-enabled') bool lpdEnabled,@JsonKey(name: 'peer-limit-global') int peerLimitGlobal,@JsonKey(name: 'peer-limit-per-torrent') int peerLimitPerTorrent,@JsonKey(name: 'peer-port') int peerPort,@JsonKey(name: 'peer-port-random-on-start') bool peerPortRandomOnStart,@JsonKey(name: 'pex-enabled') bool pexEnabled,@JsonKey(name: 'port-forwarding-enabled') bool portForwardingEnabled,@JsonKey(name: 'queue-stalled-enabled') bool queueStalledEnabled,@JsonKey(name: 'queue-stalled-minutes') int queueStalledMinutes,@JsonKey(name: 'rename-partial-files') bool renamePartialFiles,@JsonKey(name: 'script-torrent-added-enabled') bool scriptTorrentAddedEnabled,@JsonKey(name: 'script-torrent-added-filename') String scriptTorrentAddedFilename,@JsonKey(name: 'script-torrent-done-enabled') bool scriptTorrentDoneEnabled,@JsonKey(name: 'script-torrent-done-filename') String scriptTorrentDoneFilename,@JsonKey(name: 'script-torrent-done-seeding-enabled') bool scriptTorrentDoneSeedingEnabled,@JsonKey(name: 'script-torrent-done-seeding-filename') String scriptTorrentDoneSeedingFilename,@JsonKey(name: 'seed-queue-enabled') bool seedQueueEnabled,@JsonKey(name: 'seed-queue-size') int seedQueueSize,@JsonKey(name: 'seedRatioLimit') double seedRatioLimit,@JsonKey(name: 'seedRatioLimited') bool seedRatioLimited,@JsonKey(name: 'session-id') String sessionId,@JsonKey(name: 'speed-limit-down') int speedLimitDown,@JsonKey(name: 'speed-limit-down-enabled') bool speedLimitDownEnabled,@JsonKey(name: 'speed-limit-up') int speedLimitUp,@JsonKey(name: 'speed-limit-up-enabled') bool speedLimitUpEnabled,@JsonKey(name: 'start-added-torrents') bool startAddedTorrents,@JsonKey(name: 'tcp-enabled') bool tcpEnabled,@JsonKey(name: 'trash-original-torrent-files') bool trashOriginalTorrentFiles,@JsonKey(name: 'utp-enabled') bool utpEnabled
});




}
/// @nodoc
class _$TransmissionPreferencesCopyWithImpl<$Res>
    implements $TransmissionPreferencesCopyWith<$Res> {
  _$TransmissionPreferencesCopyWithImpl(this._self, this._then);

  final TransmissionPreferences _self;
  final $Res Function(TransmissionPreferences) _then;

/// Create a copy of TransmissionPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rpcVersion = null,Object? rpcVersionSemver = null,Object? rpcVersionMinimum = null,Object? version = null,Object? altSpeedDown = null,Object? altSpeedEnabled = null,Object? altSpeedTimeBegin = null,Object? altSpeedTimeDay = null,Object? altSpeedTimeEnabled = null,Object? altSpeedTimeEnd = null,Object? altSpeedUp = null,Object? antiBruteForceEnabled = null,Object? antiBruteForceThreshold = null,Object? blocklistEnabled = null,Object? blocklistSize = null,Object? blocklistUrl = null,Object? cacheSizeMb = null,Object? configDir = null,Object? defaultTrackers = null,Object? dhtEnabled = null,Object? downloadDir = null,Object? downloadDirFreeSpace = null,Object? downloadQueueEnabled = null,Object? downloadQueueSize = null,Object? encryption = null,Object? idleSeedingLimit = null,Object? idleSeedingLimitEnabled = null,Object? incompleteDir = null,Object? incompleteDirEnabled = null,Object? lpdEnabled = null,Object? peerLimitGlobal = null,Object? peerLimitPerTorrent = null,Object? peerPort = null,Object? peerPortRandomOnStart = null,Object? pexEnabled = null,Object? portForwardingEnabled = null,Object? queueStalledEnabled = null,Object? queueStalledMinutes = null,Object? renamePartialFiles = null,Object? scriptTorrentAddedEnabled = null,Object? scriptTorrentAddedFilename = null,Object? scriptTorrentDoneEnabled = null,Object? scriptTorrentDoneFilename = null,Object? scriptTorrentDoneSeedingEnabled = null,Object? scriptTorrentDoneSeedingFilename = null,Object? seedQueueEnabled = null,Object? seedQueueSize = null,Object? seedRatioLimit = null,Object? seedRatioLimited = null,Object? sessionId = null,Object? speedLimitDown = null,Object? speedLimitDownEnabled = null,Object? speedLimitUp = null,Object? speedLimitUpEnabled = null,Object? startAddedTorrents = null,Object? tcpEnabled = null,Object? trashOriginalTorrentFiles = null,Object? utpEnabled = null,}) {
  return _then(_self.copyWith(
rpcVersion: null == rpcVersion ? _self.rpcVersion : rpcVersion // ignore: cast_nullable_to_non_nullable
as int,rpcVersionSemver: null == rpcVersionSemver ? _self.rpcVersionSemver : rpcVersionSemver // ignore: cast_nullable_to_non_nullable
as String,rpcVersionMinimum: null == rpcVersionMinimum ? _self.rpcVersionMinimum : rpcVersionMinimum // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,altSpeedDown: null == altSpeedDown ? _self.altSpeedDown : altSpeedDown // ignore: cast_nullable_to_non_nullable
as int,altSpeedEnabled: null == altSpeedEnabled ? _self.altSpeedEnabled : altSpeedEnabled // ignore: cast_nullable_to_non_nullable
as bool,altSpeedTimeBegin: null == altSpeedTimeBegin ? _self.altSpeedTimeBegin : altSpeedTimeBegin // ignore: cast_nullable_to_non_nullable
as int,altSpeedTimeDay: null == altSpeedTimeDay ? _self.altSpeedTimeDay : altSpeedTimeDay // ignore: cast_nullable_to_non_nullable
as int,altSpeedTimeEnabled: null == altSpeedTimeEnabled ? _self.altSpeedTimeEnabled : altSpeedTimeEnabled // ignore: cast_nullable_to_non_nullable
as bool,altSpeedTimeEnd: null == altSpeedTimeEnd ? _self.altSpeedTimeEnd : altSpeedTimeEnd // ignore: cast_nullable_to_non_nullable
as int,altSpeedUp: null == altSpeedUp ? _self.altSpeedUp : altSpeedUp // ignore: cast_nullable_to_non_nullable
as int,antiBruteForceEnabled: null == antiBruteForceEnabled ? _self.antiBruteForceEnabled : antiBruteForceEnabled // ignore: cast_nullable_to_non_nullable
as bool,antiBruteForceThreshold: null == antiBruteForceThreshold ? _self.antiBruteForceThreshold : antiBruteForceThreshold // ignore: cast_nullable_to_non_nullable
as int,blocklistEnabled: null == blocklistEnabled ? _self.blocklistEnabled : blocklistEnabled // ignore: cast_nullable_to_non_nullable
as bool,blocklistSize: null == blocklistSize ? _self.blocklistSize : blocklistSize // ignore: cast_nullable_to_non_nullable
as int,blocklistUrl: null == blocklistUrl ? _self.blocklistUrl : blocklistUrl // ignore: cast_nullable_to_non_nullable
as String,cacheSizeMb: null == cacheSizeMb ? _self.cacheSizeMb : cacheSizeMb // ignore: cast_nullable_to_non_nullable
as int,configDir: null == configDir ? _self.configDir : configDir // ignore: cast_nullable_to_non_nullable
as String,defaultTrackers: null == defaultTrackers ? _self.defaultTrackers : defaultTrackers // ignore: cast_nullable_to_non_nullable
as String,dhtEnabled: null == dhtEnabled ? _self.dhtEnabled : dhtEnabled // ignore: cast_nullable_to_non_nullable
as bool,downloadDir: null == downloadDir ? _self.downloadDir : downloadDir // ignore: cast_nullable_to_non_nullable
as String,downloadDirFreeSpace: null == downloadDirFreeSpace ? _self.downloadDirFreeSpace : downloadDirFreeSpace // ignore: cast_nullable_to_non_nullable
as int,downloadQueueEnabled: null == downloadQueueEnabled ? _self.downloadQueueEnabled : downloadQueueEnabled // ignore: cast_nullable_to_non_nullable
as bool,downloadQueueSize: null == downloadQueueSize ? _self.downloadQueueSize : downloadQueueSize // ignore: cast_nullable_to_non_nullable
as int,encryption: null == encryption ? _self.encryption : encryption // ignore: cast_nullable_to_non_nullable
as String,idleSeedingLimit: null == idleSeedingLimit ? _self.idleSeedingLimit : idleSeedingLimit // ignore: cast_nullable_to_non_nullable
as int,idleSeedingLimitEnabled: null == idleSeedingLimitEnabled ? _self.idleSeedingLimitEnabled : idleSeedingLimitEnabled // ignore: cast_nullable_to_non_nullable
as bool,incompleteDir: null == incompleteDir ? _self.incompleteDir : incompleteDir // ignore: cast_nullable_to_non_nullable
as String,incompleteDirEnabled: null == incompleteDirEnabled ? _self.incompleteDirEnabled : incompleteDirEnabled // ignore: cast_nullable_to_non_nullable
as bool,lpdEnabled: null == lpdEnabled ? _self.lpdEnabled : lpdEnabled // ignore: cast_nullable_to_non_nullable
as bool,peerLimitGlobal: null == peerLimitGlobal ? _self.peerLimitGlobal : peerLimitGlobal // ignore: cast_nullable_to_non_nullable
as int,peerLimitPerTorrent: null == peerLimitPerTorrent ? _self.peerLimitPerTorrent : peerLimitPerTorrent // ignore: cast_nullable_to_non_nullable
as int,peerPort: null == peerPort ? _self.peerPort : peerPort // ignore: cast_nullable_to_non_nullable
as int,peerPortRandomOnStart: null == peerPortRandomOnStart ? _self.peerPortRandomOnStart : peerPortRandomOnStart // ignore: cast_nullable_to_non_nullable
as bool,pexEnabled: null == pexEnabled ? _self.pexEnabled : pexEnabled // ignore: cast_nullable_to_non_nullable
as bool,portForwardingEnabled: null == portForwardingEnabled ? _self.portForwardingEnabled : portForwardingEnabled // ignore: cast_nullable_to_non_nullable
as bool,queueStalledEnabled: null == queueStalledEnabled ? _self.queueStalledEnabled : queueStalledEnabled // ignore: cast_nullable_to_non_nullable
as bool,queueStalledMinutes: null == queueStalledMinutes ? _self.queueStalledMinutes : queueStalledMinutes // ignore: cast_nullable_to_non_nullable
as int,renamePartialFiles: null == renamePartialFiles ? _self.renamePartialFiles : renamePartialFiles // ignore: cast_nullable_to_non_nullable
as bool,scriptTorrentAddedEnabled: null == scriptTorrentAddedEnabled ? _self.scriptTorrentAddedEnabled : scriptTorrentAddedEnabled // ignore: cast_nullable_to_non_nullable
as bool,scriptTorrentAddedFilename: null == scriptTorrentAddedFilename ? _self.scriptTorrentAddedFilename : scriptTorrentAddedFilename // ignore: cast_nullable_to_non_nullable
as String,scriptTorrentDoneEnabled: null == scriptTorrentDoneEnabled ? _self.scriptTorrentDoneEnabled : scriptTorrentDoneEnabled // ignore: cast_nullable_to_non_nullable
as bool,scriptTorrentDoneFilename: null == scriptTorrentDoneFilename ? _self.scriptTorrentDoneFilename : scriptTorrentDoneFilename // ignore: cast_nullable_to_non_nullable
as String,scriptTorrentDoneSeedingEnabled: null == scriptTorrentDoneSeedingEnabled ? _self.scriptTorrentDoneSeedingEnabled : scriptTorrentDoneSeedingEnabled // ignore: cast_nullable_to_non_nullable
as bool,scriptTorrentDoneSeedingFilename: null == scriptTorrentDoneSeedingFilename ? _self.scriptTorrentDoneSeedingFilename : scriptTorrentDoneSeedingFilename // ignore: cast_nullable_to_non_nullable
as String,seedQueueEnabled: null == seedQueueEnabled ? _self.seedQueueEnabled : seedQueueEnabled // ignore: cast_nullable_to_non_nullable
as bool,seedQueueSize: null == seedQueueSize ? _self.seedQueueSize : seedQueueSize // ignore: cast_nullable_to_non_nullable
as int,seedRatioLimit: null == seedRatioLimit ? _self.seedRatioLimit : seedRatioLimit // ignore: cast_nullable_to_non_nullable
as double,seedRatioLimited: null == seedRatioLimited ? _self.seedRatioLimited : seedRatioLimited // ignore: cast_nullable_to_non_nullable
as bool,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,speedLimitDown: null == speedLimitDown ? _self.speedLimitDown : speedLimitDown // ignore: cast_nullable_to_non_nullable
as int,speedLimitDownEnabled: null == speedLimitDownEnabled ? _self.speedLimitDownEnabled : speedLimitDownEnabled // ignore: cast_nullable_to_non_nullable
as bool,speedLimitUp: null == speedLimitUp ? _self.speedLimitUp : speedLimitUp // ignore: cast_nullable_to_non_nullable
as int,speedLimitUpEnabled: null == speedLimitUpEnabled ? _self.speedLimitUpEnabled : speedLimitUpEnabled // ignore: cast_nullable_to_non_nullable
as bool,startAddedTorrents: null == startAddedTorrents ? _self.startAddedTorrents : startAddedTorrents // ignore: cast_nullable_to_non_nullable
as bool,tcpEnabled: null == tcpEnabled ? _self.tcpEnabled : tcpEnabled // ignore: cast_nullable_to_non_nullable
as bool,trashOriginalTorrentFiles: null == trashOriginalTorrentFiles ? _self.trashOriginalTorrentFiles : trashOriginalTorrentFiles // ignore: cast_nullable_to_non_nullable
as bool,utpEnabled: null == utpEnabled ? _self.utpEnabled : utpEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TransmissionPreferences].
extension TransmissionPreferencesPatterns on TransmissionPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransmissionPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransmissionPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransmissionPreferences value)  $default,){
final _that = this;
switch (_that) {
case _TransmissionPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransmissionPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _TransmissionPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'rpc-version')  int rpcVersion, @JsonKey(name: 'rpc-version-semver')  String rpcVersionSemver, @JsonKey(name: 'rpc-version-minimum')  int rpcVersionMinimum,  String version, @JsonKey(name: 'alt-speed-down')  int altSpeedDown, @JsonKey(name: 'alt-speed-enabled')  bool altSpeedEnabled, @JsonKey(name: 'alt-speed-time-begin')  int altSpeedTimeBegin, @JsonKey(name: 'alt-speed-time-day')  int altSpeedTimeDay, @JsonKey(name: 'alt-speed-time-enabled')  bool altSpeedTimeEnabled, @JsonKey(name: 'alt-speed-time-end')  int altSpeedTimeEnd, @JsonKey(name: 'alt-speed-up')  int altSpeedUp, @JsonKey(name: 'anti-brute-force-enabled')  bool antiBruteForceEnabled, @JsonKey(name: 'anti-brute-force-threshold')  int antiBruteForceThreshold, @JsonKey(name: 'blocklist-enabled')  bool blocklistEnabled, @JsonKey(name: 'blocklist-size')  int blocklistSize, @JsonKey(name: 'blocklist-url')  String blocklistUrl, @JsonKey(name: 'cache-size-mb')  int cacheSizeMb, @JsonKey(name: 'config-dir')  String configDir, @JsonKey(name: 'default-trackers')  String defaultTrackers, @JsonKey(name: 'dht-enabled')  bool dhtEnabled, @JsonKey(name: 'download-dir')  String downloadDir, @JsonKey(name: 'download-dir-free-space')  int downloadDirFreeSpace, @JsonKey(name: 'download-queue-enabled')  bool downloadQueueEnabled, @JsonKey(name: 'download-queue-size')  int downloadQueueSize,  String encryption, @JsonKey(name: 'idle-seeding-limit')  int idleSeedingLimit, @JsonKey(name: 'idle-seeding-limit-enabled')  bool idleSeedingLimitEnabled, @JsonKey(name: 'incomplete-dir')  String incompleteDir, @JsonKey(name: 'incomplete-dir-enabled')  bool incompleteDirEnabled, @JsonKey(name: 'lpd-enabled')  bool lpdEnabled, @JsonKey(name: 'peer-limit-global')  int peerLimitGlobal, @JsonKey(name: 'peer-limit-per-torrent')  int peerLimitPerTorrent, @JsonKey(name: 'peer-port')  int peerPort, @JsonKey(name: 'peer-port-random-on-start')  bool peerPortRandomOnStart, @JsonKey(name: 'pex-enabled')  bool pexEnabled, @JsonKey(name: 'port-forwarding-enabled')  bool portForwardingEnabled, @JsonKey(name: 'queue-stalled-enabled')  bool queueStalledEnabled, @JsonKey(name: 'queue-stalled-minutes')  int queueStalledMinutes, @JsonKey(name: 'rename-partial-files')  bool renamePartialFiles, @JsonKey(name: 'script-torrent-added-enabled')  bool scriptTorrentAddedEnabled, @JsonKey(name: 'script-torrent-added-filename')  String scriptTorrentAddedFilename, @JsonKey(name: 'script-torrent-done-enabled')  bool scriptTorrentDoneEnabled, @JsonKey(name: 'script-torrent-done-filename')  String scriptTorrentDoneFilename, @JsonKey(name: 'script-torrent-done-seeding-enabled')  bool scriptTorrentDoneSeedingEnabled, @JsonKey(name: 'script-torrent-done-seeding-filename')  String scriptTorrentDoneSeedingFilename, @JsonKey(name: 'seed-queue-enabled')  bool seedQueueEnabled, @JsonKey(name: 'seed-queue-size')  int seedQueueSize, @JsonKey(name: 'seedRatioLimit')  double seedRatioLimit, @JsonKey(name: 'seedRatioLimited')  bool seedRatioLimited, @JsonKey(name: 'session-id')  String sessionId, @JsonKey(name: 'speed-limit-down')  int speedLimitDown, @JsonKey(name: 'speed-limit-down-enabled')  bool speedLimitDownEnabled, @JsonKey(name: 'speed-limit-up')  int speedLimitUp, @JsonKey(name: 'speed-limit-up-enabled')  bool speedLimitUpEnabled, @JsonKey(name: 'start-added-torrents')  bool startAddedTorrents, @JsonKey(name: 'tcp-enabled')  bool tcpEnabled, @JsonKey(name: 'trash-original-torrent-files')  bool trashOriginalTorrentFiles, @JsonKey(name: 'utp-enabled')  bool utpEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransmissionPreferences() when $default != null:
return $default(_that.rpcVersion,_that.rpcVersionSemver,_that.rpcVersionMinimum,_that.version,_that.altSpeedDown,_that.altSpeedEnabled,_that.altSpeedTimeBegin,_that.altSpeedTimeDay,_that.altSpeedTimeEnabled,_that.altSpeedTimeEnd,_that.altSpeedUp,_that.antiBruteForceEnabled,_that.antiBruteForceThreshold,_that.blocklistEnabled,_that.blocklistSize,_that.blocklistUrl,_that.cacheSizeMb,_that.configDir,_that.defaultTrackers,_that.dhtEnabled,_that.downloadDir,_that.downloadDirFreeSpace,_that.downloadQueueEnabled,_that.downloadQueueSize,_that.encryption,_that.idleSeedingLimit,_that.idleSeedingLimitEnabled,_that.incompleteDir,_that.incompleteDirEnabled,_that.lpdEnabled,_that.peerLimitGlobal,_that.peerLimitPerTorrent,_that.peerPort,_that.peerPortRandomOnStart,_that.pexEnabled,_that.portForwardingEnabled,_that.queueStalledEnabled,_that.queueStalledMinutes,_that.renamePartialFiles,_that.scriptTorrentAddedEnabled,_that.scriptTorrentAddedFilename,_that.scriptTorrentDoneEnabled,_that.scriptTorrentDoneFilename,_that.scriptTorrentDoneSeedingEnabled,_that.scriptTorrentDoneSeedingFilename,_that.seedQueueEnabled,_that.seedQueueSize,_that.seedRatioLimit,_that.seedRatioLimited,_that.sessionId,_that.speedLimitDown,_that.speedLimitDownEnabled,_that.speedLimitUp,_that.speedLimitUpEnabled,_that.startAddedTorrents,_that.tcpEnabled,_that.trashOriginalTorrentFiles,_that.utpEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'rpc-version')  int rpcVersion, @JsonKey(name: 'rpc-version-semver')  String rpcVersionSemver, @JsonKey(name: 'rpc-version-minimum')  int rpcVersionMinimum,  String version, @JsonKey(name: 'alt-speed-down')  int altSpeedDown, @JsonKey(name: 'alt-speed-enabled')  bool altSpeedEnabled, @JsonKey(name: 'alt-speed-time-begin')  int altSpeedTimeBegin, @JsonKey(name: 'alt-speed-time-day')  int altSpeedTimeDay, @JsonKey(name: 'alt-speed-time-enabled')  bool altSpeedTimeEnabled, @JsonKey(name: 'alt-speed-time-end')  int altSpeedTimeEnd, @JsonKey(name: 'alt-speed-up')  int altSpeedUp, @JsonKey(name: 'anti-brute-force-enabled')  bool antiBruteForceEnabled, @JsonKey(name: 'anti-brute-force-threshold')  int antiBruteForceThreshold, @JsonKey(name: 'blocklist-enabled')  bool blocklistEnabled, @JsonKey(name: 'blocklist-size')  int blocklistSize, @JsonKey(name: 'blocklist-url')  String blocklistUrl, @JsonKey(name: 'cache-size-mb')  int cacheSizeMb, @JsonKey(name: 'config-dir')  String configDir, @JsonKey(name: 'default-trackers')  String defaultTrackers, @JsonKey(name: 'dht-enabled')  bool dhtEnabled, @JsonKey(name: 'download-dir')  String downloadDir, @JsonKey(name: 'download-dir-free-space')  int downloadDirFreeSpace, @JsonKey(name: 'download-queue-enabled')  bool downloadQueueEnabled, @JsonKey(name: 'download-queue-size')  int downloadQueueSize,  String encryption, @JsonKey(name: 'idle-seeding-limit')  int idleSeedingLimit, @JsonKey(name: 'idle-seeding-limit-enabled')  bool idleSeedingLimitEnabled, @JsonKey(name: 'incomplete-dir')  String incompleteDir, @JsonKey(name: 'incomplete-dir-enabled')  bool incompleteDirEnabled, @JsonKey(name: 'lpd-enabled')  bool lpdEnabled, @JsonKey(name: 'peer-limit-global')  int peerLimitGlobal, @JsonKey(name: 'peer-limit-per-torrent')  int peerLimitPerTorrent, @JsonKey(name: 'peer-port')  int peerPort, @JsonKey(name: 'peer-port-random-on-start')  bool peerPortRandomOnStart, @JsonKey(name: 'pex-enabled')  bool pexEnabled, @JsonKey(name: 'port-forwarding-enabled')  bool portForwardingEnabled, @JsonKey(name: 'queue-stalled-enabled')  bool queueStalledEnabled, @JsonKey(name: 'queue-stalled-minutes')  int queueStalledMinutes, @JsonKey(name: 'rename-partial-files')  bool renamePartialFiles, @JsonKey(name: 'script-torrent-added-enabled')  bool scriptTorrentAddedEnabled, @JsonKey(name: 'script-torrent-added-filename')  String scriptTorrentAddedFilename, @JsonKey(name: 'script-torrent-done-enabled')  bool scriptTorrentDoneEnabled, @JsonKey(name: 'script-torrent-done-filename')  String scriptTorrentDoneFilename, @JsonKey(name: 'script-torrent-done-seeding-enabled')  bool scriptTorrentDoneSeedingEnabled, @JsonKey(name: 'script-torrent-done-seeding-filename')  String scriptTorrentDoneSeedingFilename, @JsonKey(name: 'seed-queue-enabled')  bool seedQueueEnabled, @JsonKey(name: 'seed-queue-size')  int seedQueueSize, @JsonKey(name: 'seedRatioLimit')  double seedRatioLimit, @JsonKey(name: 'seedRatioLimited')  bool seedRatioLimited, @JsonKey(name: 'session-id')  String sessionId, @JsonKey(name: 'speed-limit-down')  int speedLimitDown, @JsonKey(name: 'speed-limit-down-enabled')  bool speedLimitDownEnabled, @JsonKey(name: 'speed-limit-up')  int speedLimitUp, @JsonKey(name: 'speed-limit-up-enabled')  bool speedLimitUpEnabled, @JsonKey(name: 'start-added-torrents')  bool startAddedTorrents, @JsonKey(name: 'tcp-enabled')  bool tcpEnabled, @JsonKey(name: 'trash-original-torrent-files')  bool trashOriginalTorrentFiles, @JsonKey(name: 'utp-enabled')  bool utpEnabled)  $default,) {final _that = this;
switch (_that) {
case _TransmissionPreferences():
return $default(_that.rpcVersion,_that.rpcVersionSemver,_that.rpcVersionMinimum,_that.version,_that.altSpeedDown,_that.altSpeedEnabled,_that.altSpeedTimeBegin,_that.altSpeedTimeDay,_that.altSpeedTimeEnabled,_that.altSpeedTimeEnd,_that.altSpeedUp,_that.antiBruteForceEnabled,_that.antiBruteForceThreshold,_that.blocklistEnabled,_that.blocklistSize,_that.blocklistUrl,_that.cacheSizeMb,_that.configDir,_that.defaultTrackers,_that.dhtEnabled,_that.downloadDir,_that.downloadDirFreeSpace,_that.downloadQueueEnabled,_that.downloadQueueSize,_that.encryption,_that.idleSeedingLimit,_that.idleSeedingLimitEnabled,_that.incompleteDir,_that.incompleteDirEnabled,_that.lpdEnabled,_that.peerLimitGlobal,_that.peerLimitPerTorrent,_that.peerPort,_that.peerPortRandomOnStart,_that.pexEnabled,_that.portForwardingEnabled,_that.queueStalledEnabled,_that.queueStalledMinutes,_that.renamePartialFiles,_that.scriptTorrentAddedEnabled,_that.scriptTorrentAddedFilename,_that.scriptTorrentDoneEnabled,_that.scriptTorrentDoneFilename,_that.scriptTorrentDoneSeedingEnabled,_that.scriptTorrentDoneSeedingFilename,_that.seedQueueEnabled,_that.seedQueueSize,_that.seedRatioLimit,_that.seedRatioLimited,_that.sessionId,_that.speedLimitDown,_that.speedLimitDownEnabled,_that.speedLimitUp,_that.speedLimitUpEnabled,_that.startAddedTorrents,_that.tcpEnabled,_that.trashOriginalTorrentFiles,_that.utpEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'rpc-version')  int rpcVersion, @JsonKey(name: 'rpc-version-semver')  String rpcVersionSemver, @JsonKey(name: 'rpc-version-minimum')  int rpcVersionMinimum,  String version, @JsonKey(name: 'alt-speed-down')  int altSpeedDown, @JsonKey(name: 'alt-speed-enabled')  bool altSpeedEnabled, @JsonKey(name: 'alt-speed-time-begin')  int altSpeedTimeBegin, @JsonKey(name: 'alt-speed-time-day')  int altSpeedTimeDay, @JsonKey(name: 'alt-speed-time-enabled')  bool altSpeedTimeEnabled, @JsonKey(name: 'alt-speed-time-end')  int altSpeedTimeEnd, @JsonKey(name: 'alt-speed-up')  int altSpeedUp, @JsonKey(name: 'anti-brute-force-enabled')  bool antiBruteForceEnabled, @JsonKey(name: 'anti-brute-force-threshold')  int antiBruteForceThreshold, @JsonKey(name: 'blocklist-enabled')  bool blocklistEnabled, @JsonKey(name: 'blocklist-size')  int blocklistSize, @JsonKey(name: 'blocklist-url')  String blocklistUrl, @JsonKey(name: 'cache-size-mb')  int cacheSizeMb, @JsonKey(name: 'config-dir')  String configDir, @JsonKey(name: 'default-trackers')  String defaultTrackers, @JsonKey(name: 'dht-enabled')  bool dhtEnabled, @JsonKey(name: 'download-dir')  String downloadDir, @JsonKey(name: 'download-dir-free-space')  int downloadDirFreeSpace, @JsonKey(name: 'download-queue-enabled')  bool downloadQueueEnabled, @JsonKey(name: 'download-queue-size')  int downloadQueueSize,  String encryption, @JsonKey(name: 'idle-seeding-limit')  int idleSeedingLimit, @JsonKey(name: 'idle-seeding-limit-enabled')  bool idleSeedingLimitEnabled, @JsonKey(name: 'incomplete-dir')  String incompleteDir, @JsonKey(name: 'incomplete-dir-enabled')  bool incompleteDirEnabled, @JsonKey(name: 'lpd-enabled')  bool lpdEnabled, @JsonKey(name: 'peer-limit-global')  int peerLimitGlobal, @JsonKey(name: 'peer-limit-per-torrent')  int peerLimitPerTorrent, @JsonKey(name: 'peer-port')  int peerPort, @JsonKey(name: 'peer-port-random-on-start')  bool peerPortRandomOnStart, @JsonKey(name: 'pex-enabled')  bool pexEnabled, @JsonKey(name: 'port-forwarding-enabled')  bool portForwardingEnabled, @JsonKey(name: 'queue-stalled-enabled')  bool queueStalledEnabled, @JsonKey(name: 'queue-stalled-minutes')  int queueStalledMinutes, @JsonKey(name: 'rename-partial-files')  bool renamePartialFiles, @JsonKey(name: 'script-torrent-added-enabled')  bool scriptTorrentAddedEnabled, @JsonKey(name: 'script-torrent-added-filename')  String scriptTorrentAddedFilename, @JsonKey(name: 'script-torrent-done-enabled')  bool scriptTorrentDoneEnabled, @JsonKey(name: 'script-torrent-done-filename')  String scriptTorrentDoneFilename, @JsonKey(name: 'script-torrent-done-seeding-enabled')  bool scriptTorrentDoneSeedingEnabled, @JsonKey(name: 'script-torrent-done-seeding-filename')  String scriptTorrentDoneSeedingFilename, @JsonKey(name: 'seed-queue-enabled')  bool seedQueueEnabled, @JsonKey(name: 'seed-queue-size')  int seedQueueSize, @JsonKey(name: 'seedRatioLimit')  double seedRatioLimit, @JsonKey(name: 'seedRatioLimited')  bool seedRatioLimited, @JsonKey(name: 'session-id')  String sessionId, @JsonKey(name: 'speed-limit-down')  int speedLimitDown, @JsonKey(name: 'speed-limit-down-enabled')  bool speedLimitDownEnabled, @JsonKey(name: 'speed-limit-up')  int speedLimitUp, @JsonKey(name: 'speed-limit-up-enabled')  bool speedLimitUpEnabled, @JsonKey(name: 'start-added-torrents')  bool startAddedTorrents, @JsonKey(name: 'tcp-enabled')  bool tcpEnabled, @JsonKey(name: 'trash-original-torrent-files')  bool trashOriginalTorrentFiles, @JsonKey(name: 'utp-enabled')  bool utpEnabled)?  $default,) {final _that = this;
switch (_that) {
case _TransmissionPreferences() when $default != null:
return $default(_that.rpcVersion,_that.rpcVersionSemver,_that.rpcVersionMinimum,_that.version,_that.altSpeedDown,_that.altSpeedEnabled,_that.altSpeedTimeBegin,_that.altSpeedTimeDay,_that.altSpeedTimeEnabled,_that.altSpeedTimeEnd,_that.altSpeedUp,_that.antiBruteForceEnabled,_that.antiBruteForceThreshold,_that.blocklistEnabled,_that.blocklistSize,_that.blocklistUrl,_that.cacheSizeMb,_that.configDir,_that.defaultTrackers,_that.dhtEnabled,_that.downloadDir,_that.downloadDirFreeSpace,_that.downloadQueueEnabled,_that.downloadQueueSize,_that.encryption,_that.idleSeedingLimit,_that.idleSeedingLimitEnabled,_that.incompleteDir,_that.incompleteDirEnabled,_that.lpdEnabled,_that.peerLimitGlobal,_that.peerLimitPerTorrent,_that.peerPort,_that.peerPortRandomOnStart,_that.pexEnabled,_that.portForwardingEnabled,_that.queueStalledEnabled,_that.queueStalledMinutes,_that.renamePartialFiles,_that.scriptTorrentAddedEnabled,_that.scriptTorrentAddedFilename,_that.scriptTorrentDoneEnabled,_that.scriptTorrentDoneFilename,_that.scriptTorrentDoneSeedingEnabled,_that.scriptTorrentDoneSeedingFilename,_that.seedQueueEnabled,_that.seedQueueSize,_that.seedRatioLimit,_that.seedRatioLimited,_that.sessionId,_that.speedLimitDown,_that.speedLimitDownEnabled,_that.speedLimitUp,_that.speedLimitUpEnabled,_that.startAddedTorrents,_that.tcpEnabled,_that.trashOriginalTorrentFiles,_that.utpEnabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransmissionPreferences implements TransmissionPreferences {
  const _TransmissionPreferences({@JsonKey(name: 'rpc-version') this.rpcVersion = 0, @JsonKey(name: 'rpc-version-semver') this.rpcVersionSemver = '', @JsonKey(name: 'rpc-version-minimum') this.rpcVersionMinimum = 0, this.version = '', @JsonKey(name: 'alt-speed-down') this.altSpeedDown = 100, @JsonKey(name: 'alt-speed-enabled') this.altSpeedEnabled = false, @JsonKey(name: 'alt-speed-time-begin') this.altSpeedTimeBegin = 540, @JsonKey(name: 'alt-speed-time-day') this.altSpeedTimeDay = 127, @JsonKey(name: 'alt-speed-time-enabled') this.altSpeedTimeEnabled = false, @JsonKey(name: 'alt-speed-time-end') this.altSpeedTimeEnd = 1020, @JsonKey(name: 'alt-speed-up') this.altSpeedUp = 100, @JsonKey(name: 'anti-brute-force-enabled') this.antiBruteForceEnabled = false, @JsonKey(name: 'anti-brute-force-threshold') this.antiBruteForceThreshold = 100, @JsonKey(name: 'blocklist-enabled') this.blocklistEnabled = false, @JsonKey(name: 'blocklist-size') this.blocklistSize = 0, @JsonKey(name: 'blocklist-url') this.blocklistUrl = '', @JsonKey(name: 'cache-size-mb') this.cacheSizeMb = 4, @JsonKey(name: 'config-dir') this.configDir = '', @JsonKey(name: 'default-trackers') this.defaultTrackers = '', @JsonKey(name: 'dht-enabled') this.dhtEnabled = true, @JsonKey(name: 'download-dir') this.downloadDir = '', @JsonKey(name: 'download-dir-free-space') this.downloadDirFreeSpace = 0, @JsonKey(name: 'download-queue-enabled') this.downloadQueueEnabled = true, @JsonKey(name: 'download-queue-size') this.downloadQueueSize = 5, this.encryption = 'preferred', @JsonKey(name: 'idle-seeding-limit') this.idleSeedingLimit = 30, @JsonKey(name: 'idle-seeding-limit-enabled') this.idleSeedingLimitEnabled = false, @JsonKey(name: 'incomplete-dir') this.incompleteDir = '', @JsonKey(name: 'incomplete-dir-enabled') this.incompleteDirEnabled = false, @JsonKey(name: 'lpd-enabled') this.lpdEnabled = false, @JsonKey(name: 'peer-limit-global') this.peerLimitGlobal = 200, @JsonKey(name: 'peer-limit-per-torrent') this.peerLimitPerTorrent = 50, @JsonKey(name: 'peer-port') this.peerPort = 51413, @JsonKey(name: 'peer-port-random-on-start') this.peerPortRandomOnStart = false, @JsonKey(name: 'pex-enabled') this.pexEnabled = true, @JsonKey(name: 'port-forwarding-enabled') this.portForwardingEnabled = true, @JsonKey(name: 'queue-stalled-enabled') this.queueStalledEnabled = true, @JsonKey(name: 'queue-stalled-minutes') this.queueStalledMinutes = 30, @JsonKey(name: 'rename-partial-files') this.renamePartialFiles = true, @JsonKey(name: 'script-torrent-added-enabled') this.scriptTorrentAddedEnabled = false, @JsonKey(name: 'script-torrent-added-filename') this.scriptTorrentAddedFilename = '', @JsonKey(name: 'script-torrent-done-enabled') this.scriptTorrentDoneEnabled = false, @JsonKey(name: 'script-torrent-done-filename') this.scriptTorrentDoneFilename = '', @JsonKey(name: 'script-torrent-done-seeding-enabled') this.scriptTorrentDoneSeedingEnabled = false, @JsonKey(name: 'script-torrent-done-seeding-filename') this.scriptTorrentDoneSeedingFilename = '', @JsonKey(name: 'seed-queue-enabled') this.seedQueueEnabled = false, @JsonKey(name: 'seed-queue-size') this.seedQueueSize = 10, @JsonKey(name: 'seedRatioLimit') this.seedRatioLimit = 2.0, @JsonKey(name: 'seedRatioLimited') this.seedRatioLimited = false, @JsonKey(name: 'session-id') this.sessionId = '', @JsonKey(name: 'speed-limit-down') this.speedLimitDown = 100, @JsonKey(name: 'speed-limit-down-enabled') this.speedLimitDownEnabled = false, @JsonKey(name: 'speed-limit-up') this.speedLimitUp = 100, @JsonKey(name: 'speed-limit-up-enabled') this.speedLimitUpEnabled = false, @JsonKey(name: 'start-added-torrents') this.startAddedTorrents = true, @JsonKey(name: 'tcp-enabled') this.tcpEnabled = true, @JsonKey(name: 'trash-original-torrent-files') this.trashOriginalTorrentFiles = false, @JsonKey(name: 'utp-enabled') this.utpEnabled = false});
  factory _TransmissionPreferences.fromJson(Map<String, dynamic> json) => _$TransmissionPreferencesFromJson(json);

@override@JsonKey(name: 'rpc-version') final  int rpcVersion;
@override@JsonKey(name: 'rpc-version-semver') final  String rpcVersionSemver;
@override@JsonKey(name: 'rpc-version-minimum') final  int rpcVersionMinimum;
@override@JsonKey() final  String version;
@override@JsonKey(name: 'alt-speed-down') final  int altSpeedDown;
@override@JsonKey(name: 'alt-speed-enabled') final  bool altSpeedEnabled;
@override@JsonKey(name: 'alt-speed-time-begin') final  int altSpeedTimeBegin;
@override@JsonKey(name: 'alt-speed-time-day') final  int altSpeedTimeDay;
@override@JsonKey(name: 'alt-speed-time-enabled') final  bool altSpeedTimeEnabled;
@override@JsonKey(name: 'alt-speed-time-end') final  int altSpeedTimeEnd;
@override@JsonKey(name: 'alt-speed-up') final  int altSpeedUp;
@override@JsonKey(name: 'anti-brute-force-enabled') final  bool antiBruteForceEnabled;
@override@JsonKey(name: 'anti-brute-force-threshold') final  int antiBruteForceThreshold;
@override@JsonKey(name: 'blocklist-enabled') final  bool blocklistEnabled;
@override@JsonKey(name: 'blocklist-size') final  int blocklistSize;
@override@JsonKey(name: 'blocklist-url') final  String blocklistUrl;
@override@JsonKey(name: 'cache-size-mb') final  int cacheSizeMb;
@override@JsonKey(name: 'config-dir') final  String configDir;
@override@JsonKey(name: 'default-trackers') final  String defaultTrackers;
@override@JsonKey(name: 'dht-enabled') final  bool dhtEnabled;
@override@JsonKey(name: 'download-dir') final  String downloadDir;
@override@JsonKey(name: 'download-dir-free-space') final  int downloadDirFreeSpace;
@override@JsonKey(name: 'download-queue-enabled') final  bool downloadQueueEnabled;
@override@JsonKey(name: 'download-queue-size') final  int downloadQueueSize;
@override@JsonKey() final  String encryption;
@override@JsonKey(name: 'idle-seeding-limit') final  int idleSeedingLimit;
@override@JsonKey(name: 'idle-seeding-limit-enabled') final  bool idleSeedingLimitEnabled;
@override@JsonKey(name: 'incomplete-dir') final  String incompleteDir;
@override@JsonKey(name: 'incomplete-dir-enabled') final  bool incompleteDirEnabled;
@override@JsonKey(name: 'lpd-enabled') final  bool lpdEnabled;
@override@JsonKey(name: 'peer-limit-global') final  int peerLimitGlobal;
@override@JsonKey(name: 'peer-limit-per-torrent') final  int peerLimitPerTorrent;
@override@JsonKey(name: 'peer-port') final  int peerPort;
@override@JsonKey(name: 'peer-port-random-on-start') final  bool peerPortRandomOnStart;
@override@JsonKey(name: 'pex-enabled') final  bool pexEnabled;
@override@JsonKey(name: 'port-forwarding-enabled') final  bool portForwardingEnabled;
@override@JsonKey(name: 'queue-stalled-enabled') final  bool queueStalledEnabled;
@override@JsonKey(name: 'queue-stalled-minutes') final  int queueStalledMinutes;
@override@JsonKey(name: 'rename-partial-files') final  bool renamePartialFiles;
@override@JsonKey(name: 'script-torrent-added-enabled') final  bool scriptTorrentAddedEnabled;
@override@JsonKey(name: 'script-torrent-added-filename') final  String scriptTorrentAddedFilename;
@override@JsonKey(name: 'script-torrent-done-enabled') final  bool scriptTorrentDoneEnabled;
@override@JsonKey(name: 'script-torrent-done-filename') final  String scriptTorrentDoneFilename;
@override@JsonKey(name: 'script-torrent-done-seeding-enabled') final  bool scriptTorrentDoneSeedingEnabled;
@override@JsonKey(name: 'script-torrent-done-seeding-filename') final  String scriptTorrentDoneSeedingFilename;
@override@JsonKey(name: 'seed-queue-enabled') final  bool seedQueueEnabled;
@override@JsonKey(name: 'seed-queue-size') final  int seedQueueSize;
@override@JsonKey(name: 'seedRatioLimit') final  double seedRatioLimit;
@override@JsonKey(name: 'seedRatioLimited') final  bool seedRatioLimited;
@override@JsonKey(name: 'session-id') final  String sessionId;
@override@JsonKey(name: 'speed-limit-down') final  int speedLimitDown;
@override@JsonKey(name: 'speed-limit-down-enabled') final  bool speedLimitDownEnabled;
@override@JsonKey(name: 'speed-limit-up') final  int speedLimitUp;
@override@JsonKey(name: 'speed-limit-up-enabled') final  bool speedLimitUpEnabled;
@override@JsonKey(name: 'start-added-torrents') final  bool startAddedTorrents;
@override@JsonKey(name: 'tcp-enabled') final  bool tcpEnabled;
@override@JsonKey(name: 'trash-original-torrent-files') final  bool trashOriginalTorrentFiles;
@override@JsonKey(name: 'utp-enabled') final  bool utpEnabled;

/// Create a copy of TransmissionPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransmissionPreferencesCopyWith<_TransmissionPreferences> get copyWith => __$TransmissionPreferencesCopyWithImpl<_TransmissionPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransmissionPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransmissionPreferences&&(identical(other.rpcVersion, rpcVersion) || other.rpcVersion == rpcVersion)&&(identical(other.rpcVersionSemver, rpcVersionSemver) || other.rpcVersionSemver == rpcVersionSemver)&&(identical(other.rpcVersionMinimum, rpcVersionMinimum) || other.rpcVersionMinimum == rpcVersionMinimum)&&(identical(other.version, version) || other.version == version)&&(identical(other.altSpeedDown, altSpeedDown) || other.altSpeedDown == altSpeedDown)&&(identical(other.altSpeedEnabled, altSpeedEnabled) || other.altSpeedEnabled == altSpeedEnabled)&&(identical(other.altSpeedTimeBegin, altSpeedTimeBegin) || other.altSpeedTimeBegin == altSpeedTimeBegin)&&(identical(other.altSpeedTimeDay, altSpeedTimeDay) || other.altSpeedTimeDay == altSpeedTimeDay)&&(identical(other.altSpeedTimeEnabled, altSpeedTimeEnabled) || other.altSpeedTimeEnabled == altSpeedTimeEnabled)&&(identical(other.altSpeedTimeEnd, altSpeedTimeEnd) || other.altSpeedTimeEnd == altSpeedTimeEnd)&&(identical(other.altSpeedUp, altSpeedUp) || other.altSpeedUp == altSpeedUp)&&(identical(other.antiBruteForceEnabled, antiBruteForceEnabled) || other.antiBruteForceEnabled == antiBruteForceEnabled)&&(identical(other.antiBruteForceThreshold, antiBruteForceThreshold) || other.antiBruteForceThreshold == antiBruteForceThreshold)&&(identical(other.blocklistEnabled, blocklistEnabled) || other.blocklistEnabled == blocklistEnabled)&&(identical(other.blocklistSize, blocklistSize) || other.blocklistSize == blocklistSize)&&(identical(other.blocklistUrl, blocklistUrl) || other.blocklistUrl == blocklistUrl)&&(identical(other.cacheSizeMb, cacheSizeMb) || other.cacheSizeMb == cacheSizeMb)&&(identical(other.configDir, configDir) || other.configDir == configDir)&&(identical(other.defaultTrackers, defaultTrackers) || other.defaultTrackers == defaultTrackers)&&(identical(other.dhtEnabled, dhtEnabled) || other.dhtEnabled == dhtEnabled)&&(identical(other.downloadDir, downloadDir) || other.downloadDir == downloadDir)&&(identical(other.downloadDirFreeSpace, downloadDirFreeSpace) || other.downloadDirFreeSpace == downloadDirFreeSpace)&&(identical(other.downloadQueueEnabled, downloadQueueEnabled) || other.downloadQueueEnabled == downloadQueueEnabled)&&(identical(other.downloadQueueSize, downloadQueueSize) || other.downloadQueueSize == downloadQueueSize)&&(identical(other.encryption, encryption) || other.encryption == encryption)&&(identical(other.idleSeedingLimit, idleSeedingLimit) || other.idleSeedingLimit == idleSeedingLimit)&&(identical(other.idleSeedingLimitEnabled, idleSeedingLimitEnabled) || other.idleSeedingLimitEnabled == idleSeedingLimitEnabled)&&(identical(other.incompleteDir, incompleteDir) || other.incompleteDir == incompleteDir)&&(identical(other.incompleteDirEnabled, incompleteDirEnabled) || other.incompleteDirEnabled == incompleteDirEnabled)&&(identical(other.lpdEnabled, lpdEnabled) || other.lpdEnabled == lpdEnabled)&&(identical(other.peerLimitGlobal, peerLimitGlobal) || other.peerLimitGlobal == peerLimitGlobal)&&(identical(other.peerLimitPerTorrent, peerLimitPerTorrent) || other.peerLimitPerTorrent == peerLimitPerTorrent)&&(identical(other.peerPort, peerPort) || other.peerPort == peerPort)&&(identical(other.peerPortRandomOnStart, peerPortRandomOnStart) || other.peerPortRandomOnStart == peerPortRandomOnStart)&&(identical(other.pexEnabled, pexEnabled) || other.pexEnabled == pexEnabled)&&(identical(other.portForwardingEnabled, portForwardingEnabled) || other.portForwardingEnabled == portForwardingEnabled)&&(identical(other.queueStalledEnabled, queueStalledEnabled) || other.queueStalledEnabled == queueStalledEnabled)&&(identical(other.queueStalledMinutes, queueStalledMinutes) || other.queueStalledMinutes == queueStalledMinutes)&&(identical(other.renamePartialFiles, renamePartialFiles) || other.renamePartialFiles == renamePartialFiles)&&(identical(other.scriptTorrentAddedEnabled, scriptTorrentAddedEnabled) || other.scriptTorrentAddedEnabled == scriptTorrentAddedEnabled)&&(identical(other.scriptTorrentAddedFilename, scriptTorrentAddedFilename) || other.scriptTorrentAddedFilename == scriptTorrentAddedFilename)&&(identical(other.scriptTorrentDoneEnabled, scriptTorrentDoneEnabled) || other.scriptTorrentDoneEnabled == scriptTorrentDoneEnabled)&&(identical(other.scriptTorrentDoneFilename, scriptTorrentDoneFilename) || other.scriptTorrentDoneFilename == scriptTorrentDoneFilename)&&(identical(other.scriptTorrentDoneSeedingEnabled, scriptTorrentDoneSeedingEnabled) || other.scriptTorrentDoneSeedingEnabled == scriptTorrentDoneSeedingEnabled)&&(identical(other.scriptTorrentDoneSeedingFilename, scriptTorrentDoneSeedingFilename) || other.scriptTorrentDoneSeedingFilename == scriptTorrentDoneSeedingFilename)&&(identical(other.seedQueueEnabled, seedQueueEnabled) || other.seedQueueEnabled == seedQueueEnabled)&&(identical(other.seedQueueSize, seedQueueSize) || other.seedQueueSize == seedQueueSize)&&(identical(other.seedRatioLimit, seedRatioLimit) || other.seedRatioLimit == seedRatioLimit)&&(identical(other.seedRatioLimited, seedRatioLimited) || other.seedRatioLimited == seedRatioLimited)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.speedLimitDown, speedLimitDown) || other.speedLimitDown == speedLimitDown)&&(identical(other.speedLimitDownEnabled, speedLimitDownEnabled) || other.speedLimitDownEnabled == speedLimitDownEnabled)&&(identical(other.speedLimitUp, speedLimitUp) || other.speedLimitUp == speedLimitUp)&&(identical(other.speedLimitUpEnabled, speedLimitUpEnabled) || other.speedLimitUpEnabled == speedLimitUpEnabled)&&(identical(other.startAddedTorrents, startAddedTorrents) || other.startAddedTorrents == startAddedTorrents)&&(identical(other.tcpEnabled, tcpEnabled) || other.tcpEnabled == tcpEnabled)&&(identical(other.trashOriginalTorrentFiles, trashOriginalTorrentFiles) || other.trashOriginalTorrentFiles == trashOriginalTorrentFiles)&&(identical(other.utpEnabled, utpEnabled) || other.utpEnabled == utpEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,rpcVersion,rpcVersionSemver,rpcVersionMinimum,version,altSpeedDown,altSpeedEnabled,altSpeedTimeBegin,altSpeedTimeDay,altSpeedTimeEnabled,altSpeedTimeEnd,altSpeedUp,antiBruteForceEnabled,antiBruteForceThreshold,blocklistEnabled,blocklistSize,blocklistUrl,cacheSizeMb,configDir,defaultTrackers,dhtEnabled,downloadDir,downloadDirFreeSpace,downloadQueueEnabled,downloadQueueSize,encryption,idleSeedingLimit,idleSeedingLimitEnabled,incompleteDir,incompleteDirEnabled,lpdEnabled,peerLimitGlobal,peerLimitPerTorrent,peerPort,peerPortRandomOnStart,pexEnabled,portForwardingEnabled,queueStalledEnabled,queueStalledMinutes,renamePartialFiles,scriptTorrentAddedEnabled,scriptTorrentAddedFilename,scriptTorrentDoneEnabled,scriptTorrentDoneFilename,scriptTorrentDoneSeedingEnabled,scriptTorrentDoneSeedingFilename,seedQueueEnabled,seedQueueSize,seedRatioLimit,seedRatioLimited,sessionId,speedLimitDown,speedLimitDownEnabled,speedLimitUp,speedLimitUpEnabled,startAddedTorrents,tcpEnabled,trashOriginalTorrentFiles,utpEnabled]);

@override
String toString() {
  return 'TransmissionPreferences(rpcVersion: $rpcVersion, rpcVersionSemver: $rpcVersionSemver, rpcVersionMinimum: $rpcVersionMinimum, version: $version, altSpeedDown: $altSpeedDown, altSpeedEnabled: $altSpeedEnabled, altSpeedTimeBegin: $altSpeedTimeBegin, altSpeedTimeDay: $altSpeedTimeDay, altSpeedTimeEnabled: $altSpeedTimeEnabled, altSpeedTimeEnd: $altSpeedTimeEnd, altSpeedUp: $altSpeedUp, antiBruteForceEnabled: $antiBruteForceEnabled, antiBruteForceThreshold: $antiBruteForceThreshold, blocklistEnabled: $blocklistEnabled, blocklistSize: $blocklistSize, blocklistUrl: $blocklistUrl, cacheSizeMb: $cacheSizeMb, configDir: $configDir, defaultTrackers: $defaultTrackers, dhtEnabled: $dhtEnabled, downloadDir: $downloadDir, downloadDirFreeSpace: $downloadDirFreeSpace, downloadQueueEnabled: $downloadQueueEnabled, downloadQueueSize: $downloadQueueSize, encryption: $encryption, idleSeedingLimit: $idleSeedingLimit, idleSeedingLimitEnabled: $idleSeedingLimitEnabled, incompleteDir: $incompleteDir, incompleteDirEnabled: $incompleteDirEnabled, lpdEnabled: $lpdEnabled, peerLimitGlobal: $peerLimitGlobal, peerLimitPerTorrent: $peerLimitPerTorrent, peerPort: $peerPort, peerPortRandomOnStart: $peerPortRandomOnStart, pexEnabled: $pexEnabled, portForwardingEnabled: $portForwardingEnabled, queueStalledEnabled: $queueStalledEnabled, queueStalledMinutes: $queueStalledMinutes, renamePartialFiles: $renamePartialFiles, scriptTorrentAddedEnabled: $scriptTorrentAddedEnabled, scriptTorrentAddedFilename: $scriptTorrentAddedFilename, scriptTorrentDoneEnabled: $scriptTorrentDoneEnabled, scriptTorrentDoneFilename: $scriptTorrentDoneFilename, scriptTorrentDoneSeedingEnabled: $scriptTorrentDoneSeedingEnabled, scriptTorrentDoneSeedingFilename: $scriptTorrentDoneSeedingFilename, seedQueueEnabled: $seedQueueEnabled, seedQueueSize: $seedQueueSize, seedRatioLimit: $seedRatioLimit, seedRatioLimited: $seedRatioLimited, sessionId: $sessionId, speedLimitDown: $speedLimitDown, speedLimitDownEnabled: $speedLimitDownEnabled, speedLimitUp: $speedLimitUp, speedLimitUpEnabled: $speedLimitUpEnabled, startAddedTorrents: $startAddedTorrents, tcpEnabled: $tcpEnabled, trashOriginalTorrentFiles: $trashOriginalTorrentFiles, utpEnabled: $utpEnabled)';
}


}

/// @nodoc
abstract mixin class _$TransmissionPreferencesCopyWith<$Res> implements $TransmissionPreferencesCopyWith<$Res> {
  factory _$TransmissionPreferencesCopyWith(_TransmissionPreferences value, $Res Function(_TransmissionPreferences) _then) = __$TransmissionPreferencesCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'rpc-version') int rpcVersion,@JsonKey(name: 'rpc-version-semver') String rpcVersionSemver,@JsonKey(name: 'rpc-version-minimum') int rpcVersionMinimum, String version,@JsonKey(name: 'alt-speed-down') int altSpeedDown,@JsonKey(name: 'alt-speed-enabled') bool altSpeedEnabled,@JsonKey(name: 'alt-speed-time-begin') int altSpeedTimeBegin,@JsonKey(name: 'alt-speed-time-day') int altSpeedTimeDay,@JsonKey(name: 'alt-speed-time-enabled') bool altSpeedTimeEnabled,@JsonKey(name: 'alt-speed-time-end') int altSpeedTimeEnd,@JsonKey(name: 'alt-speed-up') int altSpeedUp,@JsonKey(name: 'anti-brute-force-enabled') bool antiBruteForceEnabled,@JsonKey(name: 'anti-brute-force-threshold') int antiBruteForceThreshold,@JsonKey(name: 'blocklist-enabled') bool blocklistEnabled,@JsonKey(name: 'blocklist-size') int blocklistSize,@JsonKey(name: 'blocklist-url') String blocklistUrl,@JsonKey(name: 'cache-size-mb') int cacheSizeMb,@JsonKey(name: 'config-dir') String configDir,@JsonKey(name: 'default-trackers') String defaultTrackers,@JsonKey(name: 'dht-enabled') bool dhtEnabled,@JsonKey(name: 'download-dir') String downloadDir,@JsonKey(name: 'download-dir-free-space') int downloadDirFreeSpace,@JsonKey(name: 'download-queue-enabled') bool downloadQueueEnabled,@JsonKey(name: 'download-queue-size') int downloadQueueSize, String encryption,@JsonKey(name: 'idle-seeding-limit') int idleSeedingLimit,@JsonKey(name: 'idle-seeding-limit-enabled') bool idleSeedingLimitEnabled,@JsonKey(name: 'incomplete-dir') String incompleteDir,@JsonKey(name: 'incomplete-dir-enabled') bool incompleteDirEnabled,@JsonKey(name: 'lpd-enabled') bool lpdEnabled,@JsonKey(name: 'peer-limit-global') int peerLimitGlobal,@JsonKey(name: 'peer-limit-per-torrent') int peerLimitPerTorrent,@JsonKey(name: 'peer-port') int peerPort,@JsonKey(name: 'peer-port-random-on-start') bool peerPortRandomOnStart,@JsonKey(name: 'pex-enabled') bool pexEnabled,@JsonKey(name: 'port-forwarding-enabled') bool portForwardingEnabled,@JsonKey(name: 'queue-stalled-enabled') bool queueStalledEnabled,@JsonKey(name: 'queue-stalled-minutes') int queueStalledMinutes,@JsonKey(name: 'rename-partial-files') bool renamePartialFiles,@JsonKey(name: 'script-torrent-added-enabled') bool scriptTorrentAddedEnabled,@JsonKey(name: 'script-torrent-added-filename') String scriptTorrentAddedFilename,@JsonKey(name: 'script-torrent-done-enabled') bool scriptTorrentDoneEnabled,@JsonKey(name: 'script-torrent-done-filename') String scriptTorrentDoneFilename,@JsonKey(name: 'script-torrent-done-seeding-enabled') bool scriptTorrentDoneSeedingEnabled,@JsonKey(name: 'script-torrent-done-seeding-filename') String scriptTorrentDoneSeedingFilename,@JsonKey(name: 'seed-queue-enabled') bool seedQueueEnabled,@JsonKey(name: 'seed-queue-size') int seedQueueSize,@JsonKey(name: 'seedRatioLimit') double seedRatioLimit,@JsonKey(name: 'seedRatioLimited') bool seedRatioLimited,@JsonKey(name: 'session-id') String sessionId,@JsonKey(name: 'speed-limit-down') int speedLimitDown,@JsonKey(name: 'speed-limit-down-enabled') bool speedLimitDownEnabled,@JsonKey(name: 'speed-limit-up') int speedLimitUp,@JsonKey(name: 'speed-limit-up-enabled') bool speedLimitUpEnabled,@JsonKey(name: 'start-added-torrents') bool startAddedTorrents,@JsonKey(name: 'tcp-enabled') bool tcpEnabled,@JsonKey(name: 'trash-original-torrent-files') bool trashOriginalTorrentFiles,@JsonKey(name: 'utp-enabled') bool utpEnabled
});




}
/// @nodoc
class __$TransmissionPreferencesCopyWithImpl<$Res>
    implements _$TransmissionPreferencesCopyWith<$Res> {
  __$TransmissionPreferencesCopyWithImpl(this._self, this._then);

  final _TransmissionPreferences _self;
  final $Res Function(_TransmissionPreferences) _then;

/// Create a copy of TransmissionPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rpcVersion = null,Object? rpcVersionSemver = null,Object? rpcVersionMinimum = null,Object? version = null,Object? altSpeedDown = null,Object? altSpeedEnabled = null,Object? altSpeedTimeBegin = null,Object? altSpeedTimeDay = null,Object? altSpeedTimeEnabled = null,Object? altSpeedTimeEnd = null,Object? altSpeedUp = null,Object? antiBruteForceEnabled = null,Object? antiBruteForceThreshold = null,Object? blocklistEnabled = null,Object? blocklistSize = null,Object? blocklistUrl = null,Object? cacheSizeMb = null,Object? configDir = null,Object? defaultTrackers = null,Object? dhtEnabled = null,Object? downloadDir = null,Object? downloadDirFreeSpace = null,Object? downloadQueueEnabled = null,Object? downloadQueueSize = null,Object? encryption = null,Object? idleSeedingLimit = null,Object? idleSeedingLimitEnabled = null,Object? incompleteDir = null,Object? incompleteDirEnabled = null,Object? lpdEnabled = null,Object? peerLimitGlobal = null,Object? peerLimitPerTorrent = null,Object? peerPort = null,Object? peerPortRandomOnStart = null,Object? pexEnabled = null,Object? portForwardingEnabled = null,Object? queueStalledEnabled = null,Object? queueStalledMinutes = null,Object? renamePartialFiles = null,Object? scriptTorrentAddedEnabled = null,Object? scriptTorrentAddedFilename = null,Object? scriptTorrentDoneEnabled = null,Object? scriptTorrentDoneFilename = null,Object? scriptTorrentDoneSeedingEnabled = null,Object? scriptTorrentDoneSeedingFilename = null,Object? seedQueueEnabled = null,Object? seedQueueSize = null,Object? seedRatioLimit = null,Object? seedRatioLimited = null,Object? sessionId = null,Object? speedLimitDown = null,Object? speedLimitDownEnabled = null,Object? speedLimitUp = null,Object? speedLimitUpEnabled = null,Object? startAddedTorrents = null,Object? tcpEnabled = null,Object? trashOriginalTorrentFiles = null,Object? utpEnabled = null,}) {
  return _then(_TransmissionPreferences(
rpcVersion: null == rpcVersion ? _self.rpcVersion : rpcVersion // ignore: cast_nullable_to_non_nullable
as int,rpcVersionSemver: null == rpcVersionSemver ? _self.rpcVersionSemver : rpcVersionSemver // ignore: cast_nullable_to_non_nullable
as String,rpcVersionMinimum: null == rpcVersionMinimum ? _self.rpcVersionMinimum : rpcVersionMinimum // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,altSpeedDown: null == altSpeedDown ? _self.altSpeedDown : altSpeedDown // ignore: cast_nullable_to_non_nullable
as int,altSpeedEnabled: null == altSpeedEnabled ? _self.altSpeedEnabled : altSpeedEnabled // ignore: cast_nullable_to_non_nullable
as bool,altSpeedTimeBegin: null == altSpeedTimeBegin ? _self.altSpeedTimeBegin : altSpeedTimeBegin // ignore: cast_nullable_to_non_nullable
as int,altSpeedTimeDay: null == altSpeedTimeDay ? _self.altSpeedTimeDay : altSpeedTimeDay // ignore: cast_nullable_to_non_nullable
as int,altSpeedTimeEnabled: null == altSpeedTimeEnabled ? _self.altSpeedTimeEnabled : altSpeedTimeEnabled // ignore: cast_nullable_to_non_nullable
as bool,altSpeedTimeEnd: null == altSpeedTimeEnd ? _self.altSpeedTimeEnd : altSpeedTimeEnd // ignore: cast_nullable_to_non_nullable
as int,altSpeedUp: null == altSpeedUp ? _self.altSpeedUp : altSpeedUp // ignore: cast_nullable_to_non_nullable
as int,antiBruteForceEnabled: null == antiBruteForceEnabled ? _self.antiBruteForceEnabled : antiBruteForceEnabled // ignore: cast_nullable_to_non_nullable
as bool,antiBruteForceThreshold: null == antiBruteForceThreshold ? _self.antiBruteForceThreshold : antiBruteForceThreshold // ignore: cast_nullable_to_non_nullable
as int,blocklistEnabled: null == blocklistEnabled ? _self.blocklistEnabled : blocklistEnabled // ignore: cast_nullable_to_non_nullable
as bool,blocklistSize: null == blocklistSize ? _self.blocklistSize : blocklistSize // ignore: cast_nullable_to_non_nullable
as int,blocklistUrl: null == blocklistUrl ? _self.blocklistUrl : blocklistUrl // ignore: cast_nullable_to_non_nullable
as String,cacheSizeMb: null == cacheSizeMb ? _self.cacheSizeMb : cacheSizeMb // ignore: cast_nullable_to_non_nullable
as int,configDir: null == configDir ? _self.configDir : configDir // ignore: cast_nullable_to_non_nullable
as String,defaultTrackers: null == defaultTrackers ? _self.defaultTrackers : defaultTrackers // ignore: cast_nullable_to_non_nullable
as String,dhtEnabled: null == dhtEnabled ? _self.dhtEnabled : dhtEnabled // ignore: cast_nullable_to_non_nullable
as bool,downloadDir: null == downloadDir ? _self.downloadDir : downloadDir // ignore: cast_nullable_to_non_nullable
as String,downloadDirFreeSpace: null == downloadDirFreeSpace ? _self.downloadDirFreeSpace : downloadDirFreeSpace // ignore: cast_nullable_to_non_nullable
as int,downloadQueueEnabled: null == downloadQueueEnabled ? _self.downloadQueueEnabled : downloadQueueEnabled // ignore: cast_nullable_to_non_nullable
as bool,downloadQueueSize: null == downloadQueueSize ? _self.downloadQueueSize : downloadQueueSize // ignore: cast_nullable_to_non_nullable
as int,encryption: null == encryption ? _self.encryption : encryption // ignore: cast_nullable_to_non_nullable
as String,idleSeedingLimit: null == idleSeedingLimit ? _self.idleSeedingLimit : idleSeedingLimit // ignore: cast_nullable_to_non_nullable
as int,idleSeedingLimitEnabled: null == idleSeedingLimitEnabled ? _self.idleSeedingLimitEnabled : idleSeedingLimitEnabled // ignore: cast_nullable_to_non_nullable
as bool,incompleteDir: null == incompleteDir ? _self.incompleteDir : incompleteDir // ignore: cast_nullable_to_non_nullable
as String,incompleteDirEnabled: null == incompleteDirEnabled ? _self.incompleteDirEnabled : incompleteDirEnabled // ignore: cast_nullable_to_non_nullable
as bool,lpdEnabled: null == lpdEnabled ? _self.lpdEnabled : lpdEnabled // ignore: cast_nullable_to_non_nullable
as bool,peerLimitGlobal: null == peerLimitGlobal ? _self.peerLimitGlobal : peerLimitGlobal // ignore: cast_nullable_to_non_nullable
as int,peerLimitPerTorrent: null == peerLimitPerTorrent ? _self.peerLimitPerTorrent : peerLimitPerTorrent // ignore: cast_nullable_to_non_nullable
as int,peerPort: null == peerPort ? _self.peerPort : peerPort // ignore: cast_nullable_to_non_nullable
as int,peerPortRandomOnStart: null == peerPortRandomOnStart ? _self.peerPortRandomOnStart : peerPortRandomOnStart // ignore: cast_nullable_to_non_nullable
as bool,pexEnabled: null == pexEnabled ? _self.pexEnabled : pexEnabled // ignore: cast_nullable_to_non_nullable
as bool,portForwardingEnabled: null == portForwardingEnabled ? _self.portForwardingEnabled : portForwardingEnabled // ignore: cast_nullable_to_non_nullable
as bool,queueStalledEnabled: null == queueStalledEnabled ? _self.queueStalledEnabled : queueStalledEnabled // ignore: cast_nullable_to_non_nullable
as bool,queueStalledMinutes: null == queueStalledMinutes ? _self.queueStalledMinutes : queueStalledMinutes // ignore: cast_nullable_to_non_nullable
as int,renamePartialFiles: null == renamePartialFiles ? _self.renamePartialFiles : renamePartialFiles // ignore: cast_nullable_to_non_nullable
as bool,scriptTorrentAddedEnabled: null == scriptTorrentAddedEnabled ? _self.scriptTorrentAddedEnabled : scriptTorrentAddedEnabled // ignore: cast_nullable_to_non_nullable
as bool,scriptTorrentAddedFilename: null == scriptTorrentAddedFilename ? _self.scriptTorrentAddedFilename : scriptTorrentAddedFilename // ignore: cast_nullable_to_non_nullable
as String,scriptTorrentDoneEnabled: null == scriptTorrentDoneEnabled ? _self.scriptTorrentDoneEnabled : scriptTorrentDoneEnabled // ignore: cast_nullable_to_non_nullable
as bool,scriptTorrentDoneFilename: null == scriptTorrentDoneFilename ? _self.scriptTorrentDoneFilename : scriptTorrentDoneFilename // ignore: cast_nullable_to_non_nullable
as String,scriptTorrentDoneSeedingEnabled: null == scriptTorrentDoneSeedingEnabled ? _self.scriptTorrentDoneSeedingEnabled : scriptTorrentDoneSeedingEnabled // ignore: cast_nullable_to_non_nullable
as bool,scriptTorrentDoneSeedingFilename: null == scriptTorrentDoneSeedingFilename ? _self.scriptTorrentDoneSeedingFilename : scriptTorrentDoneSeedingFilename // ignore: cast_nullable_to_non_nullable
as String,seedQueueEnabled: null == seedQueueEnabled ? _self.seedQueueEnabled : seedQueueEnabled // ignore: cast_nullable_to_non_nullable
as bool,seedQueueSize: null == seedQueueSize ? _self.seedQueueSize : seedQueueSize // ignore: cast_nullable_to_non_nullable
as int,seedRatioLimit: null == seedRatioLimit ? _self.seedRatioLimit : seedRatioLimit // ignore: cast_nullable_to_non_nullable
as double,seedRatioLimited: null == seedRatioLimited ? _self.seedRatioLimited : seedRatioLimited // ignore: cast_nullable_to_non_nullable
as bool,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,speedLimitDown: null == speedLimitDown ? _self.speedLimitDown : speedLimitDown // ignore: cast_nullable_to_non_nullable
as int,speedLimitDownEnabled: null == speedLimitDownEnabled ? _self.speedLimitDownEnabled : speedLimitDownEnabled // ignore: cast_nullable_to_non_nullable
as bool,speedLimitUp: null == speedLimitUp ? _self.speedLimitUp : speedLimitUp // ignore: cast_nullable_to_non_nullable
as int,speedLimitUpEnabled: null == speedLimitUpEnabled ? _self.speedLimitUpEnabled : speedLimitUpEnabled // ignore: cast_nullable_to_non_nullable
as bool,startAddedTorrents: null == startAddedTorrents ? _self.startAddedTorrents : startAddedTorrents // ignore: cast_nullable_to_non_nullable
as bool,tcpEnabled: null == tcpEnabled ? _self.tcpEnabled : tcpEnabled // ignore: cast_nullable_to_non_nullable
as bool,trashOriginalTorrentFiles: null == trashOriginalTorrentFiles ? _self.trashOriginalTorrentFiles : trashOriginalTorrentFiles // ignore: cast_nullable_to_non_nullable
as bool,utpEnabled: null == utpEnabled ? _self.utpEnabled : utpEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
