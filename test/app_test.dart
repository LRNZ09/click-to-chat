import 'package:charlatan/charlatan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:click_to_chat/app.dart';
import 'package:click_to_chat/routes/home/body.dart';

final testCountry = {
  "alpha2Code": "TC",
  "callingCodes": ["42"],
  "nativeName": "Test Country"
};

final charlatan = Charlatan()
  ..whenGet(
    '/all',
    (req) => [testCountry],
  )
  ..whenGet(
    '/alpha/TC',
    (request) => testCountry,
  );

void main() {
  setUpAll(() {
    countriesDio.httpClientAdapter = charlatan.toFakeHttpClientAdapter();
  });

  group('App', () {
    testWidgets('should display the title', (tester) async {
      // load the PlantsApp widget
      await tester.pumpWidget(const App());

      // wait for data to load
      await tester.pumpAndSettle();

      // Find widget with 'Click to Chat' text
      final finder = find.text('Click to Chat');

      // Check if widget is displayed
      expect(finder, findsOneWidget);
    });

    testWidgets('should display country placeholder', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      expect(find.text('Country'), findsOneWidget);
    });

    testWidgets('should display phone number placeholder', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      expect(find.text('Phone number'), findsOneWidget);
    });

    testWidgets('should display WhatsApp icon', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.whatsapp), findsOneWidget);
    });

    testWidgets('should display star icon', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('should display share icon', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.share), findsOneWidget);
    });
  });
}
