import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/hive_manager.dart';
import '../../../core/storage/storage_keys.dart';

part 'privacy_provider.g.dart';

@Riverpod(keepAlive: true)
class PrivacyMode extends _$PrivacyMode {
  @override
  bool build() {
    return HiveManager.get<bool>(StorageKeys.privacyMode) ?? false;
  }

  void toggle() {
    state = !state;
    HiveManager.set(StorageKeys.privacyMode, state);
  }
}
