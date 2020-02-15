import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import 'body.dart';

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
        // TODO
        // leading: IconButton(
        //   icon: Icon(Icons.settings),
        //   onPressed: () {},
        // ),
        actions: [
          PopupMenuButton(
            onSelected: (PopupMenuItemEnum choice) async {
              switch (choice) {
                case PopupMenuItemEnum.sendFeedback:
                  await UrlLauncher.launch('mailto:feedback@lorenzopieri.dev');
                  break;

                case PopupMenuItemEnum.about:
                  var packageInfo = await PackageInfo.fromPlatform();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(widget.title),
                        content: Text(
                          'Version ${packageInfo.version} build ${packageInfo.buildNumber}',
                        ),
                      );
                    },
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
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Body(),
      ),
      // ? WIP
      // bottomNavigationBar: BottomAppBar(
      //   shape: AutomaticNotchedShape(
      //     RoundedRectangleBorder(),
      //     StadiumBorder(
      //       side: BorderSide(),
      //     ),
      //   ),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     mainAxisSize: MainAxisSize.max,
      //     children: [
      //       IconButton(
      //         icon: Icon(
      //           Icons.settings,
      //         ),
      //         onPressed: () {},
      //       ),
      //       IconButton(
      //         icon: Icon(
      //           Icons.share,
      //         ),
      //         onPressed: () {},
      //       ),
      //     ],
      //   ),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var url;
          if (defaultTargetPlatform == TargetPlatform.iOS) {
            url = 'https://apps.apple.com/app/id1496675283';
          } else {
            url =
                'https://play.google.com/store/apps/details?id=dev.lorenzopieri.clicktochat';
          }
          await Share.share(url);
        },
        child: Icon(Icons.share),
        tooltip: 'Share this app',
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
