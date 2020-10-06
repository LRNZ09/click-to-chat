import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> main(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fontManifest = await rootBundle.loadString(
    'FontManifest.json',
  );
  final fonts = json.decode(fontManifest);

  for (final Map<String, dynamic> font in fonts) {
    final fontLoader = FontLoader(font['family']);
    for (final Map<String, dynamic> fontType in font['fonts']) {
      fontLoader.addFont(rootBundle.load(fontType['asset']));
    }
    await fontLoader.load();
  }

  return testMain();
}
