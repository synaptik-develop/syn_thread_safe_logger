import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:syn_log_interface/syn_log_interface.dart';
import 'package:syn_thread_safe_logger/src/parts/filter/filter.dart';

typedef DaemonParams = ({IFilter? logFilter, List<LogWriter>? writers});

abstract final class LoggerDaemon {
  const LoggerDaemon._();

  static const _loggerServicePortName = 'LOGGER_SERVICE_MESSAGE';

  static void sendMessageToDaemon(LogEvent event) =>
      IsolateNameServer.lookupPortByName(
        _loggerServicePortName,
      )?.send(event.toMap());

  static void changeLogParams(DaemonParams params) =>
      IsolateNameServer.lookupPortByName(_loggerServicePortName)?.send(params);

  static bool get isDaemonExist =>
      IsolateNameServer.lookupPortByName(_loggerServicePortName) != null;

  static void spawn(DaemonParams params) {
    final (:logFilter, :writers) = params;
    if (logFilter == null || writers == null) {
      throw StateError(
        'LogFilter and Writer objects should not be null when spawned',
      );
    }
    final worker = _Worker(logFilter: logFilter, writers: writers);
    _registerLoggerDaemonMessagePort(worker.receivePort.sendPort);
    worker.startListening();
  }

  static void _registerLoggerDaemonMessagePort(SendPort sendPort) {
    final deletionResult = IsolateNameServer.removePortNameMapping(
      _loggerServicePortName,
    );

    assert(!deletionResult, 'PortName re-creation not allowed');

    final creationResult = IsolateNameServer.registerPortWithName(
      sendPort,
      _loggerServicePortName,
    );
    assert(creationResult, 'New LoggerServiceMessagePort was not created');
  }
}

class _Worker {
  _Worker({required this.logFilter, required this.writers});

  final receivePort = ReceivePort();

  IFilter logFilter;

  List<LogWriter> writers;

  void startListening() => receivePort.listen(_incomingLogsMessageHandler);

  void _incomingLogsMessageHandler(Object? message) {
    if (message is DaemonParams) {
      return _handleControlMessage(message);
    }
    if (message is Map<String, Object>) {
      return _handleLogEvent(message);
    }
    log('Unknown event type: $message', name: 'LoggerDaemonWorker');
  }

  void _handleLogEvent(Map<String, Object> rawEvent) {
    final event = LogEvent.fromMap(rawEvent);
    if (!logFilter.shouldLog(event)) {
      return;
    }
    for (final writer in writers) {
      writer.write(event);
    }
  }

  void _handleControlMessage(DaemonParams daemonParams) {
    if (daemonParams.logFilter != null) {
      logFilter = daemonParams.logFilter!;
    }
    if (daemonParams.writers != null) {
      writers.addAll(daemonParams.writers!);
    }
  }
}
