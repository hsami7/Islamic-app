import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Islamic Green color palette following Apple HIG principles
class IslamicColors {
  // Primary Islamic Green - used sparingly for key actions
  static const Color primaryGreen = Color(0xFF006B3F);
  static const Color primaryGreenLight = Color(0xFF00874D);
  static const Color primaryGreenDark = Color(0xFF004D2D);

  // Secondary - softer green for backgrounds
  static const Color secondaryGreen = Color(0xFFE8F5ED);
  static const Color secondaryGreenDark = Color(0xFF1A3D2E);

  // Accent - gold for special elements (Bismillah, etc.)
  static const Color accentGold = Color(0xFFD4A843);
  static const Color accentGoldLight = Color(0xFFE8C56D);

  // Semantic colors (Apple HIG)
  static const Color labelPrimary = Color(0xFF1C1C1E);
  static const Color labelSecondary = Color(0xFF3C3C43);
  static const Color labelTertiary = Color(0xFF3C3C4366);
  static const Color labelQuaternary = Color(0xFF3C3C432E);

  static const Color systemBackground = Color(0xFFFFFFFF);
  static const Color secondarySystemBackground = Color(0xFFF2F2F7);
  static const Color tertiarySystemBackground = Color(0xFFFFFFFF);

  static const Color systemGroupedBackground = Color(0xFFF2F2F7);
  static const Color secondarySystemGroupedBackground = Color(0xFFFFFFFF);
  static const Color tertiarySystemGroupedBackground = Color(0xFFF2F2F7);

  static const Color separator = Color(0xFF3C3C434A);
  static const Color opaqueSeparator = Color(0xFFC6C6C8);

  // Islamic specific
  static const Color quranGold = Color(0xFFD4A843);
  static const Color prayerBlue = Color(0xFF007AFF);
  static const Color qiblaOrange = Color(0xFFFF9F0A);
  static const Color azkarRed = Color(0xFFFF453A);

  // Quran reader surface
  static const Color beigeSurface = Color(0xFFF3EAD9);
  static const Color darkBeigeSurface = Color(0xFF1A1714);

  // Dark mode
  static const Color darkPrimaryGreen = Color(0xFF30D158);
  static const Color darkSecondaryGreen = Color(0xFF1A3D2E);
  static const Color darkLabelPrimary = Color(0xFFFFFFFF);
  static const Color darkLabelSecondary = Color(0xFFEBEBF5);
  static const Color darkLabelTertiary = Color(0xFFEBEBF599);
  static const Color darkSystemBackground = Color(0xFF000000);
  static const Color darkSecondarySystemBackground = Color(0xFF1C1C1E);
  static const Color darkTertiarySystemBackground = Color(0xFF2C2C2E);
  static const Color darkSystemGroupedBackground = Color(0xFF000000);
  static const Color darkSecondarySystemGroupedBackground = Color(0xFF1C1C1E);
  static const Color darkSeparator = Color(0xFF545458);
  static const Color darkOpaqueSeparator = Color(0xFF38383A);
}

/// Edge horizontal margin for full-width HIG content (lists, groups, screens).
const double kHIGMargin = 20.0;

/// Spacing system following Apple HIG (8pt grid)
class IslamicSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Border radius following Apple HIG
class IslamicRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double pill = 999.0;
}

/// Typography following Apple SF Pro + Amiri for Arabic
class IslamicTextStyles {
  // Display styles
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  // Headline styles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // Title styles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    height: 1.41,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    height: 1.47,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
    height: 1.38,
  );

  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // Footnote / caption (HIG grouped section footer, subtitles)
  static const TextStyle footnote = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
    height: 1.4,
  );

  // Callout (slightly emphasized caption)
  static const TextStyle callout = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.12,
    height: 1.4,
  );

  // Arabic specific styles
  static const TextStyle arabicLarge = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 1.8,
  );

  static const TextStyle arabicMedium = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 22,
    fontWeight: FontWeight.w400,
    height: 1.8,
  );

  static const TextStyle arabicSmall = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.8,
  );

  static const TextStyle arabicBold = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.8,
  );

  // Quran text
  static const TextStyle quranAyah = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 26,
    fontWeight: FontWeight.w400,
    height: 2.0,
  );

  static const TextStyle quranTranslation = TextStyle(
    fontFamily: 'NotoSansArabic',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
}

/// Shadow system
class IslamicShadows {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: IslamicColors.labelPrimary.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: IslamicColors.labelPrimary.withValues(alpha: 0.03),
      blurRadius: 30,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get cardElevated => [
    BoxShadow(
      color: IslamicColors.labelPrimary.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: IslamicColors.labelPrimary.withValues(alpha: 0.05),
      blurRadius: 40,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> get modal => [
    BoxShadow(
      color: IslamicColors.labelPrimary.withValues(alpha: 0.15),
      blurRadius: 50,
      offset: const Offset(0, 16),
    ),
  ];
}

/// Animation durations following Apple HIG
class IslamicDurations {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration standard = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

/// Icons using Cupertino + custom Islamic icons
class IslamicIcons {
  static const IconData quran = IconData(0xF300, fontFamily: 'IslamicIcons');
  static const IconData prayer = IconData(0xF301, fontFamily: 'IslamicIcons');
  static const IconData qibla = IconData(0xF302, fontFamily: 'IslamicIcons');
  static const IconData azkar = IconData(0xF304, fontFamily: 'IslamicIcons');
  static const IconData tasbih = IconData(0xF305, fontFamily: 'IslamicIcons');
  static const IconData kaaba = IconData(0xF306, fontFamily: 'IslamicIcons');
  static const IconData bismillah = IconData(0xF307, fontFamily: 'IslamicIcons');
}