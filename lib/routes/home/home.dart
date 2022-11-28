import 'dart:io';

import 'package:app_review/app_review.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../../routes/home/body.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

enum _PopupMenuItemEnum { about, sendFeedback }

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final title = Text(
      widget.title,
      // Provide a Key to this specific Text widget. This allows
      // identifying the widget from inside the test suite,
      // and reading the text.
      key: const Key('title'),
    );

    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            onSelected: (choice) async {
              switch (choice) {
                case _PopupMenuItemEnum.sendFeedback:
                  await url_launcher.launch('mailto:feedback@lorenzopieri.dev');
                  break;

                case _PopupMenuItemEnum.about:
                  showAboutDialog(
                    context: context,
                    applicationIcon: Image.asset(
                      'assets/icons/icon-android.png',
                      height: 52,
                      width: 52,
                    ),
                    applicationName: widget.title,
                    applicationVersion: '42',
                    // TODO: Get version from package info
                    // applicationVersion:
                    //     'Version ${packageInfo.version} build ${packageInfo.buildNumber}',
                    applicationLegalese:
                        AppLocalizations.of(context)!.appLegalese,
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text(AppLocalizations.of(context)!.sendFeedback),
                value: _PopupMenuItemEnum.sendFeedback,
              ),
              PopupMenuItem(
                child: Text(AppLocalizations.of(context)!.about),
                value: _PopupMenuItemEnum.about,
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
              icon: const Icon(Icons.star),
              onPressed: () async {
                await AppReview.requestReview;
              },
              tooltip: AppLocalizations.of(context)!.rate,
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () async {
                var url;

                if (Platform.isAndroid) {
                  url =
                      'https://play.google.com/store/apps/details?id=dev.lorenzopieri.clicktochat';
                } else if (Platform.isIOS) {
                  url = 'https://apps.apple.com/app/id1496675283';
                }

                // TODO: Add share functionality
                // if (url != null) await Share.share(url, subject: widget.title);
              },
              tooltip: AppLocalizations.of(context)!.share,
            ),
          ],
        ),
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
