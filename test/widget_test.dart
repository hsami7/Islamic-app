// This is a basic Flutter widget test.
////
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:islamic_app/screens/main_screen.dart';
import 'package:islamic_app/providers/index.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Test the MainScreen with required providers (no Hive init needed)
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => QuranProvider()),
          ChangeNotifierProvider(create: (_) => PrayerTimesProvider()),
          ChangeNotifierProvider(create: (_) => QiblaProvider()),
          ChangeNotifierProvider(create: (_) => AzkarProvider()),
        ],
        child: const MaterialApp(
          home: MainScreen(),
        ),
      ),
    );

    // Pump initial frame
    await tester.pump();

    // Verify the app loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
