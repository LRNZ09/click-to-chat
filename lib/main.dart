import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'sentry.dart';

void main() {
  FlutterError.onError = _onFlutterError;

  // Run the whole app in a zone to capture all uncaught errors.
  runZoned(_runApp, onError: _onError);
}

void _runApp() {
  runApp(App());
}

void _onFlutterError(FlutterErrorDetails details) {
  _onError(details.exception, details.stack);

  // Also use Flutter's pretty error logging to the device's console.
  FlutterError.dumpErrorToConsole(details, forceReport: true);
}

void _onError(Object error, StackTrace stackTrace) {
  try {
    sentry.captureException(
      exception: error,
      stackTrace: stackTrace,
    );
    print('Error sent to sentry.io: $error');
  } catch (sentryError) {
    print('Sending report to Sentry failed: $sentryError');
    print('Original error: $error');
  }
}
