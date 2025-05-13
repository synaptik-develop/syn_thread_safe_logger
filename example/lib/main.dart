import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:synaptic_thread_safe_logger/logger.dart';

void main() {
  Future<void>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Log.initDaemon();

    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void spamLog() {
    void event;
    Isolate.spawn<void>(
      (_) {
        while (true) {
          Log.e('spam');
        }
      },
      event,
      debugName: 'SpamIsolate',
    );
  }

  Future<void> sendFromOtherIsolate() => compute(
        (_) async {
          await Future.delayed(
            const Duration(seconds: 2),
            () => Log.i('Sended from other isolate'),
          );
        },
        null,
      );

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Logger Service Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Log.v('Example verbose message'),
                  child: const Text('Example verbose message'),
                ),
                ElevatedButton(
                  onPressed: () => Log.d('Example debug message'),
                  child: const Text('Example debug message'),
                ),
                ElevatedButton(
                  onPressed: () => Log.i('Example info message'),
                  child: const Text('Example info message'),
                ),
                ElevatedButton(
                  onPressed: () => Log.w('Example warning message'),
                  child: const Text('Example warning message'),
                ),
                ElevatedButton(
                  onPressed: () => Log.e('Example error message'),
                  child: const Text('Example error message'),
                ),
                ElevatedButton(
                  onPressed: () => Log.f(
                    'Example fatal message',
                  ),
                  child: const Text('Example fatal message'),
                ),
                ElevatedButton(
                  onPressed: sendFromOtherIsolate,
                  child: const Text('sendFromOtherIsolate'),
                ),
                ElevatedButton(onPressed: spamLog, child: const Text('SPAM')),
              ],
            ),
          ),
        ),
      );
}
