import 'package:syn_log_interface/syn_log_interface.dart';

/// Default log source.
final class BaseLogSource implements ISource {
  const BaseLogSource();

  @override
  SourceName get name => 'Main';
}
