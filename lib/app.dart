import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'routes/home/home.dart';

class App extends StatelessWidget {
  static const _title = 'Click to Chat';

  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primarySwatch = Colors.green;
    // const darkAccentColor = Color.fromRGBO(37, 211, 102, 1);

    final theme = ThemeData(
      brightness: Brightness.light,
      primarySwatch: primarySwatch,
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primarySwatch: primarySwatch,
      // accentColor: darkAccentColor,
    );

    return MaterialApp(
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
      home: const Home(title: _title),
      localizationsDelegates: const [
        // This is where all translations are defined, will be added later.
        AppLocalizations.delegate,
        // Built-in delegate for the localization of the Material widgets.
        GlobalMaterialLocalizations.delegate,
        // Built-in localization for text direction (ltr or rtl).
        GlobalWidgetsLocalizations.delegate,
        // Built-in delegate for the localization of the Cupertino widgets.
        GlobalCupertinoLocalizations.delegate,
      ],
      // Make sure you're not using the title property!
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('it', 'IT'),
      ],
      theme: theme,
    );
  }
}
