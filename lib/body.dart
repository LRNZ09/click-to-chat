import 'dart:convert';

import 'package:click_to_chat/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mdi/mdi.dart';
import 'package:open_appstore/open_appstore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sim_info/sim_info.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

const _kWHOPhoneNumber = '+41798931892';

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

  int get hashCode => alpha2Code.hashCode;

  bool operator ==(other) =>
      (other is Country && other.alpha2Code == alpha2Code);
}

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

enum PopupMenuItemEnum { about, sendFeedback }

class _BodyState extends State<Body> {
  final _phoneNumberMaxLength = 12;

  var _countriesFuture = http.get(
    'https://restcountries.eu/rest/v2/all?fields=alpha2Code;callingCodes;nativeName',
  );

  Country _phoneNumberCountry;
  var _phoneNumber = '';
  var _phoneNumberSet = Set();
  var _phoneNumberDateTimeMap = {};

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
      final shouldShowPermissionDialog = await PermissionHandler()
          .shouldShowRequestPermissionRationale(PermissionGroup.phone);

      var shouldAskPermission = true;
      if (shouldShowPermissionDialog) {
        shouldAskPermission = await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => AlertDialog(
            content: Text(
                'Phone permission is required in order to get the country from your SIM card, otherwise the one of your locale will be used in its place'),
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
        final permissions = await PermissionHandler()
            .requestPermissions([PermissionGroup.phone]);

        if (permissions[PermissionGroup.phone] == PermissionStatus.granted ||
            permissions[PermissionGroup.phone] == PermissionStatus.unknown) {
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
      final response = await http.get(
        'https://restcountries.eu/rest/v2/lang/${locale.languageCode}?fields=alpha2Code;callingCodes;nativeName',
      );
      simCountryMap = json.decode(response.body)[0];
    } else {
      final response = await http.get(
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
    var url = phoneNumber == _kWHOPhoneNumber
        ? 'whatsapp://send?phone=$phoneNumber&text=hi'
        : 'whatsapp://send?phone=$phoneNumber';

    if (await url_launcher.canLaunch(url)) {
      await url_launcher.launch(url);

      setState(() {
        _phoneNumberSet.add(phoneNumber);
        _phoneNumberDateTimeMap[phoneNumber] = DateTime.now();
      });
    } else {
      try {
        await OpenAppstore.launch(
          androidAppId: 'com.whatsapp',
          iOSAppId: '310633997',
        );
      } catch (error) {
        await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(AppLocalizations.of(context).badNews),
            content: Text(
              'It seems you don\'t have WhatsApp installed, try installing it from the store.',
            ),
            actions: [
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
    }
  }

  void _onButtonPressed() {
    var fullPhoneNumber = '+${_phoneNumberCountry.callingCode}$_phoneNumber';
    _onListTileTap(fullPhoneNumber);
  }

  void _copyPhoneNumber(String phoneNumber) async {
    var data = ClipboardData(text: phoneNumber);
    await Clipboard.setData(data);

    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Phone number $phoneNumber copied to clipboard',
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
          'Phone number $phoneNumber has been deleted',
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
                              icon: Icon(Mdi.progressAlert),
                              onPressed: () {
                                setState(() {
                                  _countriesFuture = http.get(
                                    'https://restcountries.eu/rest/v2/all?fields=alpha2Code;callingCodes;nativeName',
                                  );
                                });
                              })
                          : Icon(
                              snapshot.hasData
                                  ? Mdi.arrowDownDropCircle
                                  : Mdi.progressClock,
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
        ListTile(
          contentPadding: EdgeInsets.all(16),
          onTap: () {
            _onListTileTap(_kWHOPhoneNumber);
          },
          onLongPress: () {
            _copyPhoneNumber(_kWHOPhoneNumber);
          },
          title: Text('World Health Organization'),
          subtitle: Text(
            'This service will provide you with the latest information and guidance from WHO on the current outbreak of coronavirus disease (COVID-19)',
          ),
          leading: Icon(Mdi.earth),
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
                              leading: Icon(Mdi.phoneClassic),
                              title: Text(AppLocalizations.of(context).call),
                              onTap: () async {
                                Navigator.pop(context);

                                var url = 'tel://$phoneNumber';
                                await url_launcher.launch(url);
                              },
                            ),
                            ListTile(
                              leading: Icon(Mdi.messageText),
                              title: Text(
                                AppLocalizations.of(context).sendSmsMessage,
                              ),
                              onTap: () async {
                                Navigator.pop(context);

                                var url = 'sms://$phoneNumber';
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
                title: Text(phoneNumber),
                subtitle: Text(phoneNumberDateTime),
              ),
            );
          },
        )
      ],
    );
  }
}
