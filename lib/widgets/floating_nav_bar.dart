import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../constants/app_design.dart';
import '../../providers/settings_provider.dart';

/// A floating, glass bottom navigation bar (Home, Quran, Prayer, Qibla, Azkar).
class FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const FloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;

    final items = [
      _NavItem(icon: CupertinoIcons.house_fill, label: 'home', color: IslamicColors.primaryGreen),
      _NavItem(icon: CupertinoIcons.book_fill, label: 'quran', color: IslamicColors.quranGold),
      _NavItem(icon: CupertinoIcons.clock_fill, label: 'prayer_times', color: IslamicColors.prayerBlue),
      _NavItem(icon: CupertinoIcons.location_fill, label: 'qibla', color: IslamicColors.qiblaOrange),
      _NavItem(icon: CupertinoIcons.sparkles, label: 'azkar', color: IslamicColors.azkarRed),
    ];

    final bg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: IslamicSpacing.lg,
          vertical: IslamicSpacing.sm,
        ),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(IslamicRadius.pill),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == selectedIndex;
              final color = isSelected
                  ? item.color
                  : (isDark ? IslamicColors.darkLabelTertiary : IslamicColors.labelTertiary);

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(IslamicRadius.md),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: color,
                        size: isSelected ? 26 : 24,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label.tr(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: color,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w400,
                              fontSize: 10,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Color color;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}
