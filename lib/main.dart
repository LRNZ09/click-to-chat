import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'sentry.dart';

void main() {
  FlutterError.onError = onFlutterError;

  // Run the whole app in a zone to capture all uncaught errors.
  runZoned(() => runApp(App()), onError: onAppError);
}

var onFlutterError = (FlutterErrorDetails details) {
  try {
    onAppError(details.exception, details.stack);
  } finally {
    // Also use Flutter's pretty error logging to the device's console.
    FlutterError.dumpErrorToConsole(details, forceReport: true);
  }
};

var onAppError = (Object error, StackTrace stackTrace) {
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
};
