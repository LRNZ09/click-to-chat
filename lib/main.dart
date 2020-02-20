import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';

import 'app.dart';
import 'sentry.dart';

/// Whether the VM is running in debug mode.
bool get isInDebugMode {
  // Assume you're in production mode.
  bool inDebugMode = false;

  // Assert expressions are only evaluated during development. They are ignored
  // in production. Therefore, this code only sets `inDebugMode` to true
  // in a development environment.
  assert(inDebugMode = true);

  return inDebugMode;
}

void main() {
  // This captures errors reported by the Flutter framework.
  FlutterError.onError = _onFlutterError;

  // Run the whole app in a zone to capture all uncaught errors.
  runZoned(_runApp, onError: _onError);

  // Keep screen on in debug mode
  Wakelock.toggle(on: isInDebugMode);
}

void _runApp() {
  runApp(App());
}

void _onFlutterError(FlutterErrorDetails details) {
  if (isInDebugMode) {
    // In development mode, simply print to console.
    FlutterError.dumpErrorToConsole(details);
  } else {
    // In production mode, report to the application zone to report to
    // Sentry.
    Zone.current.handleUncaughtError(details.exception, details.stack);
  }
}

// Whenever an error occurs, call the `_reportError` function. This sends
// Dart errors to the dev console or Sentry depending on the environment.
void _onError(dynamic error, dynamic stackTrace) async {
  if (isInDebugMode) {
    // Print the full stacktrace in debug mode.
    print(error);
    print(stackTrace);
    return;
  }
  // Send the Exception and Stacktrace to Sentry in Production mode.
  try {
    final response = await sentry.captureException(
      exception: error,
      stackTrace: stackTrace,
    );

    if (response.isSuccessful) {
      print('Success! Event ID: ${response.eventId}');
    } else {
      print('Failed to report to Sentry.io: ${response.error}');
    }
  } catch (sentryError) {
    print('Sending report to Sentry failed: $sentryError');
    print('Original error: $error');
  }
}
