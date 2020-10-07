import 'dart:async';

import 'package:click_to_chat/app.dart';
import 'package:click_to_chat/debug.dart';
import 'package:click_to_chat/sentry.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  // This captures errors reported by the Flutter framework.
  FlutterError.onError = _onFlutterError;

  // Run the whole app in a zone to capture all uncaught errors.
  runZoned(_runApp, onError: _onError);
}

void _runApp() {
  // Inform the plugin that this app supports pending purchases on Android.
  // An error will occur on Android if you access the plugin `instance`
  // without this call.
  //
  // On iOS this is a no-op.
  InAppPurchaseConnection.enablePendingPurchases();

  runApp(App());

  // Enable smooth scroll on high refresh rate screens
  GestureBinding.instance.resamplingEnabled = true;

  // Keep screen on in debug mode
  Wakelock.toggle(on: isInDebugMode);
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
