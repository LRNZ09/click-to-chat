import 'package:flutter_test/flutter_test.dart';
import 'package:mdi/mdi.dart';

import 'package:click_to_chat/app.dart';

void main() {
  testWidgets('Home', (WidgetTester tester) async {
    await tester.pumpWidget(App());

    var textField = find.text('Phone number');

    expect(textField, findsOneWidget);

    var button = find.byIcon(Mdi.whatsapp);

    expect(button, findsOneWidget);

    await tester.tap(button);
    // await tester.pump();

    // TODO Verify that our button is disabled
  });
}
