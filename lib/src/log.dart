import 'dart:isolate';
import 'dart:ui';

import 'package:syn_log_interface/syn_log_interface.dart';
import 'package:syn_logger_console_writer/syn_logger_console_writer.dart';
import 'package:syn_logger_file_writer/syn_logger_file_writer.dart';
import 'package:syn_platform_utils/syn_platform_utils.dart' as platform_utils;
import 'package:syn_thread_safe_logger/src/parts/core/logger_daemon.dart';
import 'package:syn_thread_safe_logger/src/parts/filter/filter.export.dart';

part 'parts/core/isolate_bridge.dart';

/// External `interface` for uses in application.
enum Log {
  v,
  d,
  i,
  w,
  e,
  f;

  static Future<Isolate?> initDaemon({
    IFilter? logFilter,
    List<LogWriter>? writers,
  }) async => _initLogDaemon(
    logFilter: logFilter ?? BaseFilter(),
    writers:
        writers ??
        [
          ConsoleWriter(),
          FileWriter(logDirectory: await platform_utils.logDirectory),
        ],
  );

  static void changeFilter(IFilter logFilter) =>
      _changeLoggerParams(logFilter: logFilter);

  @pragma('vm:invisible')
  void call(
    Object message, {
    ISource source = const BaseLogSource(),
    StackTrace? stackTrace,
  }) => _sendLog(
    message,
    level: _logLevelForCall,
    source: source,
    stackTrace:
        ((this == Log.e || this == Log.f) && stackTrace == null)
            ? StackTrace.current
            : stackTrace,
  );

  LogLevel get _logLevelForCall => switch (this) {
    Log.v => LogLevel.verbose,
    Log.d => LogLevel.debug,
    Log.i => LogLevel.info,
    Log.w => LogLevel.warning,
    Log.e => LogLevel.error,
    Log.f => LogLevel.fatal,
  };
}
