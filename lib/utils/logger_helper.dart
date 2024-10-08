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
  @override
  List<String> log(logger.LogEvent event) {
    String level = event.level.name.toUpperCase();
    var log = ['[$level] [${event.time}]  ${event.message} '];
    if (event.error != null) {
      log = [
        '[$level] [${event.time}]  ${event.message} \n  ${event.error} \n ${event.stackTrace}'
      ];
    }
    return log;
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
