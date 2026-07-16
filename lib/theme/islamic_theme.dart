import 'package:flutter/material.dart';
import '../constants/app_design.dart';

/// UNIFIED THEME TOKENS
///
/// One source of truth for every surface. Never hardcode a raw color in a
/// screen again — pull it from [IslamicTheme] so light/dark stay consistent.
///
/// Rules (pro-style, explicit):
///   TEXT / ICONS
///     ┌───────────────┬─────────────────────────┬─────────────────────────┐
///     │ token         │ LIGHT MODE              │ DARK MODE               │
///     ├───────────────┼─────────────────────────┼─────────────────────────┤
///     │ textPrimary   │ near-black  #1C1C1E     │ white        #FFFFFF     │
///     │ textSecondary │ dark grey   #3C3C43     │ light grey   #EBEBF5     │
///     │ textTertiary  │ grey 40%    #3C3C4366   │ light grey 60% #EBEBF599 │
///     │ accent        │ green       #006B3F     │ bright green #30D158     │
///     │ separator     │ grey 29%    #3C3C434A   │ grey         #545458     │
///     └───────────────┴─────────────────────────┴─────────────────────────┘
///
///   SURFACES
///     background   : light #FFFFFF        dark #000000
///     card         : light #FFFFFF        dark #1C1C1E
///     accentSoft   : accent @ 12% alpha (works in both modes)
class IslamicTheme {
  IslamicTheme._({
    required this.isDark,
    required this.background,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.accentDark,
    required this.accentSoft,
    required this.separator,
    required this.gold,
    required this.red,
  });

  /// Resolve tokens for the current [Brightness].
  factory IslamicTheme.fromBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? IslamicTheme.dark : IslamicTheme.light;

  /// Convenience: resolve from a [BuildContext].
  factory IslamicTheme.of(BuildContext context) =>
      IslamicTheme.fromBrightness(Theme.of(context).brightness);

  static final IslamicTheme light = IslamicTheme._(
    isDark: false,
    background: IslamicColors.systemBackground,
    card: IslamicColors.systemBackground,
    textPrimary: IslamicColors.labelPrimary,
    textSecondary: IslamicColors.labelSecondary,
    textTertiary: IslamicColors.labelTertiary,
    accent: IslamicColors.primaryGreen,
    accentDark: IslamicColors.primaryGreenDark,
    accentSoft: IslamicColors.primaryGreen.withValues(alpha: 0.12),
    separator: IslamicColors.separator,
    gold: IslamicColors.accentGold,
    red: IslamicColors.azkarRed,
  );

  static final IslamicTheme dark = IslamicTheme._(
    isDark: true,
    background: IslamicColors.darkSystemBackground,
    card: IslamicColors.darkSecondarySystemBackground,
    textPrimary: IslamicColors.darkLabelPrimary,
    textSecondary: IslamicColors.darkLabelSecondary,
    textTertiary: IslamicColors.darkLabelTertiary,
    accent: IslamicColors.darkPrimaryGreen,
    accentDark: IslamicColors.darkPrimaryGreen,
    accentSoft: IslamicColors.darkPrimaryGreen.withValues(alpha: 0.18),
    separator: IslamicColors.darkSeparator,
    gold: IslamicColors.accentGold,
    red: IslamicColors.azkarRed,
  );

  final bool isDark;

  // Surfaces
  final Color background;
  final Color card;

  // Text + icons share the same tokens (pro pattern: icon color == text color)
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  // Brand accent (green)
  final Color accent;
  final Color accentDark;
  final Color accentSoft;

  // Lines
  final Color separator;

  // Semantic accents
  final Color gold;
  final Color red;
}
