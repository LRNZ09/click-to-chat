import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mdi/mdi.dart';
import 'package:nock/nock.dart';

import 'package:click_to_chat/app.dart';

final COUNTRIES_BASE_URL = 'https://restcountries.eu/rest/v2';
final COUNTRY_CODE = 'US';
final COUNTRY_PARAMS = '?fields=alpha2Code;callingCodes;nativeName';

void main() {
  setUpAll(() {
    nock.init();
  });

  setUp(() {
    nock.cleanAll();
  });

  group('App', () {
    setUp(() {
      final countriesScope = nock(COUNTRIES_BASE_URL);

      final allCountriesPath = '/all$COUNTRY_PARAMS';
      countriesScope.get(allCountriesPath)..replay(200, '[]');

      final phoneCountryPath = '/alpha/$COUNTRY_CODE$COUNTRY_PARAMS';
      countriesScope.get(phoneCountryPath)
        ..replay(
          200,
          '{"alpha2Code":"US","callingCodes":["1"],"nativeName":"United States"}',
        );
    });

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
        Device.tabletLandscape,
      ]);
    });
  });
}
