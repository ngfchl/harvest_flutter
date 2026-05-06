import 'dart:io';

import 'package:archive/archive.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../storage/storage_keys.dart';

/// 日志级别，从低到高
enum LogLevel {
  verbose, // 0
  debug, // 1
  info, // 2
  warn, // 3
  error, // 4
  off, // 5 - 关闭所有日志
}

class AppLogger {
  static late Logger _consoleLogger;
  static File? _logFile;
  static bool _isInitialized = false;
  static const int _maxLogDays = 7;

  /// 当前日志级别，默认 debug（开发环境）
  static LogLevel _level = LogLevel.debug;

  /// 设置日志级别
  static void setLevel(LogLevel level) {
    _level = level;
    info('日志级别已设置为: ${level.name}');
  }

  /// 获取当前日志级别
  static LogLevel get level => _level;

  /// 初始化日志（自动从存储读取级别）
  static Future<void> init() async {
    if (_isInitialized) return;

    // 从存储读取日志级别
    var savedIndex = HiveManager.get(StorageKeys.loggerLevel);
    if (savedIndex.runtimeType != int) {
      savedIndex = 2;
    }
    _level = savedIndex != null ? LogLevel.values[savedIndex as int] : LogLevel.debug;

    _consoleLogger = Logger(
      printer: PrettyPrinter(methodCount: 2, errorMethodCount: 8, colors: true, printEmojis: true, printTime: true),
    );
    await _initFileLogger();
    await _clearOldLogs();
    _isInitialized = true;
    info('✅ 日志初始化完成（级别: ${_level.name}）');
  }

  /// 重新初始化（切换级别后调用）
  static Future<void> reinit(LogLevel level) async {
    _level = level;
    await HiveManager.set(StorageKeys.loggerLevel, level.index);
    _consoleLogger = Logger(
      printer: PrettyPrinter(methodCount: 2, errorMethodCount: 8, colors: true, printEmojis: true, printTime: true),
    );
    info('日志级别已切换为: ${level.name}');
  }

  /// 初始化日志文件
  static Future<void> _initFileLogger() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logDir = Directory(path.join(dir.path, 'logs'));
      if (!await logDir.exists()) await logDir.create();

      final date = DateTime.now().toString().split(' ')[0];
      final logPath = path.join(logDir.path, 'app_$date.log');
      _logFile = File(logPath);
    } catch (e) {
      print('日志文件初始化失败: $e');
    }
  }

  /// 写入文件（不受级别限制，始终写入，方便排查问题）
  static void _writeToFile(String level, String message) {
    if (_logFile == null) return;
    try {
      final time = DateTime.now().toIso8601String();
      _logFile!.writeAsString('[$time] [$level] $message\n', mode: FileMode.append);
    } catch (e) {}
  }

  static Future<void> _clearOldLogs() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logDir = Directory(path.join(dir.path, 'logs'));
      if (!await logDir.exists()) return;

      final now = DateTime.now();
      await for (final file in logDir.list()) {
        if (file is File && file.path.endsWith('.log')) {
          final lastMod = await file.lastModified();
          if (now.difference(lastMod).inDays > _maxLogDays) {
            await file.delete();
          }
        }
      }
    } catch (e) {}
  }

  static Future<File?> compressAllLogs() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logDir = Directory(path.join(dir.path, 'logs'));
      if (!await logDir.exists()) return null;

      final zipPath = path.join(dir.path, 'app_logs_${DateTime.now().millisecondsSinceEpoch}.zip');
      final archive = Archive();

      await for (final file in logDir.list()) {
        if (file is File && file.path.endsWith('.log')) {
          final bytes = await file.readAsBytes();
          archive.addFile(ArchiveFile(path.basename(file.path), bytes.length, bytes));
        }
      }

      final zipBytes = ZipEncoder().encode(archive);
      final zipFile = File(zipPath);
      await zipFile.writeAsBytes(zipBytes);
      return zipFile;
    } catch (err) {
      error('压缩失败', err);
      return null;
    }
  }

  static Future<void> shareLogs() async {
    final zip = await compressAllLogs();
    if (zip == null) return;
    await SharePlus.instance.share(ShareParams(files: [XFile(zip.path)], text: '导出日志'));
  }

  // 在 shareLogs 方法后面加
  static Future<void> shareSingleLog(File file) async {
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: '导出日志: ${path.basename(file.path)}'));
  }

  static Future<void> deleteAllLogFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logDir = Directory(path.join(dir.path, 'logs'));
      if (await logDir.exists()) {
        await for (final entity in logDir.list()) {
          if (entity is File && entity.path.endsWith('.log')) {
            await entity.delete();
          }
        }
        // 删除打包的 zip
        await for (final entity in dir.list()) {
          if (entity is File && entity.path.endsWith('.zip') && entity.path.contains('app_logs')) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      error('删除日志文件失败', e);
    }
  }

  // ———————————————— 对外调用（带级别过滤）————————————————
  static void verbose(dynamic msg) {
    _writeToFile('VERBOSE', msg.toString());
    if (_level.index <= LogLevel.verbose.index) {
      _consoleLogger.v(msg);
    }
  }

  static void debug(dynamic msg) {
    _writeToFile('DEBUG', msg.toString());
    if (_level.index <= LogLevel.debug.index) {
      _consoleLogger.d(msg);
    }
  }

  static void info(dynamic msg) {
    _writeToFile('INFO', msg.toString());
    if (_level.index <= LogLevel.info.index) {
      _consoleLogger.i(msg);
    }
  }

  static void warn(dynamic msg) {
    _writeToFile('WARN', msg.toString());
    if (_level.index <= LogLevel.warn.index) {
      _consoleLogger.w(msg);
    }
  }

  static void error(dynamic msg, [dynamic error, StackTrace? st]) {
    _writeToFile('ERROR', '$msg ${error ?? ""}');
    if (_level.index <= LogLevel.error.index) {
      _consoleLogger.e(msg, error: error, stackTrace: st);
    }
  }
}
