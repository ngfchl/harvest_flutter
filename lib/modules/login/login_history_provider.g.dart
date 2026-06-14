// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LoginHistory)
final loginHistoryProvider = LoginHistoryProvider._();

final class LoginHistoryProvider
    extends $NotifierProvider<LoginHistory, List<LoginRecord>> {
  LoginHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginHistoryHash();

  @$internal
  @override
  LoginHistory create() => LoginHistory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<LoginRecord> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<LoginRecord>>(value),
    );
  }
}

String _$loginHistoryHash() => r'91b658f9d286e330dc6218215ff1562ed8963bd5';

abstract class _$LoginHistory extends $Notifier<List<LoginRecord>> {
  List<LoginRecord> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<LoginRecord>, List<LoginRecord>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<LoginRecord>, List<LoginRecord>>,
              List<LoginRecord>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
