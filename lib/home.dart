import 'package:app_review/app_review.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

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
        actions: [
          PopupMenuButton(
            onSelected: (PopupMenuItemEnum choice) async {
              switch (choice) {
                case PopupMenuItemEnum.sendFeedback:
                  await launch('mailto:feedback@lorenzopieri.dev');
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          var result = await AppReview.storeListing;
          // TODO
          print(result);
        },
        icon: Icon(Icons.star),
        label: Text('Rate me'),
      ),
    );
  }
}
