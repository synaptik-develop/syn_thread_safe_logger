import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:syn_log_interface/syn_log_interface.dart';

/// Base class for filter system.
@immutable
abstract base class IFilter {
  @literal
  const IFilter({this.logLevels = const Any(), this.sources = const Any()});

  final ICondition logLevels;

  final ICondition sources;

  /// Is called every time a new log message is sent and decides if
  /// it will be printed or canceled.
  ///
  /// Returns `true` if the message should be logged.
  bool shouldLog(LogEvent event) =>
      logLevels.isLegitimate(event) && sources.isLegitimate(event);
}

/// Type of comparators for [IFilter.logLevels].
/// Also applicable for [num] in common.
enum LogLevelEqualType {
  equal,
  notEqual,

  /// Log level is more important that target and close to [LogLevel.fatal]
  more,

  /// Log level is less important that target and close to [LogLevel.verbose]
  less,
  moreOrEqual,
  lessOrEqual,
}

/// Type od comparators for [IFilter.sources].
/// Also applicable for [String] in common.
enum LogSourceEqualType {
  /// Contains full equivalent
  equal,

  /// Does not contain full equivalent
  notEqual,

  /// Target prefix
  startWith,

  /// Target suffix
  endWith,

  /// Target substring
  contains,
}

/// Hold single condition for [LogEvent.level].
/// Can be combined by [OneOfLogEvent], [AllOfLogEvent].
final class LogLevelConditionData implements ILogEventCondition {
  const LogLevelConditionData({required this.level, required this.equalType});

  final LogLevel level;
  final LogLevelEqualType equalType;

  @override
  bool isLegitimate(LogEvent event) => switch (equalType) {
    LogLevelEqualType.equal => event.level == level,
    LogLevelEqualType.notEqual => event.level != level,
    LogLevelEqualType.more => event.level.weight > level.weight,
    LogLevelEqualType.less => event.level.weight < level.weight,
    LogLevelEqualType.moreOrEqual => event.level.weight >= level.weight,
    LogLevelEqualType.lessOrEqual => event.level.weight <= level.weight,
  };
}

/// Hold single codition for [LogEvent.sourceName]
/// Can be combined by [OneOfLogEvent], [AllOfLogEvent].
final class LogSourceConditionData implements ILogEventCondition {
  const LogSourceConditionData({
    required this.allowedSource,
    required this.equalType,
  });
  final HashSet<SourceName> allowedSource;
  final LogSourceEqualType equalType;
  @override
  bool isLegitimate(LogEvent state) => switch (equalType) {
    LogSourceEqualType.equal => allowedSource.contains(state.sourceName),
    LogSourceEqualType.notEqual => !allowedSource.contains(state.sourceName),
    LogSourceEqualType.startWith => allowedSource.any(
      (target) => state.sourceName.startsWith(target),
    ),
    LogSourceEqualType.endWith => allowedSource.any(
      (target) => state.sourceName.endsWith(target),
    ),
    LogSourceEqualType.contains => allowedSource.any(
      (target) => state.sourceName.contains(target),
    ),
  };
}

/// Default placeholder, bypass anything.
final class Any implements ICondition {
  const Any();
  @override
  bool isLegitimate(Object _) => true;
}

/// Hold sum of conditions, where only one above all must be true
final class OneOfLogEvent implements ILogEventCondition {
  const OneOfLogEvent({this.conditions = const []});

  final Iterable<ILogEventCondition> conditions;

  @override
  bool isLegitimate(LogEvent event) =>
      conditions.any((v) => v.isLegitimate(event));
}

/// Hold sum of conditions, where  all must be true
final class AllOfLogEvent implements ILogEventCondition {
  const AllOfLogEvent({this.conditions = const []});

  final Iterable<ILogEventCondition> conditions;

  @override
  bool isLegitimate(LogEvent event) =>
      conditions.every((v) => v.isLegitimate(event));
}

/// Condition interface for logger goal.
abstract interface class ILogEventCondition implements ICondition {
  @override
  bool isLegitimate(LogEvent state);
}

/// Top-level interface for condition in general.
abstract interface class ICondition {
  bool isLegitimate(covariant Object state);
}
