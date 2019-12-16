import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final title = 'WhosApp';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
      ),
      darkTheme:
          ThemeData(brightness: Brightness.dark, primarySwatch: Colors.green),
      home: MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _phoneNumber = '';

  void _onPhoneNumberChanged(text) {
    _phoneNumber = text;
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
            title: Text('Nope'),
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
        behavior: HitTestBehavior.opaque,
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
                filled: true,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                helperText: 'Make sure to enter the country prefix too',
                labelText: 'Phone number',
                prefixIcon: Icon(Mdi.dialpad),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 15,
              maxLengthEnforced: false,
              onChanged: _onPhoneNumberChanged,
            ),
            SizedBox(
              height: 24,
            ),
            RaisedButton.icon(
              icon: Icon(Mdi.whatsapp),
              label: Text('Open In WhatsApp'),
              onPressed: _onButtonPressed,
            )
          ],
        ),
      ),
    );
  }
}
