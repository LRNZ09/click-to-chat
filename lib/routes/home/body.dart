import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../../utils/country.dart';

final countriesDio = Dio(
  BaseOptions(
    baseUrl: 'https://restcountries.com/v3.1/',
    receiveTimeout: 5000,
  ),
);
// ..interceptors.add(
//     DioCacheManager(
//       CacheConfig(
//         defaultMaxStale: Duration(days: 7),
//       ),
//     ).interceptor,
//   );

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  static const _phoneNumberMaxLength = 16;

  final _countriesCancelToken = CancelToken();
  final _phoneNumberSet = <String>{};
  final _phoneNumberDateTimeMap = {};

  late Future<Response> _countriesFuture;
  Country? _phoneNumberCountry;

  var _phoneNumber = '';
  var _message = '';

  @override
  void initState() {
    super.initState();

    _countriesFuture = countriesDio.get(
      '/all',
      cancelToken: _countriesCancelToken,
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

    Map<String, dynamic>? simCountryMap;
    try {
      var shouldAskPermission = true;

      if (await Permission.phone.shouldShowRequestRationale) {
        shouldAskPermission = await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
            content: const Text(
              'Phone permission is required in order to get the country from your SIM card, otherwise the one of your locale will be used in its place',
            ),
            actions: [
              FlatButton(
                child: Text(AppLocalizations.of(context)!.notNow),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              FlatButton(
                child: const Text('OK'),
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
          // TODO: get sim country
          // final simCountryCode = await SimInfo.getIsoCountryCode;
          // if (simCountryCode.isNotEmpty) countryCode = simCountryCode;
        }
      }

      if (countryCode == null) {
        final response = await countriesDio.get(
          '/lang/${locale.languageCode}',
          cancelToken: _countriesCancelToken,
        );
        simCountryMap = response.data[0];
      } else {
        final response = await countriesDio.get(
          '/alpha/$countryCode',
          cancelToken: _countriesCancelToken,
        );
        simCountryMap = response.data[0];
      }
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'An error occurred while trying to get your country info',
          ),
        ),
      );
    }

    final simCountry = simCountryMap == null
        ? const Country(
            callingCode: '1',
            code: '840',
            flag: '🇺🇸',
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
          title: Text(AppLocalizations.of(context)!.badNews),
          content: const Text(
            'It seems you don\'t have WhatsApp installed, try installing it from the store.',
          ),
          actions: [
            FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: const Text('OK'),
              onPressed: () async {
                Navigator.pop(context);

                try {
                  // TODO: Add a redirect to the store
                  // await StoreRedirect.redirect(
                  //   androidAppId: 'com.whatsapp',
                  //   iOSAppId: '310633997',
                  // );
                } on dynamic {}
              },
            ),
          ],
        ),
      );
    }
  }

  void _onButtonPressed() {
    var fullPhoneNumber = '${_phoneNumberCountry?.callingCode}$_phoneNumber';
    _onListTileTap(fullPhoneNumber, _message);
  }

  void _copyPhoneNumber(String phoneNumber) async {
    var text = '+$phoneNumber';
    var data = ClipboardData(text: text);
    await Clipboard.setData(data);

    ScaffoldMessenger.of(context).showSnackBar(
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: SnackBarAction(
          label: (AppLocalizations.of(context)!.undo).toUpperCase(),
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
      padding: const EdgeInsets.only(bottom: 240),
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              FutureBuilder(
                future: _countriesFuture,
                builder: (context, AsyncSnapshot<Response> snapshot) {
                  var countries = [];
                  if (snapshot.hasData) countries = snapshot.data!.data;

                  var items = countries
                      .map((countryMap) => Country.fromJson(countryMap))
                      .where((country) => country.callingCode.isNotEmpty)
                      .map(
                        (country) => DropdownMenuItem(
                          key: ValueKey(country),
                          value: country,
                          child: Text('${country.flag}  ${country.nativeName}'),
                        ),
                      )
                      .toList();

                  return InputDecorator(
                    decoration: InputDecoration(
                      errorText: snapshot.error?.toString(),
                      filled: true,
                      prefixIcon: const Icon(Icons.flag),
                      labelText: AppLocalizations.of(context)!.country,
                      suffixIcon: snapshot.hasData
                          ? const Icon(Icons.arrow_drop_down)
                          : snapshot.hasError
                              ? IconButton(
                                  icon: const Icon(Icons.warning),
                                  onPressed: () {
                                    setState(() {
                                      _countriesFuture = countriesDio.get(
                                        '/all',
                                        cancelToken: _countriesCancelToken,
                                      );
                                    });
                                  },
                                  tooltip: ' Retry',
                                )
                              : null,
                    ),
                    isEmpty: _phoneNumberCountry == null,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        iconSize: 0,
                        value: _phoneNumberCountry,
                        isDense: true,
                        isExpanded: true,
                        onChanged: (Country? value) {
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
              const SizedBox(
                height: 16,
              ),
              TextField(
                maxLengthEnforcement: MaxLengthEnforcement.none,
                decoration: InputDecoration(
                  prefixText: _phoneNumberCountry?.callingCode ?? '',
                  errorText: _phoneNumber.length > _phoneNumberMaxLength
                      ? 'Are you sure this phone number is correct?'
                      : null,
                  filled: true,
                  labelText: AppLocalizations.of(context)!.phoneNumber,
                  prefixIcon: const Icon(Icons.dialpad),
                ),
                keyboardType: TextInputType.phone,
                maxLength: _phoneNumberMaxLength,
                onChanged: _onPhoneNumberChanged,
              ),
              const SizedBox(
                height: 16,
              ),
              ConstrainedBox(
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    labelText: AppLocalizations.of(context)!.message,
                    prefixIcon: const Icon(Icons.message),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  onChanged: _onMessageChanged,
                ),
                constraints: const BoxConstraints(maxHeight: 120),
              ),
              const SizedBox(
                height: 24,
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.whatsapp),
                label: Text(AppLocalizations.of(context)!.homeOpenButton),
                onPressed: _phoneNumber.isEmpty ? null : _onButtonPressed,
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
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
                child: const Icon(Icons.copy, color: Colors.white),
                padding: const EdgeInsets.only(left: 24),
              ),
              secondaryBackground: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                child: const Icon(Icons.delete, color: Colors.white),
                padding: const EdgeInsets.only(right: 24),
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
                              leading: const Icon(Icons.share),
                              title: Text(AppLocalizations.of(context)!.share),
                              onTap: () async {
                                Navigator.pop(context);

                                var url = 'https://wa.me/$phoneNumber';
                                // TODO: Add share functionality
                                // await Share.share(url);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.phone),
                              title: Text(AppLocalizations.of(context)!.call),
                              onTap: () async {
                                Navigator.pop(context);

                                var url = 'tel://+$phoneNumber';
                                await url_launcher.launch(url);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.message),
                              title: Text(
                                AppLocalizations.of(context)!.sendSmsMessage,
                              ),
                              onTap: () async {
                                Navigator.pop(context);

                                var url = 'sms://+$phoneNumber';
                                await url_launcher.launch(url);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.copy),
                              title: Text(AppLocalizations.of(context)!.copy),
                              onTap: () {
                                Navigator.pop(context);

                                _copyPhoneNumber(phoneNumber);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.delete),
                              title: Text(AppLocalizations.of(context)!.delete),
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
