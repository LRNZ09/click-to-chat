import 'package:flutter_test/flutter_test.dart';
// import 'package:mdi/mdi.dart';

import 'package:click_to_chat/app.dart';

void main() {
  testWidgets('App', (WidgetTester tester) async {
    await tester.pumpWidget(App());

    var countryField = find.text('Country');
    expect(countryField, findsOneWidget);

    var phoneNumberField = find.text('Phone number');
    expect(phoneNumberField, findsOneWidget);

    // ! FIXME Test is failing on Codemagic
    // var button = find.byIcon(Mdi.whatsapp);
    // expect(button, findsOneWidget);

    // TODO Verify that our button is disabled
    // await tester.tap(button);
    // await tester.pump();

    // var shareFab = find.byIcon(Mdi.shareVariant);
    // expect(shareFab, findsOneWidget);
  });
}
