import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mdi/mdi.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  final title = 'Click to Chat';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: Home(title: title),
      localizationsDelegates: [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('it'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
      ),
      title: title,
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _phoneNumberMaxLength = 15;

  var _phoneNumber = '';
  var _phoneNumberSet = Set();
  var _phoneNumberDateTimeMap = {};

  void _onPhoneNumberChanged(text) {
    setState(() {
      _phoneNumber = text;
    });
  }

  void _onListTileTap(phoneNumber) async {
    var url = 'whatsapp://send?phone=$phoneNumber';

    if (await canLaunch(url)) {
      await launch(url);

      setState(() {
        _phoneNumberSet.add(phoneNumber);
        _phoneNumberDateTimeMap[phoneNumber] = DateTime.now();
      });
    } else {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Bad news'),
            content: Text('It seems you don\'t have WhatsApp installed.'),
            actions: [
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _onButtonPressed() {
    _onListTileTap(_phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: ListView(
          padding: EdgeInsets.only(bottom: 240),
          children: [
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      errorText: _phoneNumber.length > _phoneNumberMaxLength
                          ? 'Are you sure this phone number is correct?'
                          : null,
                      filled: true,
                      helperText:
                          'Enter the country prefix with or without the + sign',
                      labelText: 'Phone number',
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
                    label: Text('Open In WhatsApp'),
                    onPressed:
                        _phoneNumber.length == 0 ? null : _onButtonPressed,
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

                return ListTile(
                  onTap: () {
                    _onListTileTap(phoneNumber);
                  },
                  onLongPress: () async {
                    await Clipboard.setData(ClipboardData(text: phoneNumber));

                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Phone number $phoneNumber copied to clipboard.',
                        ),
                      ),
                    );
                  },
                  title: Text(phoneNumber),
                  subtitle: Text(phoneNumberDateTime),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
