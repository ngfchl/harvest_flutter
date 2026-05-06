import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../model/option_model.dart';
import '../service/option_service.dart';

part 'option_provider.freezed.dart';

@freezed
abstract class OptionState with _$OptionState {
  const OptionState._();

  const factory OptionState({
    @Default([]) List<Option> options,
    @Default(false) bool isLoading,
    String? error,
  }) = _OptionState;

  Option? getOption(String name) =>
      options.where((o) => o.name == name).firstOrNull;
}

final optionServiceProvider = Provider((_) => OptionService());

final optionProvider =
    StateNotifierProvider.autoDispose<OptionNotifier, OptionState>(
      (ref) => OptionNotifier(ref),
    );

class OptionNotifier extends StateNotifier<OptionState> {
  final Ref ref;

  OptionNotifier(this.ref) : super(const OptionState()) {
    fetchOptions();
  }

  Future<void> fetchOptions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final options = await ref.read(optionServiceProvider).fetchOptions();
      state = state.copyWith(options: options, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> saveOption(Option option) async {
    try {
      await ref.read(optionServiceProvider).saveOption(option);
      // 沉默刷新，不触发 loading
      final options = await ref.read(optionServiceProvider).fetchOptions();
      state = state.copyWith(options: options);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> testNotice(Map<String, String> body) async {
    try {
      await ref.read(optionServiceProvider).testNotice(body);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setTelegramWebhook(String host) async {
    try {
      await ref.read(optionServiceProvider).setTelegramWebhook(host);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> importCookieBackup({
    required PlatformFile file,
    required CookieBackupSource source,
  }) async {
    try {
      return await ref
          .read(optionServiceProvider)
          .importCookieBackup(file: file, source: source);
    } catch (e) {
      return null;
    }
  }

  Future<bool> syncCookieCloud() async {
    try {
      await ref.read(optionServiceProvider).syncCookieCloud();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> speedTest() async {
    try {
      await ref.read(optionServiceProvider).speedTest();
      return true;
    } catch (e) {
      return false;
    }
  }
}
