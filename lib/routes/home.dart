import 'dart:io';

import 'package:app_review/app_review.dart';
import 'package:click_to_chat/body.dart';
import 'package:click_to_chat/routes/unlock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';
import 'package:package_info/package_info.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

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
    final title = Text(widget.title);

    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            onSelected: (PopupMenuItemEnum choice) async {
              switch (choice) {
                case PopupMenuItemEnum.sendFeedback:
                  await UrlLauncher.launch('mailto:feedback@lorenzopieri.dev');
                  break;

                case PopupMenuItemEnum.about:
                  var packageInfo = await PackageInfo.fromPlatform();
                  showAboutDialog(
                    context: context,
                    applicationName: widget.title,
                    applicationVersion:
                        'Version ${packageInfo.version} build ${packageInfo.buildNumber}',
                    applicationLegalese: 'Made by LRNZ09',
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Text('Send feedback'),
                value: PopupMenuItemEnum.sendFeedback,
              ),
              const PopupMenuItem(
                child: Text('About'),
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
              icon: Icon(Mdi.lockOpen),
              onPressed: () {
                final route = MaterialPageRoute(builder: (context) => Unlock());
                Navigator.push(context, route);
              },
              tooltip: 'Unlock full version',
            ),
            IconButton(
              icon: Icon(Mdi.starFace),
              onPressed: () async {
                await AppReview.writeReview;
              },
              tooltip: 'Leave a review',
            ),
          ],
        ),
        notchMargin: 8,
        shape: CircularNotchedRectangle(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var url;

          if (Platform.isAndroid) {
            url =
                'https://play.google.com/store/apps/details?id=dev.lorenzopieri.clicktochat';
          } else if (Platform.isIOS) {
            url = 'https://apps.apple.com/app/id1496675283';
          }

          if (url != null) await Share.share(url);
        },
        child: Icon(Mdi.shareVariant),
        tooltip: 'Share the app',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
