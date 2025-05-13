part of '../../log.dart';

Future<Isolate?> _initLogDaemon({
  required IFilter logFilter,
  required List<LogWriter> writers,
}) {
  assert(
    RootIsolateToken.instance != null,
    'Initialization of the logger daemon '
    'is only allowed in the root isolate',
  );

  if (LoggerDaemon.isDaemonExist) {
    Log.i('Log daemon already init');
    return Future.value();
  }

  return Isolate.spawn<DaemonParams>(LoggerDaemon.spawn, (
    logFilter: logFilter,
    writers: writers,
  ), debugName: 'LoggerDaemon');
}

void _changeLoggerParams({IFilter? logFilter, List<LogWriter>? writers}) =>
    LoggerDaemon.changeLogParams((logFilter: logFilter, writers: writers));

void _sendLog(
  Object message, {
  required LogLevel level,
  required ISource source,
  StackTrace? stackTrace,
}) => LoggerDaemon.sendMessageToDaemon(
  LogEvent(
    sourceName: source.name,
    isolateDebugName: Isolate.current.debugName,
    level: level,
    message: message.toString(),
    time: DateTime.now(),
    stackTrace: stackTrace,
  ),
);
