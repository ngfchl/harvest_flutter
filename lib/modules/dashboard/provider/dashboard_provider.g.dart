// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DashboardNotifier)
final dashboardProvider = DashboardNotifierProvider._();

final class DashboardNotifierProvider
    extends $NotifierProvider<DashboardNotifier, DashboardData?> {
  DashboardNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardNotifierHash();

  @$internal
  @override
  DashboardNotifier create() => DashboardNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardData? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardData?>(value),
    );
  }
}

String _$dashboardNotifierHash() => r'd20d4c4de67ff6226b9d416e9852509f81aadb3c';

abstract class _$DashboardNotifier extends $Notifier<DashboardData?> {
  DashboardData? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DashboardData?, DashboardData?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DashboardData?, DashboardData?>,
              DashboardData?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
