import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_design.dart';

/// Light theme following Apple HIG with Islamic Green accents
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  // Color scheme
  colorScheme: const ColorScheme.light(
    primary: IslamicColors.primaryGreen,
    onPrimary: Colors.white,
    primaryContainer: IslamicColors.secondaryGreen,
    onPrimaryContainer: IslamicColors.primaryGreenDark,
    secondary: IslamicColors.accentGold,
    onSecondary: Colors.white,
    secondaryContainer: IslamicColors.accentGoldLight,
    onSecondaryContainer: IslamicColors.labelPrimary,
    tertiary: IslamicColors.prayerBlue,
    onTertiary: Colors.white,
    error: IslamicColors.azkarRed,
    onError: Colors.white,
    surface: IslamicColors.systemBackground,
    onSurface: IslamicColors.labelPrimary,
    surfaceContainerHighest: IslamicColors.tertiarySystemBackground,
    onSurfaceVariant: IslamicColors.labelSecondary,
    outline: IslamicColors.separator,
    outlineVariant: IslamicColors.opaqueSeparator,
    shadow: IslamicColors.labelPrimary,
    scrim: IslamicColors.labelPrimary,
    inverseSurface: IslamicColors.darkSystemBackground,
    onInverseSurface: IslamicColors.darkLabelPrimary,
    inversePrimary: IslamicColors.darkPrimaryGreen,
  ),

  // Typography - SF Pro for English, Amiri for Arabic
  textTheme: const TextTheme(
    displayLarge: IslamicTextStyles.displayLarge,
    displayMedium: IslamicTextStyles.displayMedium,
    displaySmall: IslamicTextStyles.displaySmall,
    headlineLarge: IslamicTextStyles.headlineLarge,
    headlineMedium: IslamicTextStyles.headlineMedium,
    headlineSmall: IslamicTextStyles.headlineSmall,
    titleLarge: IslamicTextStyles.titleLarge,
    titleMedium: IslamicTextStyles.titleMedium,
    titleSmall: IslamicTextStyles.titleSmall,
    bodyLarge: IslamicTextStyles.bodyLarge,
    bodyMedium: IslamicTextStyles.bodyMedium,
    bodySmall: IslamicTextStyles.bodySmall,
    labelLarge: IslamicTextStyles.labelLarge,
    labelMedium: IslamicTextStyles.labelMedium,
    labelSmall: IslamicTextStyles.labelSmall,
  ).apply(
    bodyColor: IslamicColors.labelPrimary,
    displayColor: IslamicColors.labelPrimary,
  ),

  // Scaffold
  scaffoldBackgroundColor: IslamicColors.systemGroupedBackground,

  // App bar - Cupertino style
  appBarTheme: const AppBarTheme(
    backgroundColor: IslamicColors.systemBackground,
    foregroundColor: IslamicColors.labelPrimary,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 1,
    shadowColor: IslamicColors.separator,
    titleTextStyle: IslamicTextStyles.titleLarge,
    toolbarTextStyle: IslamicTextStyles.bodyMedium,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    centerTitle: true,
  ),

  // Card theme
  cardTheme: CardThemeData(
    color: IslamicColors.systemBackground,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shadowColor: IslamicColors.labelPrimary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(IslamicRadius.lg),
      side: const BorderSide(color: IslamicColors.separator, width: 0.5),
    ),
    margin: const EdgeInsets.all(IslamicSpacing.sm),
  ),

  // Elevated button
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: IslamicColors.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: IslamicSpacing.lg,
        vertical: IslamicSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IslamicRadius.md),
      ),
      textStyle: IslamicTextStyles.labelLarge,
      minimumSize: const Size(double.infinity, 50),
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.pressed)) {
            return IslamicColors.primaryGreenDark.withValues(alpha: 0.3);
          }
          if (states.contains(WidgetState.hovered)) {
            return IslamicColors.primaryGreenLight.withValues(alpha: 0.2);
          }
          return null;
        },
      ),
    ),
  ),

  // Outlined button
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: IslamicColors.primaryGreen,
      side: const BorderSide(color: IslamicColors.primaryGreen, width: 1.5),
      padding: const EdgeInsets.symmetric(
        horizontal: IslamicSpacing.lg,
        vertical: IslamicSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IslamicRadius.md),
      ),
      textStyle: IslamicTextStyles.labelLarge,
      minimumSize: const Size(double.infinity, 50),
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.pressed)) {
            return IslamicColors.secondaryGreen;
          }
          if (states.contains(WidgetState.hovered)) {
            return IslamicColors.secondaryGreen.withValues(alpha: 0.5);
          }
          return null;
        },
      ),
    ),
  ),

  // Text button
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: IslamicColors.primaryGreen,
      padding: const EdgeInsets.symmetric(
        horizontal: IslamicSpacing.md,
        vertical: IslamicSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IslamicRadius.sm),
      ),
      textStyle: IslamicTextStyles.labelLarge,
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.pressed)) {
            return IslamicColors.secondaryGreen;
          }
          return null;
        },
      ),
    ),
  ),

  // Input decoration
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: IslamicColors.secondarySystemBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(IslamicRadius.md),
      borderSide: const BorderSide(color: IslamicColors.separator, width: 0.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(IslamicRadius.md),
      borderSide: const BorderSide(color: IslamicColors.separator, width: 0.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(IslamicRadius.md),
      borderSide: const BorderSide(color: IslamicColors.primaryGreen, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(IslamicRadius.md),
      borderSide: const BorderSide(color: IslamicColors.azkarRed, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: IslamicSpacing.md,
      vertical: IslamicSpacing.md,
    ),
    labelStyle: IslamicTextStyles.bodyMedium.copyWith(
      color: IslamicColors.labelSecondary,
    ),
    hintStyle: IslamicTextStyles.bodyMedium.copyWith(
      color: IslamicColors.labelTertiary,
    ),
    errorStyle: IslamicTextStyles.bodySmall.copyWith(
      color: IslamicColors.azkarRed,
    ),
    floatingLabelStyle: IslamicTextStyles.labelMedium.copyWith(
      color: IslamicColors.primaryGreen,
    ),
  ),

  // List tile
  listTileTheme: const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(
      horizontal: IslamicSpacing.md,
      vertical: IslamicSpacing.xs,
    ),
    titleTextStyle: IslamicTextStyles.bodyLarge,
    subtitleTextStyle: IslamicTextStyles.bodySmall,
    leadingAndTrailingTextStyle: IslamicTextStyles.bodyMedium,
    iconColor: IslamicColors.labelSecondary,
    textColor: IslamicColors.labelPrimary,
    minLeadingWidth: 24,
    horizontalTitleGap: IslamicSpacing.md,
    minVerticalPadding: IslamicSpacing.sm,
  ),

  // Divider
  dividerTheme: const DividerThemeData(
    color: IslamicColors.separator,
    thickness: 0.5,
    space: IslamicSpacing.md,
    indent: IslamicSpacing.md,
    endIndent: IslamicSpacing.md,
  ),

  // Bottom navigation bar
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: IslamicColors.systemBackground,
    selectedItemColor: IslamicColors.primaryGreen,
    unselectedItemColor: IslamicColors.labelTertiary,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    selectedLabelStyle: IslamicTextStyles.labelSmall,
    unselectedLabelStyle: IslamicTextStyles.labelSmall,
    showSelectedLabels: true,
    showUnselectedLabels: true,
  ),

  // Navigation bar (iOS 16+)
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: IslamicColors.systemBackground.withValues(alpha: 0.9),
    indicatorColor: IslamicColors.secondaryGreen,
    labelTextStyle: WidgetStateProperty.all(IslamicTextStyles.labelSmall),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(
          color: IslamicColors.primaryGreen,
          size: 24,
        );
      }
      return const IconThemeData(
        color: IslamicColors.labelTertiary,
        size: 24,
      );
    }),
    height: 64,
    surfaceTintColor: Colors.transparent,
    shadowColor: IslamicColors.separator,
  ),

  // Tab bar
  tabBarTheme: TabBarThemeData(
    labelColor: IslamicColors.primaryGreen,
    unselectedLabelColor: IslamicColors.labelTertiary,
    indicatorColor: IslamicColors.primaryGreen,
    indicatorSize: TabBarIndicatorSize.label,
    labelStyle: IslamicTextStyles.labelMedium,
    unselectedLabelStyle: IslamicTextStyles.labelMedium,
    dividerColor: Colors.transparent,
    overlayColor: WidgetStateProperty.resolveWith<Color?>(
      (states) {
        if (states.contains(WidgetState.pressed)) {
          return IslamicColors.secondaryGreen;
        }
        return null;
      },
    ),
  ),

  // Slider
  sliderTheme: SliderThemeData(
    activeTrackColor: IslamicColors.primaryGreen,
    inactiveTrackColor: IslamicColors.secondaryGreen,
    thumbColor: IslamicColors.primaryGreen,
    overlayColor: IslamicColors.primaryGreen.withValues(alpha: 0.15),
    valueIndicatorColor: IslamicColors.primaryGreen,
    valueIndicatorTextStyle: IslamicTextStyles.labelSmall.copyWith(
      color: Colors.white,
    ),
    trackHeight: 4,
    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
  ),

  // Switch
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return IslamicColors.primaryGreen;
      }
      return Colors.white;
    }),
    trackColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return IslamicColors.primaryGreenLight;
      }
      return IslamicColors.separator;
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        return null;
      }
      return IslamicColors.separator;
    }),
  ),

  // Checkbox
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return IslamicColors.primaryGreen;
      }
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(Colors.white),
    side: const BorderSide(color: IslamicColors.separator, width: 1.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(IslamicRadius.sm),
    ),
    materialTapTargetSize: MaterialTapTargetSize.padded,
  ),

  // Radio
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return IslamicColors.primaryGreen;
      }
      return IslamicColors.labelTertiary;
    }),
    materialTapTargetSize: MaterialTapTargetSize.padded,
  ),

  // Progress indicator
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: IslamicColors.primaryGreen,
    linearTrackColor: IslamicColors.secondaryGreen,
    circularTrackColor: IslamicColors.secondaryGreen,
  ),

  // Bottom sheet
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: IslamicColors.systemBackground,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shadowColor: IslamicColors.labelPrimary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(IslamicRadius.xl),
      ),
    ),
    modalBackgroundColor: IslamicColors.systemBackground,
    constraints: BoxConstraints(minWidth: double.infinity),
  ),

  // Dialog
  dialogTheme: DialogThemeData(
    backgroundColor: IslamicColors.systemBackground,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shadowColor: IslamicColors.labelPrimary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(IslamicRadius.xl),
    ),
    titleTextStyle: IslamicTextStyles.titleLarge.copyWith(
      color: IslamicColors.labelPrimary,
    ),
    contentTextStyle: IslamicTextStyles.bodyMedium.copyWith(
      color: IslamicColors.labelPrimary,
    ),
    alignment: Alignment.center,
  ),

  // Snack bar
  snackBarTheme: SnackBarThemeData(
    backgroundColor: IslamicColors.darkLabelPrimary,
    contentTextStyle: IslamicTextStyles.bodyMedium.copyWith(
      color: IslamicColors.darkSystemBackground,
    ),
    actionTextColor: IslamicColors.accentGold,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(IslamicRadius.md),
    ),
    elevation: 6,
  ),

  // Floating action button
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: IslamicColors.primaryGreen,
    foregroundColor: Colors.white,
    elevation: 4,
    focusElevation: 6,
    hoverElevation: 6,
    highlightElevation: 8,
    shape: CircleBorder(),
  ),

  // Chip
  chipTheme: ChipThemeData(
    backgroundColor: IslamicColors.secondaryGreen,
    labelStyle: IslamicTextStyles.labelMedium.copyWith(
      color: IslamicColors.primaryGreenDark,
    ),
    secondaryLabelStyle: IslamicTextStyles.labelMedium.copyWith(
      color: IslamicColors.primaryGreenDark,
    ),
    selectedColor: IslamicColors.primaryGreen,
    disabledColor: IslamicColors.separator.withValues(alpha: 0.3),
    padding: const EdgeInsets.symmetric(
      horizontal: IslamicSpacing.md,
      vertical: IslamicSpacing.xs,
    ),
    labelPadding: const EdgeInsets.symmetric(horizontal: IslamicSpacing.sm),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(IslamicRadius.pill),
      side: BorderSide.none,
    ),
    iconTheme: const IconThemeData(
      color: IslamicColors.primaryGreenDark,
      size: 16,
    ),
  ),

  // Page transitions
  pageTransitionsTheme: PageTransitionsTheme(
    builders: {
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
    },
  ),

  // Visual density
  visualDensity: VisualDensity.standard,
);

/// Dark theme following Apple HIG with Islamic Green accents
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  colorScheme: const ColorScheme.dark(
    primary: IslamicColors.darkPrimaryGreen,
    onPrimary: Colors.black,
    primaryContainer: IslamicColors.darkSecondaryGreen,
    onPrimaryContainer: IslamicColors.darkPrimaryGreen,
    secondary: IslamicColors.accentGoldLight,
    onSecondary: Colors.black,
    secondaryContainer: IslamicColors.accentGold,
    onSecondaryContainer: IslamicColors.darkLabelPrimary,
    tertiary: IslamicColors.prayerBlue,
    onTertiary: Colors.black,
    error: IslamicColors.azkarRed,
    onError: Colors.white,
    surface: IslamicColors.darkSystemBackground,
    onSurface: IslamicColors.darkLabelPrimary,
    surfaceContainerHighest: IslamicColors.darkTertiarySystemBackground,
    onSurfaceVariant: IslamicColors.darkLabelSecondary,
    outline: IslamicColors.darkSeparator,
    outlineVariant: IslamicColors.darkOpaqueSeparator,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: IslamicColors.systemBackground,
    onInverseSurface: IslamicColors.labelPrimary,
    inversePrimary: IslamicColors.primaryGreen,
  ),

  textTheme: const TextTheme(
    displayLarge: IslamicTextStyles.displayLarge,
    displayMedium: IslamicTextStyles.displayMedium,
    displaySmall: IslamicTextStyles.displaySmall,
    headlineLarge: IslamicTextStyles.headlineLarge,
    headlineMedium: IslamicTextStyles.headlineMedium,
    headlineSmall: IslamicTextStyles.headlineSmall,
    titleLarge: IslamicTextStyles.titleLarge,
    titleMedium: IslamicTextStyles.titleMedium,
    titleSmall: IslamicTextStyles.titleSmall,
    bodyLarge: IslamicTextStyles.bodyLarge,
    bodyMedium: IslamicTextStyles.bodyMedium,
    bodySmall: IslamicTextStyles.bodySmall,
    labelLarge: IslamicTextStyles.labelLarge,
    labelMedium: IslamicTextStyles.labelMedium,
    labelSmall: IslamicTextStyles.labelSmall,
  ).apply(
    bodyColor: IslamicColors.darkLabelPrimary,
    displayColor: IslamicColors.darkLabelPrimary,
  ),

  scaffoldBackgroundColor: IslamicColors.darkSystemGroupedBackground,

  appBarTheme: const AppBarTheme(
    backgroundColor: IslamicColors.darkSystemBackground,
    foregroundColor: IslamicColors.darkLabelPrimary,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 1,
    shadowColor: IslamicColors.darkSeparator,
    titleTextStyle: IslamicTextStyles.titleLarge,
    toolbarTextStyle: IslamicTextStyles.bodyMedium,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    centerTitle: true,
  ),

  cardTheme: CardThemeData(
    color: IslamicColors.darkSecondarySystemBackground,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shadowColor: Colors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(IslamicRadius.lg),
      side: const BorderSide(color: IslamicColors.darkSeparator, width: 0.5),
    ),
    margin: const EdgeInsets.all(IslamicSpacing.sm),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: IslamicColors.darkPrimaryGreen,
      foregroundColor: Colors.black,
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: IslamicSpacing.lg,
        vertical: IslamicSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IslamicRadius.md),
      ),
      textStyle: IslamicTextStyles.labelLarge,
      minimumSize: const Size(double.infinity, 50),
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.pressed)) {
            return IslamicColors.darkPrimaryGreen.withValues(alpha: 0.3);
          }
          return null;
        },
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: IslamicColors.darkPrimaryGreen,
      side: const BorderSide(color: IslamicColors.darkPrimaryGreen, width: 1.5),
      padding: const EdgeInsets.symmetric(
        horizontal: IslamicSpacing.lg,
        vertical: IslamicSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IslamicRadius.md),
      ),
      textStyle: IslamicTextStyles.labelLarge,
      minimumSize: const Size(double.infinity, 50),
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.pressed)) {
            return IslamicColors.darkPrimaryGreen.withValues(alpha: 0.2);
          }
          return null;
        },
      ),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: IslamicColors.darkPrimaryGreen,
      padding: const EdgeInsets.symmetric(
        horizontal: IslamicSpacing.md,
        vertical: IslamicSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IslamicRadius.sm),
      ),
      textStyle: IslamicTextStyles.labelLarge,
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.pressed)) {
            return IslamicColors.darkPrimaryGreen.withValues(alpha: 0.15);
          }
          return null;
        },
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: IslamicColors.darkTertiarySystemBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(IslamicRadius.md),
      borderSide: const BorderSide(color: IslamicColors.darkSeparator, width: 0.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(IslamicRadius.md),
      borderSide: const BorderSide(color: IslamicColors.darkSeparator, width: 0.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(IslamicRadius.md),
      borderSide: const BorderSide(color: IslamicColors.darkPrimaryGreen, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(IslamicRadius.md),
      borderSide: const BorderSide(color: IslamicColors.azkarRed, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: IslamicSpacing.md,
      vertical: IslamicSpacing.md,
    ),
    labelStyle: IslamicTextStyles.bodyMedium.copyWith(
      color: IslamicColors.darkLabelSecondary,
    ),
    hintStyle: IslamicTextStyles.bodyMedium.copyWith(
      color: IslamicColors.darkLabelTertiary,
    ),
    errorStyle: IslamicTextStyles.bodySmall.copyWith(
      color: IslamicColors.azkarRed,
    ),
    floatingLabelStyle: IslamicTextStyles.labelMedium.copyWith(
      color: IslamicColors.darkPrimaryGreen,
    ),
  ),

  listTileTheme: const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(
      horizontal: IslamicSpacing.md,
      vertical: IslamicSpacing.xs,
    ),
    titleTextStyle: IslamicTextStyles.bodyLarge,
    subtitleTextStyle: IslamicTextStyles.bodySmall,
    leadingAndTrailingTextStyle: IslamicTextStyles.bodyMedium,
    iconColor: IslamicColors.darkLabelSecondary,
    textColor: IslamicColors.darkLabelPrimary,
    minLeadingWidth: 24,
    horizontalTitleGap: IslamicSpacing.md,
    minVerticalPadding: IslamicSpacing.sm,
  ),

  dividerTheme: const DividerThemeData(
    color: IslamicColors.darkSeparator,
    thickness: 0.5,
    space: IslamicSpacing.md,
    indent: IslamicSpacing.md,
    endIndent: IslamicSpacing.md,
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: IslamicColors.darkSystemBackground,
    selectedItemColor: IslamicColors.darkPrimaryGreen,
    unselectedItemColor: IslamicColors.darkLabelTertiary,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    selectedLabelStyle: IslamicTextStyles.labelSmall,
    unselectedLabelStyle: IslamicTextStyles.labelSmall,
    showSelectedLabels: true,
    showUnselectedLabels: true,
  ),

  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: IslamicColors.darkSystemBackground.withValues(alpha: 0.9),
    indicatorColor: IslamicColors.darkSecondaryGreen,
    labelTextStyle: WidgetStateProperty.all(IslamicTextStyles.labelSmall),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(
          color: IslamicColors.darkPrimaryGreen,
          size: 24,
        );
      }
      return const IconThemeData(
        color: IslamicColors.darkLabelTertiary,
        size: 24,
      );
    }),
    height: 64,
    surfaceTintColor: Colors.transparent,
    shadowColor: IslamicColors.darkSeparator,
  ),

  tabBarTheme: TabBarThemeData(
    labelColor: IslamicColors.darkPrimaryGreen,
    unselectedLabelColor: IslamicColors.darkLabelTertiary,
    indicatorColor: IslamicColors.darkPrimaryGreen,
    indicatorSize: TabBarIndicatorSize.label,
    labelStyle: IslamicTextStyles.labelMedium,
    unselectedLabelStyle: IslamicTextStyles.labelMedium,
    dividerColor: Colors.transparent,
    overlayColor: WidgetStateProperty.resolveWith<Color?>(
      (states) {
        if (states.contains(WidgetState.pressed)) {
          return IslamicColors.darkPrimaryGreen.withValues(alpha: 0.15);
        }
        return null;
      },
    ),
  ),

  sliderTheme: SliderThemeData(
    activeTrackColor: IslamicColors.darkPrimaryGreen,
    inactiveTrackColor: IslamicColors.darkSecondaryGreen,
    thumbColor: IslamicColors.darkPrimaryGreen,
    overlayColor: IslamicColors.darkPrimaryGreen.withValues(alpha: 0.15),
    valueIndicatorColor: IslamicColors.darkPrimaryGreen,
    valueIndicatorTextStyle: IslamicTextStyles.labelSmall.copyWith(
      color: Colors.black,
    ),
    trackHeight: 4,
    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
  ),

  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return IslamicColors.darkPrimaryGreen;
      }
      return IslamicColors.darkLabelPrimary;
    }),
    trackColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return IslamicColors.darkPrimaryGreen.withValues(alpha: 0.5);
      }
      return IslamicColors.darkSeparator;
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
      return IslamicColors.darkSeparator;
    }),
  ),

  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return IslamicColors.darkPrimaryGreen;
      }
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(Colors.black),
    side: const BorderSide(color: IslamicColors.darkSeparator, width: 1.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(IslamicRadius.sm),
    ),
    materialTapTargetSize: MaterialTapTargetSize.padded,
  ),

  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return IslamicColors.darkPrimaryGreen;
      }
      return IslamicColors.darkLabelTertiary;
    }),
    materialTapTargetSize: MaterialTapTargetSize.padded,
  ),

  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: IslamicColors.darkPrimaryGreen,
    linearTrackColor: IslamicColors.darkSecondaryGreen,
    circularTrackColor: IslamicColors.darkSecondaryGreen,
  ),

  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: IslamicColors.darkSystemBackground,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shadowColor: Colors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(IslamicRadius.xl),
      ),
    ),
    modalBackgroundColor: IslamicColors.darkSystemBackground,
    constraints: BoxConstraints(minWidth: double.infinity),
  ),

  dialogTheme: DialogThemeData(
    backgroundColor: IslamicColors.darkSystemBackground,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shadowColor: Colors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(IslamicRadius.xl),
    ),
    titleTextStyle: IslamicTextStyles.titleLarge.copyWith(
      color: IslamicColors.darkLabelPrimary,
    ),
    contentTextStyle: IslamicTextStyles.bodyMedium.copyWith(
      color: IslamicColors.darkLabelPrimary,
    ),
    alignment: Alignment.center,
  ),

  snackBarTheme: SnackBarThemeData(
    backgroundColor: IslamicColors.darkLabelSecondary,
    contentTextStyle: IslamicTextStyles.bodyMedium.copyWith(
      color: IslamicColors.darkLabelPrimary,
    ),
    actionTextColor: IslamicColors.accentGoldLight,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(IslamicRadius.md),
    ),
    elevation: 6,
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: IslamicColors.darkPrimaryGreen,
    foregroundColor: Colors.black,
    elevation: 4,
    focusElevation: 6,
    hoverElevation: 6,
    highlightElevation: 8,
    shape: CircleBorder(),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: IslamicColors.darkSecondaryGreen,
    labelStyle: IslamicTextStyles.labelMedium.copyWith(
      color: IslamicColors.darkPrimaryGreen,
    ),
    secondaryLabelStyle: IslamicTextStyles.labelMedium.copyWith(
      color: IslamicColors.darkPrimaryGreen,
    ),
    selectedColor: IslamicColors.darkPrimaryGreen,
    disabledColor: IslamicColors.darkSeparator.withValues(alpha: 0.3),
    padding: const EdgeInsets.symmetric(
      horizontal: IslamicSpacing.md,
      vertical: IslamicSpacing.xs,
    ),
    labelPadding: const EdgeInsets.symmetric(horizontal: IslamicSpacing.sm),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(IslamicRadius.pill),
      side: BorderSide.none,
    ),
    iconTheme: const IconThemeData(
      color: IslamicColors.darkPrimaryGreen,
      size: 16,
    ),
  ),

  pageTransitionsTheme: PageTransitionsTheme(
    builders: {
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
    },
  ),

  visualDensity: VisualDensity.standard,
);