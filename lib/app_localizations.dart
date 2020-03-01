import 'package:click_to_chat/l10n/messages_all.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

var SUPPORTED_LOCALES = ['en', 'it'];

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) async {
    final String name = locale.countryCode == null || locale.countryCode.isEmpty
        ? locale.languageCode
        : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    await initializeMessages(localeName);

    Intl.defaultLocale = localeName;

    return AppLocalizations();
  }

  // Localizations are usually accessed using the InheritedWidget "of" syntax.
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Messages which contain a string in the default language of your app and a name as identifier.
  // CamelCasing is required for the name of the Intl message.
  String get about => Intl.message('About', name: 'about');
  String get appTitle => Intl.message('Click to Chat', name: 'appTitle');
  String get country => Intl.message('Country', name: 'country');
  String get homeOpenButton =>
      Intl.message('Open in WhatsApp', name: 'homeOpenButton');
  String get phoneNumber => Intl.message('Phone number', name: 'phoneNumber');
  String get sendFeedback =>
      Intl.message('Send feedback', name: 'sendFeedback');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  // As the instance of this delegate will never change, it can have a const constructor.
  const AppLocalizationsDelegate();

  // Checks whether or not a certain locale (or language code in this cast) is supported.
  // The order of the locales doesn't matter in this case.
  @override
  bool isSupported(Locale locale) =>
      SUPPORTED_LOCALES.contains(locale.languageCode);

  // Load the translations of a certain locale.
  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  // Defines whether or not all the app’s widgets should be reloaded when the load method is completed.
  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
