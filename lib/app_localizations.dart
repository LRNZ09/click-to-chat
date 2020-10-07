import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'l10n/messages_all.dart';

const _kSupportedLocales = ['en', 'it'];

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) async {
    final name = locale.countryCode == null || locale.countryCode.isEmpty
        ? locale.languageCode
        : locale.toString();

    final localeName = Intl.canonicalizedLocale(name);

    await initializeMessages(localeName);

    Intl.defaultLocale = localeName;

    return AppLocalizations();
  }

  // Localizations are usually accessed using the InheritedWidget "of" syntax.
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get about => Intl.message('About', name: 'about');
  String get appLegalese => Intl.message('Made by LRNZ09', name: 'appLegalese');
  String get appTitle => Intl.message('Click to Chat', name: 'appTitle');
  String get badNews => Intl.message('Bad news', name: 'badNews');
  String get buyMeACoffee =>
      Intl.message('Buy me a coffee', name: 'buyMeACoffee');
  String get call => Intl.message('Call', name: 'call');
  String get close => Intl.message('Close', name: 'close');
  String get copy => Intl.message('Copy', name: 'copy');
  String get country => Intl.message('Country', name: 'country');
  String get delete => Intl.message('Delete', name: 'delete');
  String get homeOpenButton =>
      Intl.message('Open in WhatsApp', name: 'homeOpenButton');
  String get notNow => Intl.message('Not now', name: 'notNow');
  String get phoneNumber => Intl.message('Phone number', name: 'phoneNumber');
  // String get phoneNumberError => Intl.message('Phone number error', name: 'phoneNumberError');
  String get rate => Intl.message('Rate', name: 'rate');
  String get sendFeedback =>
      Intl.message('Send feedback', name: 'sendFeedback');
  String get sendSmsMessage =>
      Intl.message('Send SMS message', name: 'sendSmsMessage');
  String get share => Intl.message('Share', name: 'share');
  String get undo => Intl.message('Undo', name: 'undo');
  String get unlock => Intl.message('Unlock', name: 'unlock');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  /// As the instance of this delegate will never change,
  /// it can have a const constructor.
  const AppLocalizationsDelegate();

  // Checks whether or not a certain locale (or language code in this cast)
  // is supported. The order of the locales doesn't matter in this case.
  @override
  bool isSupported(Locale locale) =>
      _kSupportedLocales.contains(locale.languageCode);

  // Load the translations of a certain locale.
  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  // Defines whether or not all the app’s widgets should be reloaded
  // when the load method is completed.
  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
