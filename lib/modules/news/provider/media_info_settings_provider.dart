import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';

class MediaInfoSettings {
  final bool tmdbEnabled;
  final bool doubanEnabled;

  const MediaInfoSettings({
    this.tmdbEnabled = false,
    this.doubanEnabled = false,
  });

  bool get enabled => tmdbEnabled || doubanEnabled;

  MediaInfoSettings copyWith({bool? tmdbEnabled, bool? doubanEnabled}) {
    return MediaInfoSettings(
      tmdbEnabled: tmdbEnabled ?? this.tmdbEnabled,
      doubanEnabled: doubanEnabled ?? this.doubanEnabled,
    );
  }

  static MediaInfoSettings load() {
    final raw = HiveManager.get<Map>(StorageKeys.mediaInfoSettings);
    if (raw == null) return const MediaInfoSettings();

    return MediaInfoSettings(
      tmdbEnabled: raw['tmdb_enabled'] as bool? ?? false,
      doubanEnabled: raw['douban_enabled'] as bool? ?? false,
    );
  }

  Future<void> save() {
    return HiveManager.set(StorageKeys.mediaInfoSettings, {
      'tmdb_enabled': tmdbEnabled,
      'douban_enabled': doubanEnabled,
    });
  }
}

final mediaInfoSettingsProvider =
    StateNotifierProvider<MediaInfoSettingsNotifier, MediaInfoSettings>(
      (ref) => MediaInfoSettingsNotifier(),
    );

class MediaInfoSettingsNotifier extends StateNotifier<MediaInfoSettings> {
  MediaInfoSettingsNotifier() : super(MediaInfoSettings.load());

  Future<void> setTmdbEnabled(bool value) async {
    state = state.copyWith(tmdbEnabled: value);
    await state.save();
  }

  Future<void> setDoubanEnabled(bool value) async {
    state = state.copyWith(doubanEnabled: value);
    await state.save();
  }
}
