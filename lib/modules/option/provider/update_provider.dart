import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/storage/hive_manager.dart';

import '../model/update_log_model.dart';
import '../service/update_service.dart';

class UpdateState {
  final UpdateLogInfo? backend;
  final UpdateLogInfo? sites;
  final bool isBackendLoading;
  final bool isSitesLoading;
  final UpgradeAction? updatingAction;
  final String? error;
  final String? updateMessage;

  const UpdateState({
    this.backend,
    this.sites,
    this.isBackendLoading = false,
    this.isSitesLoading = false,
    this.updatingAction,
    this.error,
    this.updateMessage,
  });

  bool get isLoading => isBackendLoading || isSitesLoading;

  bool get isUpdating => updatingAction != null;

  bool get hasAnyUpdate =>
      backend?.needsUpdate == true || sites?.needsUpdate == true;

  bool get hasUnknownStatus =>
      backend?.hasUpdate == null || sites?.hasUpdate == null;

  bool get allLatest => !hasUnknownStatus && !hasAnyUpdate;

  int get updateCount {
    final backendCount = backend?.pendingUpdateCount ?? 0;
    final sitesCount = sites?.pendingUpdateCount ?? 0;
    return backendCount + sitesCount;
  }

  UpdateState copyWith({
    UpdateLogInfo? backend,
    UpdateLogInfo? sites,
    bool? isBackendLoading,
    bool? isSitesLoading,
    UpgradeAction? updatingAction,
    String? error,
    String? updateMessage,
    bool clearUpdatingAction = false,
    bool clearError = false,
    bool clearUpdateMessage = false,
  }) {
    return UpdateState(
      backend: backend ?? this.backend,
      sites: sites ?? this.sites,
      isBackendLoading: isBackendLoading ?? this.isBackendLoading,
      isSitesLoading: isSitesLoading ?? this.isSitesLoading,
      updatingAction: clearUpdatingAction
          ? null
          : updatingAction ?? this.updatingAction,
      error: clearError ? null : error ?? this.error,
      updateMessage: clearUpdateMessage
          ? null
          : updateMessage ?? this.updateMessage,
    );
  }
}

final updateServiceProvider = Provider<UpdateService>(
  (_) => const UpdateService(),
);

final updateProvider =
    StateNotifierProvider.autoDispose<UpdateNotifier, UpdateState>((ref) {
      return UpdateNotifier(ref);
    });

class UpdateNotifier extends StateNotifier<UpdateState> {
  final Ref ref;

  UpdateNotifier(this.ref) : super(const UpdateState()) {
    refresh();
  }

  Future<void> refresh({bool showLoading = true}) async {
    if (!mounted) return;
    if (!HiveManager.hasAccessToken) return;

    if (showLoading) {
      state = state.copyWith(
        isBackendLoading: true,
        isSitesLoading: true,
        clearError: true,
      );
    }

    final service = ref.read(updateServiceProvider);
    final results = await Future.wait([
      _loadTarget(service, UpdateTarget.backend),
      _loadTarget(service, UpdateTarget.sites),
    ]);

    if (!mounted) return;

    final backend = results[0].info;
    final sites = results[1].info;
    final errors = results
        .map((result) => result.error)
        .whereType<String>()
        .toList();

    state = state.copyWith(
      backend: backend ?? state.backend,
      sites: sites ?? state.sites,
      isBackendLoading: false,
      isSitesLoading: false,
      error: errors.isEmpty ? null : errors.join('\n'),
      clearError: errors.isEmpty,
    );
  }

  Future<void> refreshTarget(UpdateTarget target) async {
    if (!mounted) return;
    if (!HiveManager.hasAccessToken) return;

    state = _copyTargetLoading(state, target, true).copyWith(clearError: true);
    try {
      final info = await ref.read(updateServiceProvider).fetchLog(target);
      if (!mounted) return;

      state = _copyTargetInfo(
        _copyTargetLoading(state, target, false),
        target,
        info,
      ).copyWith(clearError: true);
    } catch (e) {
      if (!mounted) return;

      state = _copyTargetLoading(
        state,
        target,
        false,
      ).copyWith(error: '${target.title}更新日志获取失败');
    }
  }

  Future<bool> runUpdate(UpgradeAction action) async {
    if (!mounted) return false;
    if (!HiveManager.hasAccessToken) return false;

    state = state.copyWith(
      updatingAction: action,
      clearError: true,
      clearUpdateMessage: true,
    );
    try {
      final message = await ref.read(updateServiceProvider).runUpdate(action);
      if (!mounted) return false;

      state = state.copyWith(clearUpdatingAction: true, updateMessage: message);
      await _refreshAfterUpdate(action);
      return true;
    } catch (e) {
      if (!mounted) return false;

      state = state.copyWith(clearUpdatingAction: true, error: e.toString());
      return false;
    }
  }

  Future<void> _refreshAfterUpdate(UpgradeAction action) {
    switch (action) {
      case UpgradeAction.django:
        return refreshTarget(UpdateTarget.backend);
      case UpgradeAction.sites:
        return refreshTarget(UpdateTarget.sites);
      case UpgradeAction.all:
      case UpgradeAction.webui:
        return refresh(showLoading: false);
    }
  }

  Future<({UpdateLogInfo? info, String? error})> _loadTarget(
    UpdateService service,
    UpdateTarget target,
  ) async {
    try {
      return (info: await service.fetchLog(target), error: null);
    } catch (e) {
      return (info: null, error: '${target.title}更新日志获取失败');
    }
  }

  UpdateState _copyTargetLoading(
    UpdateState state,
    UpdateTarget target,
    bool value,
  ) {
    switch (target) {
      case UpdateTarget.backend:
        return state.copyWith(isBackendLoading: value);
      case UpdateTarget.sites:
        return state.copyWith(isSitesLoading: value);
    }
  }

  UpdateState _copyTargetInfo(
    UpdateState state,
    UpdateTarget target,
    UpdateLogInfo info,
  ) {
    switch (target) {
      case UpdateTarget.backend:
        return state.copyWith(backend: info);
      case UpdateTarget.sites:
        return state.copyWith(sites: info);
    }
  }
}
