import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_localizations.dart';
import 'routes/home/home.dart';

class App extends StatelessWidget {
  static final _title = 'Click to Chat';

  @override
  Widget build(BuildContext context) {
    final primarySwatch = Colors.green;
    final darkAccentColor = Color.fromRGBO(37, 211, 102, 1);

    final theme = ThemeData(
      brightness: Brightness.light,
      primarySwatch: primarySwatch,
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primarySwatch: primarySwatch,
      accentColor: darkAccentColor,
    );

    return MaterialApp(
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
      home: Home(title: _title),
      localizationsDelegates: [
        // This is where all translations are defined, will be added later.
        const AppLocalizationsDelegate(),
        // Built-in delegate for the localisation of the Material widgets.
        GlobalMaterialLocalizations.delegate,
        // Built-in localisation for text direction (ltr or rtl).
        GlobalWidgetsLocalizations.delegate,
        // Built-in delegate for the localisation of the Cupertino widgets.
        GlobalCupertinoLocalizations.delegate,
      ],
      // Make sure you're not using the title property!
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('it', 'IT'),
      ],
      theme: theme,
    );
  }
}
