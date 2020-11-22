import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mdi/mdi.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:sim_info/sim_info.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

final countriesDio = Dio(
  BaseOptions(
    baseUrl: 'https://restcountries.eu/rest/v2',
    receiveTimeout: 5000,
  ),
)..interceptors.add(
    DioCacheManager(
      CacheConfig(
        defaultMaxStale: Duration(days: 7),
      ),
    ).interceptor,
  );

@immutable
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
  bool operator ==(dynamic other) =>
      (other is Country && other.alpha2Code == alpha2Code);
}

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  static final _phoneNumberMaxLength = 16;

  final _countriesCancelToken = CancelToken();
  final _phoneNumberSet = <String>{};
  final _phoneNumberDateTimeMap = {};

  Future<Response> _countriesFuture;
  Country _phoneNumberCountry;

  var _phoneNumber = '';
  var _message = '';

  @override
  void initState() {
    super.initState();

    _countriesFuture = countriesDio.get(
      '/all',
      cancelToken: _countriesCancelToken,
      queryParameters: {
        'fields': 'alpha2Code;callingCodes;nativeName',
      },
    );
  }

  @override
  void didChangeDependencies() {
    _initPhoneNumberCountry();

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _countriesCancelToken.cancel('dispose');

    super.dispose();
  }

  void _initPhoneNumberCountry() async {
    if (_phoneNumberCountry != null) return;

    final locale = Localizations.localeOf(context);
    var countryCode = locale.countryCode;

    Map<String, dynamic> simCountryMap;
    try {
      var shouldAskPermission = true;

      if (await Permission.phone.shouldShowRequestRationale) {
        shouldAskPermission = await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
            content: Text(
              'Phone permission is required in order to get the country from your SIM card, otherwise the one of your locale will be used in its place',
            ),
            actions: [
              FlatButton(
                child: Text(AppLocalizations.of(context).notNow),
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

      if (countryCode == null) {
        final response = await countriesDio.get(
          '/lang/${locale.languageCode}',
          cancelToken: _countriesCancelToken,
          queryParameters: {
            'fields': 'alpha2Code;callingCodes;nativeName',
          },
        );
        simCountryMap = response.data[0];
      } else {
        final response = await countriesDio.get(
          '/alpha/$countryCode',
          cancelToken: _countriesCancelToken,
          queryParameters: {
            'fields': 'alpha2Code;callingCodes;nativeName',
          },
        );
        simCountryMap = response.data;
      }
    } on dynamic {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An error occurred while trying to get your country info',
          ),
        ),
      );
    }

    final simCountry = simCountryMap == null
        ? Country(
            alpha2Code: 'US',
            callingCode: '1',
            nativeName: 'United States',
          )
        : Country.fromJson(simCountryMap);

    setState(() {
      _phoneNumberCountry = simCountry;
    });
  }

  void _onPhoneNumberChanged(text) {
    setState(() {
      _phoneNumber = text;
    });
  }

  void _onListTileTap(String phoneNumber, [String message = '']) async {
    var url = 'whatsapp://send?phone=$phoneNumber&text=$message';

    if (await url_launcher.canLaunch(url)) {
      await url_launcher.launch(url);

      setState(() {
        _phoneNumberSet.add(phoneNumber);
        _phoneNumberDateTimeMap[phoneNumber] = DateTime.now();
      });
    } else {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
                Navigator.pop(context);

                try {
                  await StoreRedirect.redirect(
                    androidAppId: 'com.whatsapp',
                    iOSAppId: '310633997',
                  );
                } on dynamic {}
              },
            ),
          ],
        ),
      );
    }
  }

  void _onButtonPressed() {
    var fullPhoneNumber = '${_phoneNumberCountry.callingCode}$_phoneNumber';
    _onListTileTap(fullPhoneNumber, _message);
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
                // ignore: avoid_types_on_closure_parameters
                builder: (context, AsyncSnapshot<Response> snapshot) {
                  var countries = [];
                  if (snapshot.hasData) countries = snapshot.data.data;

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
                                  _countriesFuture = countriesDio.get(
                                    '/all',
                                    cancelToken: _countriesCancelToken,
                                    queryParameters: {
                                      'fields':
                                          'alpha2Code;callingCodes;nativeName',
                                    },
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
                height: 16,
              ),
              ConstrainedBox(
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    labelText: AppLocalizations.of(context).message,
                    prefixIcon: Icon(Mdi.messageText),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  onChanged: _onMessageChanged,
                ),
                constraints: BoxConstraints(maxHeight: 120),
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
                    builder: (context) {
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

  void _onMessageChanged(String value) {
    setState(() {
      _message = value;
    });
  }
}
