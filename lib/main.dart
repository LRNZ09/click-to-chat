import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mdi/mdi.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  final title = 'Click to Chat';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('it'),
      ],
      title: title,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
      ),
      darkTheme:
          ThemeData(brightness: Brightness.dark, primarySwatch: Colors.green),
      home: Home(title: title),
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

  void _onPhoneNumberChanged(text) {
    setState(() {
      _phoneNumber = text;
    });
  }

  void _onButtonPressed() async {
    var url = 'whatsapp://send?phone=$_phoneNumber';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Bad news'),
            content: Text('It seems you don\'t have WhatsApp installed.'),
            actions: <Widget>[
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
          padding: EdgeInsets.all(16),
          children: <Widget>[
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
              onPressed: _phoneNumber.length == 0 ? null : _onButtonPressed,
            )
          ],
        ),
      ),
    );
  }
}
