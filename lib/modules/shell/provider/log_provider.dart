import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:harvest/core/utils/utils.dart';

part 'log_provider.freezed.dart';

// ══════════════════════════════════════════════════════════
//  Model
// ══════════════════════════════════════════════════════════

@freezed
abstract class LogFileInfo with _$LogFileInfo {
  const factory LogFileInfo({
    required String name,
    required String filePath,
    required int sizeBytes,
    required DateTime lastModified,
  }) = _LogFileInfo;
}

@freezed
abstract class LogState with _$LogState {
  const factory LogState({
    @Default([]) List<LogFileInfo> files,
    @Default(false) bool isLoading,
    LogLevel? selectedLevel,
    // 查看器
    String? viewingFilePath,
    String? viewingFileName,
    @Default([]) List<String> viewingLines,
    @Default(false) bool isLoadingContent,
    @Default(true) bool isFollowing,
  }) = _LogState;
}

// ══════════════════════════════════════════════════════════
//  Provider
// ══════════════════════════════════════════════════════════

final logProvider = StateNotifierProvider.autoDispose<LogNotifier, LogState>((ref) => LogNotifier());

class LogNotifier extends StateNotifier<LogState> {
  Timer? _refreshTimer;
  Timer? _fileRefreshTimer;
  int _lastFileLength = 0;

  LogNotifier() : super(LogState(selectedLevel: AppLogger.level)) {
    loadFiles();
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }

  void _stopTimers() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _fileRefreshTimer?.cancel();
    _fileRefreshTimer = null;
  }

  // ══════════════════════════════════════════════════════════
  //  文件列表
  // ══════════════════════════════════════════════════════════

  Future<void> loadFiles() async {
    state = state.copyWith(isLoading: true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logDir = Directory(p.join(dir.path, 'logs'));
      if (!await logDir.exists()) {
        state = state.copyWith(isLoading: false, files: []);
        return;
      }

      final files = <LogFileInfo>[];
      await for (final entity in logDir.list()) {
        if (entity is File && entity.path.endsWith('.log')) {
          final stat = await entity.stat();
          files.add(
            LogFileInfo(
              name: p.basename(entity.path),
              filePath: entity.path,
              sizeBytes: stat.size,
              lastModified: stat.modified,
            ),
          );
        }
      }

      files.sort((a, b) => b.lastModified.compareTo(a.lastModified));
      state = state.copyWith(isLoading: false, files: files);
    } catch (e) {
      debugPrint('[LogProvider] loadFiles error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  // ══════════════════════════════════════════════════════════
  //  查看文件（支持实时追踪）
  // ══════════════════════════════════════════════════════════

  Future<void> viewFile(LogFileInfo file) async {
    _stopTimers();
    state = state.copyWith(
      viewingFilePath: file.filePath,
      viewingFileName: file.name,
      isLoadingContent: true,
      viewingLines: [],
      isFollowing: true,
    );

    try {
      final content = await File(file.filePath).readAsString();
      final lines = content.split('\n').where((l) => l.isNotEmpty).toList();
      _lastFileLength = content.length;
      state = state.copyWith(viewingLines: lines, isLoadingContent: false);
    } catch (e) {
      state = state.copyWith(viewingLines: ['读取失败: $e'], isLoadingContent: false);
    }

    // 启动实时追踪
    _startTailing(file.filePath);
  }

  /// 实时追踪：每秒检查文件是否有新内容
  void _startTailing(String filePath) {
    _fileRefreshTimer?.cancel();
    _fileRefreshTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      await _tailUpdate(filePath);
    });
  }

  Future<void> _tailUpdate(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return;

      final stat = await file.stat();
      final currentLength = stat.size;

      // 文件没有变化，跳过
      if (currentLength == _lastFileLength) return;

      String content;
      if (currentLength < _lastFileLength) {
        // 文件被截断（如日志轮转），重新读取
        content = await file.readAsString();
      } else {
        // 增量读取
        final raf = file.openSync(mode: FileMode.read);
        raf.setPositionSync(_lastFileLength);
        final newBytes = raf.readSync(currentLength - _lastFileLength);
        raf.closeSync();
        content = String.fromCharCodes(newBytes);
      }

      _lastFileLength = currentLength;

      final newLines = content.split('\n').where((l) => l.isNotEmpty).toList();
      if (newLines.isEmpty) return;

      final currentLines = List<String>.from(state.viewingLines);

      if (currentLength < stat.size) {
        // 文件被截断，全量替换
        final fullContent = await file.readAsString();
        final allLines = fullContent.split('\n').where((l) => l.isNotEmpty).toList();
        state = state.copyWith(viewingLines: allLines);
      } else {
        // 增量追加
        currentLines.addAll(newLines);
        state = state.copyWith(viewingLines: currentLines);
      }
    } catch (e) {
      debugPrint('[LogProvider] tail error: $e');
    }
  }

  /// 关闭查看器
  void closeViewer() {
    _stopTimers();
    _lastFileLength = 0;
    state = state.copyWith(viewingFilePath: null, viewingFileName: null, viewingLines: []);
  }

  /// 切换自动追踪
  void toggleFollowing() {
    state = state.copyWith(isFollowing: !state.isFollowing);
  }

  // ══════════════════════════════════════════════════════════
  //  日志级别
  // ══════════════════════════════════════════════════════════

  void setLevel(LogLevel level) {
    AppLogger.reinit(level);
    state = state.copyWith(selectedLevel: level);
  }

  // ══════════════════════════════════════════════════════════
  //  分享 / 导出
  // ══════════════════════════════════════════════════════════

  /// 分享所有日志（打包 zip）
  Future<bool> shareAllLogs() async {
    try {
      await AppLogger.shareLogs();
      return true;
    } catch (e) {
      debugPrint('[LogProvider] shareAllLogs error: $e');
      return false;
    }
  }

  /// 分享当前正在查看的单个日志文件
  Future<bool> shareCurrentFile() async {
    final filePath = state.viewingFilePath;
    if (filePath == null) return false;
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;
      // 直接分享单个文件
      await AppLogger.shareSingleLog(file);
      return true;
    } catch (e) {
      debugPrint('[LogProvider] shareCurrentFile error: $e');
      return false;
    }
  }

  /// 复制当前查看的全部内容到剪贴板
  String get currentContent => state.viewingLines.join('\n');

  // ══════════════════════════════════════════════════════════
  //  删除
  // ══════════════════════════════════════════════════════════

  Future<void> clearAllLogs() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logDir = Directory(p.join(dir.path, 'logs'));
      if (await logDir.exists()) {
        await for (final entity in logDir.list()) {
          if (entity is File && entity.path.endsWith('.log')) {
            await entity.delete();
          }
        }
      }
      await loadFiles();
    } catch (_) {}
  }

  Future<void> deleteFile(LogFileInfo file) async {
    try {
      final f = File(file.filePath);
      if (await f.exists()) await f.delete();
      await loadFiles();
    } catch (_) {}
  }

  // ══════════════════════════════════════════════════════════
  //  工具
  // ══════════════════════════════════════════════════════════

  static String formatSize(int bytes) => formatBytes(bytes);

  static String formatDate(DateTime dt) => formatDateTimeMinute(dt);
}
