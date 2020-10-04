import 'dart:async';

import 'package:click_to_chat/app.dart';
import 'package:click_to_chat/debug.dart';
import 'package:click_to_chat/sentry.dart';
// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  // GestureBinding.instance.resamplingEnabled = true;

  // This captures errors reported by the Flutter framework.
  FlutterError.onError = _onFlutterError;

  // Run the whole app in a zone to capture all uncaught errors.
  runZoned(_runApp, onError: _onError);
}

void _runApp() {
  // For play billing library 2.0 on Android, it is mandatory to call
  // [enablePendingPurchases](https://developer.android.com/reference/com/android/billingclient/api/BillingClient.Builder.html#enablependingpurchases)
  // as part of initializing the app.
  InAppPurchaseConnection.enablePendingPurchases();

  // Keep screen on in debug mode
  Wakelock.toggle(on: isInDebugMode);

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
