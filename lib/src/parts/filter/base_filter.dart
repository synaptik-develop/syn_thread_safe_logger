import 'dart:collection';

import 'package:syn_log_interface/syn_log_interface.dart';
import 'package:syn_thread_safe_logger/src/parts/filter/filter.dart';

/// See this [link](https://github.com/flutter/flutter/pull/10966/files#diff-fa691172dd6cfc02a53caddd6ead6320)
/// about specific key 'dart.vm.product' for [bool.fromEnvironment] call.
/// To avoid flutter import for [kDebugMode] flag.
final class BaseFilter extends IFilter {
  BaseFilter({List<ISource> allowedSources = const []})
    : super(
        logLevels:
            !(const bool.fromEnvironment('dart.vm.product'))
                ? const Any()
                : const OneOfLogEvent(
                  conditions: [
                    LogLevelConditionData(
                      level: LogLevel.info,
                      equalType: LogLevelEqualType.moreOrEqual,
                    ),
                  ],
                ),
        sources:
            allowedSources.isEmpty
                ? const Any()
                : OneOfLogEvent(
                  conditions: [
                    LogSourceConditionData(
                      allowedSource: HashSet.of(
                        allowedSources.map((e) => e.name),
                      ),
                      equalType: LogSourceEqualType.equal,
                    ),
                  ],
                ),
      );
}
