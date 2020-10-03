import 'dart:io';

import 'package:app_review/app_review.dart';
import 'package:click_to_chat/app_localizations.dart';
import 'package:click_to_chat/routes/home/body.dart';
import 'package:click_to_chat/routes/unlock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';
import 'package:package_info/package_info.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

enum PopupMenuItemEnum { about, sendFeedback }

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final title = Text(
      widget.title,
      // Provide a Key to this specific Text widget. This allows
      // identifing the widget from inside the test suite,
      // and reading the text.
      key: Key('title'),
    );

    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            onSelected: (PopupMenuItemEnum choice) async {
              switch (choice) {
                case PopupMenuItemEnum.sendFeedback:
                  await url_launcher.launch('mailto:feedback@lorenzopieri.dev');
                  break;

                case PopupMenuItemEnum.about:
                  var packageInfo = await PackageInfo.fromPlatform();
                  showAboutDialog(
                    context: context,
                    applicationIcon: Image.asset(
                      'assets/icons/icon-android.png',
                      height: 52,
                      width: 52,
                    ),
                    applicationName: widget.title,
                    applicationVersion:
                        'Version ${packageInfo.version} build ${packageInfo.buildNumber}',
                    applicationLegalese:
                        AppLocalizations.of(context).appLegalese,
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text(AppLocalizations.of(context).sendFeedback),
                value: PopupMenuItemEnum.sendFeedback,
              ),
              PopupMenuItem(
                child: Text(AppLocalizations.of(context).about),
                value: PopupMenuItemEnum.about,
              ),
            ],
          ),
        ],
        title: title,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Body(),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Mdi.star),
              onPressed: () async {
                await AppReview.requestReview;
              },
              tooltip: AppLocalizations.of(context).rate,
            ),
            IconButton(
              icon: Icon(Mdi.shareVariant),
              onPressed: () async {
                var url;

                if (Platform.isAndroid) {
                  url =
                      'https://play.google.com/store/apps/details?id=dev.lorenzopieri.clicktochat';
                } else if (Platform.isIOS) {
                  url = 'https://apps.apple.com/app/id1496675283';
                }

                if (url != null) await Share.share(url, subject: widget.title);
              },
              tooltip: AppLocalizations.of(context).share,
            ),
          ],
        ),
        notchMargin: 8,
        shape: CircularNotchedRectangle(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Mdi.emoticonHappy),
        onPressed: () async {
          final route = MaterialPageRoute(builder: (context) => Unlock());
          await Navigator.push(context, route);
        },
        tooltip: AppLocalizations.of(context).unlock,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
