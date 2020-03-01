import 'package:click_to_chat/app_localizations.dart';
import 'package:click_to_chat/routes/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
        // This is where all translations are defined, will be added later.
        const AppLocalizationsDelegate(),
        // Built-in delegate for the localisation of the Material widgets (e.g. tooltips).
        GlobalMaterialLocalizations.delegate,
        // Built-in localisation for text direction (left-to-right or right-to-left).
        GlobalWidgetsLocalizations.delegate,
        // Built-in delegate for the localisation of the Cupertino widgets.
        GlobalCupertinoLocalizations.delegate,
      ],
      // Make sure you're not using the title property!
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context).appTitle,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('it', 'IT'),
      ],
      theme: theme,
    );
  }
}
