import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mdi/mdi.dart';

import 'package:click_to_chat/app.dart';
import 'package:click_to_chat/routes/home/body.dart';

class MockAdapter extends HttpClientAdapter {
  final _adapter = DefaultHttpClientAdapter();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>> requestStream,
    Future cancelFuture,
  ) async {
    switch (options.path) {
      case '/all':
        return ResponseBody.fromString(
          '[{"alpha2Code":"US","callingCodes":["1"],"nativeName":"United States"}]',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      case '/alpha/US':
        return ResponseBody.fromString(
          '{"alpha2Code":"US","callingCodes":["1"],"nativeName":"United States"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      default:
        return ResponseBody.fromString('', 204);
    }
  }

  @override
  void close({bool force = false}) {
    _adapter.close(force: force);
  }
}

void main() {
  setUpAll(() {
    countriesDio.httpClientAdapter = MockAdapter();
  });

  group('App', () {
    testWidgets('widgets', (tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      expect(find.text('Country'), findsOneWidget);
      expect(find.text('Phone number'), findsOneWidget);
      expect(find.byIcon(Mdi.whatsapp), findsOneWidget);
      expect(find.byIcon(Mdi.star), findsOneWidget);
      expect(find.byIcon(Mdi.shareVariant), findsOneWidget);
      expect(find.byIcon(Mdi.emoticonHappy), findsOneWidget);

      // TODO Verify that our button is disabled
      // await tester.tap(button);
      // await tester.pump();
    });

    testGoldens('devices', (tester) async {
      await tester.pumpWidgetBuilder(App());

      await multiScreenGolden(tester, 'app', devices: [
        Device.phone,
        Device.phone.dark(),
        Device.tabletPortrait,
        Device.tabletPortrait.dark(),
        Device.tabletLandscape,
        Device.tabletLandscape.dark(),
      ]);
    });
  });
}
