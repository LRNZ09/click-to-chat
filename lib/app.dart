import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'home.dart';

class App extends StatelessWidget {
  final title = 'Click to Chat';

  @override
  Widget build(BuildContext context) {
    final primarySwatch = Colors.green;

    final theme = ThemeData(
      brightness: Brightness.light,
      primarySwatch: primarySwatch,
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primarySwatch: primarySwatch,
    );

    return MaterialApp(
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
      home: Home(title: title),
      localizationsDelegates: [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('it'),
      ],
      theme: theme,
      title: title,
    );
  }
}
