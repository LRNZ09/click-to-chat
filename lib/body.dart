import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_brand_icons/flutter_brand_icons.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sim_info/sim_info.dart';

import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

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
      'https://restcountries.eu/rest/v2/all?fields=alpha2Code;callingCodes;nativeName');

  Country _phoneNumberCountry;
  var _phoneNumber = '';
  var _phoneNumberSet = Set();
  var _phoneNumberDateTimeMap = {};

  @override
  void initState() {
    super.initState();

    SimInfo.getIsoCountryCode.then((simCountryCode) {
      _setDefaultPhoneNumberCountry(simCountryCode);
    }).catchError((error) {
      var locale = Localizations.localeOf(context);
      var countryCode = locale.countryCode ?? 'us';
      _setDefaultPhoneNumberCountry(countryCode);
    });
  }

  void _setDefaultPhoneNumberCountry(String countryCode) async {
    var url =
        'https://restcountries.eu/rest/v2/alpha/$countryCode?fields=alpha2Code;callingCodes;nativeName';
    http.get(url).then((response) {
      var simCountryMap = json.decode(response.body);
      var simCountry = Country.fromJson(simCountryMap);
      setState(() {
        _phoneNumberCountry = simCountry;
      });
    });
  }

  void _onPhoneNumberChanged(text) {
    setState(() {
      _phoneNumber = text;
    });
  }

  void _onListTileTap(phoneNumber) async {
    var url = 'whatsapp://send?phone=$phoneNumber';

    if (await UrlLauncher.canLaunch(url)) {
      await UrlLauncher.launch(url);

      setState(() {
        _phoneNumberSet.add(phoneNumber);
        _phoneNumberDateTimeMap[phoneNumber] = DateTime.now();
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Bad news'),
            content: Text('It seems you don\'t have WhatsApp installed.'),
            actions: [
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
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
          'Phone number $phoneNumber copied to clipboard.',
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
        content: Text(
          'Phone number $phoneNumber has been deleted.',
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
                builder: (context, snapshot) {
                  var countries = [];
                  if (snapshot.hasData)
                    countries = json.decode(snapshot.data.body);

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
                      prefixIcon: Icon(Icons.flag),
                      labelText: 'Country',
                      suffixIcon: Icon(Icons.arrow_drop_down),
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
                  labelText: 'Phone number',
                  prefixIcon: Icon(Icons.dialpad),
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
                icon: Icon(BrandIcons.whatsapp),
                label: Text('Open In WhatsApp'),
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
                child: Icon(Icons.content_copy, color: Colors.white),
                padding: EdgeInsets.only(left: 24),
              ),
              secondaryBackground: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                child: Icon(Icons.delete_outline, color: Colors.white),
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
                            // TODO
                            // ListTile(
                            //   leading: Icon(Mdi.accountPlusOutline),
                            //   title: Text('Add to contacts'),
                            //   onTap: () {
                            //     Navigator.pop(context);
                            //   },
                            // ),
                            ListTile(
                              leading: Icon(Icons.phone),
                              title: Text('Call'),
                              onTap: () async {
                                Navigator.pop(context);

                                var url = 'tel://$phoneNumber';
                                await UrlLauncher.launch(url);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.message),
                              title: Text('Send SMS message'),
                              onTap: () async {
                                Navigator.pop(context);

                                var url = 'sms://$phoneNumber';
                                await UrlLauncher.launch(url);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.content_copy),
                              title: Text('Copy'),
                              onTap: () {
                                Navigator.pop(context);

                                _copyPhoneNumber(phoneNumber);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.delete),
                              title: Text('Delete'),
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
