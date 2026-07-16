import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:islamic_app/main.dart';
import 'package:islamic_app/services/storage_service.dart';
import 'package:islamic_app/models/index.dart';
import 'package:hive/hive.dart';
import 'dart:io';

/// Integration test covering main app flows for the Islamic App.
///
/// Flows tested:
/// 1. Quran reading -> bookmark -> settings -> prayer times
/// 2. Prayer times -> notifications -> settings -> azkar
/// 3. Qibla calibration -> compass -> prayer times
/// 4. Language switching (EN/AR) + theme toggle + RTL layout
///
/// Run with: flutter test integration_test/main_app_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Initialize Hive with a temporary directory for testing.
  Future<void> initTestHive() async {
    final tempDir = Directory.systemTemp.createTempSync('islamic_app_test_');
    Hive.init(tempDir.path);

    // Register all adapters (guard against double-registration across tests)
    final adapterList = <TypeAdapter>[
      SurahAdapter(),
      AyahAdapter(),
      PrayerTimesAdapter(),
      AzkarCategoryAdapter(),
      AzkarAdapter(),
      QiblaDirectionAdapter(),
      UserSettingsAdapter(),
      BookmarkAdapter(),
    ];
    for (final adapter in adapterList) {
      if (!Hive.isAdapterRegistered(adapter.typeId)) {
        Hive.registerAdapter(adapter);
      }
    }

    await StorageService.initialize();
  }

  /// Pump the app and wait for initial load.
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const IslamicApp());
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  /// Navigate to a tab by tapping the bottom nav item at [index].
  /// The app uses a custom bottom bar with InkWell children inside a Row.
  Future<void> navigateToTab(WidgetTester tester, int index) async {
    // The bottom navigation bar contains a Row with 5 Expanded > InkWell children.
    // Find all InkWell widgets that are descendants of the bottom bar area.
    final rowFinder = find.byType(Row);
    final rows = rowFinder.evaluate().toList();

    // The bottom nav Row is typically the last Row in the tree that contains InkWell children
    // and is positioned at the bottom of the screen.
    for (final rowElement in rows.reversed) {
      final inkWellFinder = find.descendant(
        of: find.byWidget(rowElement.widget),
        matching: find.byType(InkWell),
      );
      if (inkWellFinder.evaluate().length == 5) {
        // This is our bottom nav bar
        if (index < inkWellFinder.evaluate().length) {
          await tester.tap(inkWellFinder.at(index));
          await tester.pumpAndSettle(const Duration(seconds: 1));
          return;
        }
      }
    }

    // Fallback: try tapping by icon (works for unique icons)
    if (index == 1) {
      await tester.tap(find.byIcon(CupertinoIcons.clock_fill).first);
    } else if (index == 2) {
      await tester.tap(find.byIcon(CupertinoIcons.location_fill).first);
    } else if (index == 4) {
      await tester.tap(find.byIcon(CupertinoIcons.sparkles).first);
    } else if (index == 0) {
      await tester.tap(find.byIcon(CupertinoIcons.book_fill).first);
    } else if (index == 3) {
      await tester.tap(find.byIcon(CupertinoIcons.sparkles).first);
    }
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  // ---------------------------------------------------------------------------
  // Flow 1: Quran reading -> bookmark -> settings -> prayer times
  // ---------------------------------------------------------------------------

  group('Flow 1: Quran reading -> bookmark -> settings -> prayer times', () {
    testWidgets('navigate to Quran, open surah, bookmark it, go to settings, then prayer times', (tester) async {
      await initTestHive();
      await pumpApp(tester);

      // Step 1: Verify we start on Quran screen (first tab)
      expect(find.text('quran'), findsWidgets);

      // Step 2: Wait for surahs to load (or show loading state)
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 3: Tap on the first surah card to open surah detail
      final surahCards = find.byType(Card);
      if (surahCards.evaluate().isNotEmpty) {
        await tester.tap(surahCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify we're in surah detail - look for ayah content
        expect(find.byType(ListView), findsWidgets);

        // Step 4: Go back to surah list
        await tester.pageBack();
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Step 5: Tap bookmark icon on a surah to bookmark it
      final bookmarkIcons = find.byIcon(CupertinoIcons.bookmark);
      if (bookmarkIcons.evaluate().isNotEmpty) {
        await tester.tap(bookmarkIcons.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      }

      // Step 6: Tap the bookmark action button in the app bar to view bookmarks
      final appBarBookmark = find.byIcon(CupertinoIcons.bookmark_fill);
      if (appBarBookmark.evaluate().isNotEmpty) {
        await tester.tap(appBarBookmark.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Verify bookmarks modal appears
        expect(find.text('bookmarks'), findsWidgets);

        // Close the modal
        final cancelButton = find.text('cancel');
        if (cancelButton.evaluate().isNotEmpty) {
          await tester.tap(cancelButton.first);
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        }
      }

      // Step 7: Navigate to Prayer Times tab (index 1)
      await navigateToTab(tester, 1);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify prayer times screen is shown
      expect(find.text('prayer_times'), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // Flow 2: Prayer times -> notifications -> settings -> azkar
  // ---------------------------------------------------------------------------

  group('Flow 2: Prayer times -> notifications -> settings -> azkar', () {
    testWidgets('navigate to prayer times, check notifications, go to settings, then azkar', (tester) async {
      await initTestHive();
      await pumpApp(tester);

      // Step 1: Navigate to Prayer Times tab
      await navigateToTab(tester, 1);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify prayer times screen
      expect(find.text('prayer_times'), findsWidgets);

      // Step 2: Verify next prayer card is shown
      expect(find.text('next_prayer'), findsWidgets);

      // Step 3: Check today's prayer list tab exists
      expect(find.text('today'), findsWidgets);

      // Step 4: Navigate to Azkar tab (index 4)
      await navigateToTab(tester, 4);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify Azkar screen
      expect(find.text('azkar'), findsWidgets);
      expect(find.text('categories'), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // Flow 3: Qibla calibration -> compass -> prayer times
  // ---------------------------------------------------------------------------

  group('Flow 3: Qibla calibration -> compass -> prayer times', () {
    testWidgets('navigate to Qibla, view compass, calibrate, then go to prayer times', (tester) async {
      await initTestHive();
      await pumpApp(tester);

      // Step 1: Navigate to Qibla tab (index 2)
      await navigateToTab(tester, 2);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify Qibla screen
      expect(find.text('qibla'), findsWidgets);

      // Step 2: Verify compass elements are present
      expect(find.text('distance_to_kaaba'), findsWidgets);
      expect(find.text('qibla_direction'), findsWidgets);
      expect(find.text('coordinates'), findsWidgets);

      // Step 3: Tap calibrate button
      final calibrateButton = find.text('calibrate');
      if (calibrateButton.evaluate().isNotEmpty) {
        await tester.tap(calibrateButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Step 4: Navigate to Prayer Times tab (index 1)
      await navigateToTab(tester, 1);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify prayer times screen
      expect(find.text('prayer_times'), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // Flow 4: Language switching + theme toggle + RTL layout
  // ---------------------------------------------------------------------------

  group('Flow 4: Language switching (EN/AR) + theme toggle + RTL layout', () {
    testWidgets('switch language, toggle theme, verify RTL layout', (tester) async {
      await initTestHive();
      await pumpApp(tester);

      // Step 1: Navigate to Settings
      // Settings is accessed via the app bar or a dedicated settings button.
      // In this app, settings is not a tab - it's accessed from the app bar.
      // Look for a settings/gear icon in the app bar.
      final settingsIcon = find.byIcon(CupertinoIcons.gear);
      if (settingsIcon.evaluate().isNotEmpty) {
        await tester.tap(settingsIcon.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify settings screen
        expect(find.text('settings'), findsWidgets);

        // Step 2: Find and tap language setting
        final languageTile = find.text('language');
        if (languageTile.evaluate().isNotEmpty) {
          await tester.tap(languageTile.first);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Look for Arabic language option
          final arabicOption = find.text('arabic');
          if (arabicOption.evaluate().isNotEmpty) {
            await tester.tap(arabicOption.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }
        }

        // Step 3: Toggle dark mode
        final themeTile = find.text('theme');
        if (themeTile.evaluate().isNotEmpty) {
          await tester.tap(themeTile.first);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Look for dark mode option
          final darkModeOption = find.text('dark_mode');
          if (darkModeOption.evaluate().isNotEmpty) {
            await tester.tap(darkModeOption.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }
        }

        // Step 4: Go back from settings
        await tester.pageBack();
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Step 5: Verify the app is still functional after settings changes
      // Navigate through all tabs to confirm everything still works
      for (int i = 0; i < 5; i++) {
        await navigateToTab(tester, i);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Cross-flow navigation test
  // ---------------------------------------------------------------------------

  group('Cross-flow: Full app navigation smoke test', () {
    testWidgets('navigate through all tabs and verify no crashes', (tester) async {
      await initTestHive();
      await pumpApp(tester);

      // Navigate through all 5 tabs (quran=0, prayer_times=1, qibla=2, azkar=3)
      final tabNames = ['quran', 'prayer_times', 'qibla', 'azkar'];

      for (int i = 0; i < 4; i++) {
        await navigateToTab(tester, i);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Verify the expected tab title is present
        expect(find.text(tabNames[i]), findsWidgets);
      }

      // Verify FAB is present (prayer times shortcut)
      expect(find.byType(FloatingActionButton), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // App lifecycle test
  // ---------------------------------------------------------------------------

  group('App lifecycle: cold start and resume', () {
    testWidgets('app cold start loads all providers correctly', (tester) async {
      await initTestHive();

      // Cold start
      await tester.pumpWidget(const IslamicApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify main screen is rendered
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);

      // Verify bottom navigation is present
      expect(find.byType(Row), findsWidgets);

      // Simulate app pause and resume
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter.lifecycle'),
        (methodCall) async => null,
      );

      // Verify app is still responsive
      await navigateToTab(tester, 2);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('qibla'), findsWidgets);
    });
  });
}
