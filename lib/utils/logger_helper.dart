import 'dart:io';

import 'package:flutter/material.dart';
import 'package:harvest/utils/platform.dart';
import 'package:logger/logger.dart' as logger;

class MemoryLogOutput extends logger.LogOutput {
  final ValueNotifier<List<logger.OutputEvent>> logsNotifier =
      ValueNotifier([]);
  final int maxLogs = 1000;

  @override
  void output(logger.OutputEvent event) {
    final List<logger.OutputEvent> logs = List.from(logsNotifier.value)
      ..add(event);

    if (logs.length > maxLogs) {
      logs.removeAt(0); //删除最旧的日志
    }
    logsNotifier.value = logs;
  }

  void clearLogs() {
    logsNotifier.value = [];
  }
}

MemoryLogOutput memoryLogOutput = MemoryLogOutput();

class DateTimePrinter extends logger.PrettyPrinter {
  // DateTimePrinter({int methodCount = 1}) : super(methodCount: methodCount);

  @override
  List<String> log(logger.LogEvent event) {
    var messageStr = stringifyMessage(event.message);

    String? stackTraceStr;
    if (event.error != null) {
      if ((errorMethodCount == null || errorMethodCount! > 0)) {
        stackTraceStr = formatStackTrace(
          event.stackTrace ?? StackTrace.current,
          errorMethodCount,
        );
      }
    } else if (methodCount == null || methodCount! > 0) {
      stackTraceStr = formatStackTrace(
        event.stackTrace ?? StackTrace.current,
        methodCount,
      );
    }

    var errorStr = event.error?.toString();

    String? timeStr;
    // Keep backwards-compatibility to `printTime` check
    // ignore: deprecated_member_use_from_same_package
    if (printTime) {
      timeStr = getTime(event.time);
    }
    // 获取调用栈信息
    String level = event.level.name.toUpperCase();

    // 格式化日志信息，带上文件名和行号
    var log = ['[$level] [${event.time}] ${event.message}'];
    if (event.error != null) {
      log = [
        '[$event.level] [$timeStr] $messageStr \n  $errorStr \n $stackTraceStr'
      ];
    }
    return _formatAndPrint(
      event.level,
      messageStr,
      timeStr,
      errorStr,
      stackTraceStr,
    );
  }

  List<String> _formatAndPrint(
    logger.Level level,
    String message,
    String? time,
    String? error,
    String? stacktrace,
  ) {
    List<String> buffer = [];

    if (error != null) {
      for (var line in error.split('\n')) {
        if (line.contains('logger_helper')) {
          continue;
        }
        buffer.add(line);
      }
    }

    if (stacktrace != null) {
      for (var line in stacktrace.split('\n')) {
        if (line.contains('logger_helper')) {
          continue;
        }
        buffer.add(line);
      }
    }

    if (time != null) {
      buffer.add(time);
    }

    for (var line in message.split('\n')) {
      buffer.add(line);
    }
    return buffer;
  }
}

class MyFilter extends logger.LogFilter {
  @override
  bool shouldLog(logger.LogEvent event) {
    return true;
  }
}

class Logger {
  static final logger.Logger instance = logger.Logger(
    filter: MyFilter(),
    printer: DateTimePrinter(),
    level: logger.Level.trace,
    output: logger.MultiOutput(
      [
        logger.ConsoleOutput(),
        memoryLogOutput,
        if (!PlatformTool.isWeb())
          logger.FileOutput(
            file: File(
              '${Directory.systemTemp.path}/log.txt',
            ),
            overrideExisting: true,
          ),
      ],
    ),
  );
}
