[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)

# syn_thread_safe_logger

Extensible logging package for logging applications, the writing core is placed in a separate isolate, allowing it to be used in applications with more than one isolate.

Allows you to create custom classes for writing logs to different outputs (console, file, firebase, etc), by implementing the `LogWriter` interface