import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mdi/mdi.dart';
import 'package:url_launcher/url_launcher.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

enum PopupMenuItemEnum { about, sendFeedback }

class _BodyState extends State<Body> {
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
    if (phoneNumber.isEmpty) return;

    var url = 'whatsapp://send?phone=$phoneNumber';

    if (await canLaunch(url)) {
      await launch(url);

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

  void _copyPhoneNumber(String phoneNumber) async {
    await Clipboard.setData(ClipboardData(text: phoneNumber));

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
              TextField(
                autofocus: true,
                decoration: InputDecoration(
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
                child: Icon(Mdi.deleteOutline, color: Colors.white),
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
                              leading: Icon(Mdi.accountPlusOutline),
                              title: Text('Add to contacts'),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: Icon(Mdi.contentCopy),
                              title: Text('Copy'),
                              onTap: () {
                                Navigator.pop(context);

                                _copyPhoneNumber(phoneNumber);
                              },
                            ),
                            ListTile(
                              leading: Icon(Mdi.deleteOutline),
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