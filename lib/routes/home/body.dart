import 'dart:convert';

import 'package:click_to_chat/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mdi/mdi.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:sim_info/sim_info.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class Country {
  final String alpha2Code;
  final String callingCode;
  final String nativeName;

  Country({
    this.alpha2Code,
    this.callingCode,
    this.nativeName,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      alpha2Code: json['alpha2Code'],
      callingCode: json['callingCodes'][0],
      nativeName: json['nativeName'],
    );
  }

  String get emoji {
    return alpha2Code.toUpperCase().replaceAllMapped(RegExp('.'),
        (char) => String.fromCharCode(char[0].codeUnitAt(0) + 127397));
  }

  @override
  int get hashCode => alpha2Code.hashCode;

  @override
  bool operator ==(other) =>
      (other is Country && other.alpha2Code == alpha2Code);
}

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

enum PopupMenuItemEnum { about, sendFeedback }

class _BodyState extends State<Body> {
  static final _client = http.Client();
  static final _phoneNumberMaxLength = 16;

  var _countriesFuture = _client.get(
    'https://restcountries.eu/rest/v2/all?fields=alpha2Code;callingCodes;nativeName',
  );

  Country _phoneNumberCountry;
  var _phoneNumber = '';
  final _phoneNumberSet = <String>{};
  final _phoneNumberDateTimeMap = {};

  @override
  void didChangeDependencies() {
    _initPhoneNumberCountry();

    super.didChangeDependencies();
  }

  void _initPhoneNumberCountry() async {
    if (_phoneNumberCountry != null) return;

    final locale = Localizations.localeOf(context);
    var countryCode = locale.countryCode;

    try {
      var shouldAskPermission = true;

      if (await Permission.phone.shouldShowRequestRationale) {
        shouldAskPermission = await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => AlertDialog(
            content: Text(
              'Phone permission is required in order to get the country from your SIM card, otherwise the one of your locale will be used in its place',
            ),
            actions: [
              FlatButton(
                child: Text(AppLocalizations.of(context).notNow.toUpperCase()),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ],
          ),
        );
      }

      if (shouldAskPermission) {
        if (await Permission.phone.isPermanentlyDenied) {
          await openAppSettings();
          return;
        }

        final permission = await Permission.phone.request();

        if (permission.isGranted) {
          final simCountryCode = await SimInfo.getIsoCountryCode;
          if (simCountryCode.isNotEmpty) countryCode = simCountryCode;
        }
      }
    } catch (error) {
      // TODO show dialog?
      print(error);
    }

    Map<String, dynamic> simCountryMap;
    if (countryCode == null) {
      final response = await _client.get(
        'https://restcountries.eu/rest/v2/lang/${locale.languageCode}?fields=alpha2Code;callingCodes;nativeName',
      );
      simCountryMap = json.decode(response.body)[0];
    } else {
      final response = await _client.get(
        'https://restcountries.eu/rest/v2/alpha/$countryCode?fields=alpha2Code;callingCodes;nativeName',
      );
      simCountryMap = json.decode(response.body);
    }

    final simCountry = Country.fromJson(simCountryMap);
    setState(() {
      _phoneNumberCountry = simCountry;
    });
  }

  void _onPhoneNumberChanged(text) {
    setState(() {
      _phoneNumber = text;
    });
  }

  void _onListTileTap(phoneNumber) async {
    // TODO add text param 'whatsapp://send?phone=$phoneNumber&text=42'
    var url = 'whatsapp://send?phone=$phoneNumber';

    if (await url_launcher.canLaunch(url)) {
      await url_launcher.launch(url);

      setState(() {
        _phoneNumberSet.add(phoneNumber);
        _phoneNumberDateTimeMap[phoneNumber] = DateTime.now();
      });
    } else {
      await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(AppLocalizations.of(context).badNews),
          content: Text(
            'It seems you don\'t have WhatsApp installed, try installing it from the store.',
          ),
          actions: [
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: () async {
                try {
                  await StoreRedirect.redirect(
                    androidAppId: 'com.whatsapp',
                    iOSAppId: '310633997',
                  );
                } catch (_) {}
              },
            ),
          ],
        ),
      );
    }
  }

  void _onButtonPressed() {
    var fullPhoneNumber = '${_phoneNumberCountry.callingCode}$_phoneNumber';
    _onListTileTap(fullPhoneNumber);
  }

  void _copyPhoneNumber(String phoneNumber) async {
    var text = '+$phoneNumber';
    var data = ClipboardData(text: text);
    await Clipboard.setData(data);

    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Phone number $text copied to clipboard',
        ),
      ),
    );
  }

  void _deletePhoneNumber(String phoneNumber) {
    setState(() {
      _phoneNumberSet.remove(phoneNumber);
    });

    Scaffold.of(context).showSnackBar(
      SnackBar(
        action: SnackBarAction(
          label: (AppLocalizations.of(context).undo).toUpperCase(),
          onPressed: () {
            setState(() {
              _phoneNumberSet.add(phoneNumber);
            });
          },
        ),
        content: Text(
          'Phone number +$phoneNumber has been deleted',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(bottom: 240),
      children: [
        Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              FutureBuilder(
                future: _countriesFuture,
                builder: (context, AsyncSnapshot<http.Response> snapshot) {
                  var countries = [];
                  if (snapshot.hasData) {
                    countries = json.decode(snapshot.data.body);
                  }

                  var items = countries
                      .map((countryMap) => Country.fromJson(countryMap))
                      .where((country) => country.callingCode.isNotEmpty)
                      .map(
                        (country) => DropdownMenuItem(
                          key: ValueKey(country),
                          value: country,
                          child:
                              Text('${country.emoji}  ${country.nativeName}'),
                        ),
                      )
                      .toList();

                  return InputDecorator(
                    decoration: InputDecoration(
                      filled: true,
                      prefixIcon: Icon(Mdi.flagVariant),
                      labelText: AppLocalizations.of(context).country,
                      suffixIcon: snapshot.hasError
                          ? IconButton(
                              icon: Icon(Mdi.alert),
                              onPressed: () {
                                setState(() {
                                  _countriesFuture = _client.get(
                                    'https://restcountries.eu/rest/v2/all?fields=alpha2Code;callingCodes;nativeName',
                                  );
                                });
                              },
                              tooltip: ' Retry',
                            )
                          : Icon(
                              snapshot.hasData ? Mdi.menuDown : Mdi.loading,
                            ),
                    ),
                    isEmpty: _phoneNumberCountry == null,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        iconSize: 0,
                        value: _phoneNumberCountry,
                        isDense: true,
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            _phoneNumberCountry = value;
                          });
                        },
                        items: items,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 16,
              ),
              TextField(
                decoration: InputDecoration(
                  prefixText: _phoneNumberCountry != null
                      ? '+${_phoneNumberCountry.callingCode} '
                      : '+',
                  errorText: _phoneNumber.length > _phoneNumberMaxLength
                      ? 'Are you sure this phone number is correct?'
                      : null,
                  filled: true,
                  labelText: AppLocalizations.of(context).phoneNumber,
                  prefixIcon: Icon(Mdi.dialpad),
                ),
                keyboardType: TextInputType.phone,
                maxLength: _phoneNumberMaxLength,
                maxLengthEnforced: false,
                onChanged: _onPhoneNumberChanged,
              ),
              SizedBox(
                height: 24,
              ),
              RaisedButton.icon(
                icon: Icon(Mdi.whatsapp),
                label: Text(AppLocalizations.of(context).homeOpenButton),
                onPressed: _phoneNumber.isEmpty ? null : _onButtonPressed,
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: _phoneNumberSet.length,
          itemBuilder: (context, index) {
            var reverseIndex = _phoneNumberSet.length - index - 1;

            var phoneNumber = _phoneNumberSet.elementAt(reverseIndex);

            var languageCode = Localizations.localeOf(context).languageCode;
            var phoneNumberDateTime = DateFormat.yMMMMd(languageCode)
                .add_jm()
                .format(_phoneNumberDateTimeMap[phoneNumber]);

            return Dismissible(
              key: Key(phoneNumber),
              background: Container(
                color: Colors.blue,
                alignment: Alignment.centerLeft,
                child: Icon(Mdi.contentCopy, color: Colors.white),
                padding: EdgeInsets.only(left: 24),
              ),
              secondaryBackground: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                child: Icon(Mdi.delete, color: Colors.white),
                padding: EdgeInsets.only(right: 24),
              ),
              onDismissed: (direction) {
                _deletePhoneNumber(phoneNumber);
              },
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) return true;

                _copyPhoneNumber(phoneNumber);
                return false;
              },
              child: ListTile(
                onTap: () {
                  _onListTileTap(phoneNumber);
                },
                onLongPress: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(Mdi.shareVariant),
                              title: Text(AppLocalizations.of(context).share),
                              onTap: () async {
                                Navigator.pop(context);

                                var url = 'https://wa.me/$phoneNumber';
                                await Share.share(url);
                              },
                            ),
                            ListTile(
                              leading: Icon(Mdi.phone),
                              title: Text(AppLocalizations.of(context).call),
                              onTap: () async {
                                Navigator.pop(context);

                                var url = 'tel://+$phoneNumber';
                                await url_launcher.launch(url);
                              },
                            ),
                            ListTile(
                              leading: Icon(Mdi.message),
                              title: Text(
                                AppLocalizations.of(context).sendSmsMessage,
                              ),
                              onTap: () async {
                                Navigator.pop(context);

                                var url = 'sms://+$phoneNumber';
                                await url_launcher.launch(url);
                              },
                            ),
                            ListTile(
                              leading: Icon(Mdi.contentCopy),
                              title: Text(AppLocalizations.of(context).copy),
                              onTap: () {
                                Navigator.pop(context);

                                _copyPhoneNumber(phoneNumber);
                              },
                            ),
                            ListTile(
                              leading: Icon(Mdi.delete),
                              title: Text(AppLocalizations.of(context).delete),
                              onTap: () {
                                Navigator.pop(context);

                                _deletePhoneNumber(phoneNumber);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                title: Text('+$phoneNumber'),
                subtitle: Text(phoneNumberDateTime),
              ),
            );
          },
        )
      ],
    );
  }
}
