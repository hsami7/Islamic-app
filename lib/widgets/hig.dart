import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/app_design.dart';
import '../theme/islamic_theme.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// HIG WIDGET KIT
///
/// Shared, Apple-Human-Interface-Guidelines-faithful building blocks for every
/// screen in the app. Using these guarantees consistency: grouped inset
/// sections, rounded cards, fine separators, large tap targets, correct
/// light/dark color resolution, and safe-area handling.
///
/// Rules for every screen rewrite:
///   • Root = [HIGScaffold] (sets grouped background + SafeArea + optional title).
///   • Group related controls in [HIGGroup] (inset rounded card, iOS settings look).
///   • One row per control = [HIGTile] (icon + label + value/trailing), 44px min tap.
///   • Section caption = [HIGSectionHeader] (uppercase, tertiary color).
///   • NEVER hardcode Colors.* for content; pull from [IslamicTheme.of(context)].
///   • Respect safe areas; bottom padding ≥ 100 for the floating nav bar.
/// ─────────────────────────────────────────────────────────────────────────

/// Root scaffold with grouped background + safe area + large-title header.
class HIGScaffold extends StatelessWidget {
  final String? title;
  final List<Widget> slivers;
  final Widget? body;
  final bool useScrollView;
  final Future<void> Function()? onRefresh;
  final Widget? floatingActionButton;

  const HIGScaffold({
    super.key,
    this.title,
    this.slivers = const [],
    this.body,
    this.useScrollView = true,
    this.onRefresh,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IslamicTheme.of(context);
    final bg = theme.isDark
        ? IslamicColors.darkSystemGroupedBackground
        : IslamicColors.systemGroupedBackground;

    if (!useScrollView) {
      return Scaffold(
        backgroundColor: bg,
        body: SafeArea(child: body ?? const SizedBox.shrink()),
        floatingActionButton: floatingActionButton,
      );
    }

    final scrollView = CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (title != null) _LargeTitleSliver(title: title!),
        ...slivers,
        const SliverToBoxAdapter(
          child: SizedBox(height: 120), // room for floating nav bar
        ),
      ],
    );

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: onRefresh != null
            ? RefreshIndicator(
                onRefresh: onRefresh!,
                color: theme.accent,
                child: scrollView,
              )
            : scrollView,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class _LargeTitleSliver extends StatelessWidget {
  final String title;
  const _LargeTitleSliver({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = IslamicTheme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          left: kHIGMargin,
          right: kHIGMargin,
          top: IslamicSpacing.md,
          bottom: IslamicSpacing.sm,
        ),
        child: Text(
          title.tr(),
          style: IslamicTextStyles.displaySmall.copyWith(
            color: theme.textPrimary,
            fontFamily: 'SF Pro',
          ),
        ),
      ),
    );
  }
}

/// Inset rounded group (iOS "grouped" card). Children separated by hairlines.
class HIGGroup extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  final String? header;
  final String? footer;

  const HIGGroup({
    super.key,
    required this.children,
    this.margin,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IslamicTheme.of(context);
    final m = margin ??
        const EdgeInsets.symmetric(horizontal: kHIGMargin, vertical: IslamicSpacing.sm);

    Widget group = Container(
      margin: m,
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(IslamicRadius.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _withDividers(children, theme),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null)
          HIGSectionHeader(text: header!, margin: m),
        group,
        if (footer != null)
          Padding(
            padding: EdgeInsets.only(
              left: kHIGMargin,
              right: kHIGMargin,
              top: IslamicSpacing.xs,
            ),
            child: Text(
              footer!.tr(),
              style: IslamicTextStyles.footnote.copyWith(
                color: theme.textTertiary,
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _withDividers(List<Widget> children, IslamicTheme theme) {
    final out = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      out.add(children[i]);
      if (i < children.length - 1) {
        out.add(Padding(
          padding: const EdgeInsets.only(left: 16 + 36 + 12),
          child: Divider(
            height: 1,
            thickness: 0.5,
            color: theme.separator,
          ),
        ));
      }
    }
    return out;
  }
}

/// A single 44pt-min tap row: leading widget/icon, title, subtitle, trailing.
class HIGTile extends StatelessWidget {
  final Widget? leading;
  final IconData? icon;
  final Color? iconColor;
  final String? title;
  final String? label;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  const HIGTile({
    super.key,
    this.leading,
    this.icon,
    this.iconColor,
    this.title,
    this.label,
    this.subtitle,
    this.subtitleWidget,
    this.trailing,
    this.onTap,
    this.showChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IslamicTheme.of(context);
    final text = title ?? label;
    final child = Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 12),
        ] else if (icon != null) ...[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (iconColor ?? theme.accent).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(IslamicRadius.sm + 2),
            ),
            child: Icon(icon, color: iconColor ?? theme.accent, size: 20),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (text != null)
                Text(
                  text.tr(),
                  style: IslamicTextStyles.bodyLarge.copyWith(
                    color: theme.textPrimary,
                  ),
                ),
              if (subtitleWidget != null) ...[
                const SizedBox(height: 2),
                subtitleWidget!,
              ] else if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!.tr(),
                  style: IslamicTextStyles.footnote.copyWith(
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ] else if (showChevron) ...[
          const SizedBox(width: 8),
          Icon(
            CupertinoIcons.chevron_right,
            size: 16,
            color: CupertinoColors.systemGrey,
          ),
        ],
      ],
    );

    final padded = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: IslamicSpacing.md,
        vertical: IslamicSpacing.md - 2,
      ),
      child: child,
    );

    if (onTap == null) return padded;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(IslamicRadius.sm),
        child: padded,
      ),
    );
  }
}

/// Uppercase section caption (iOS settings group title).
class HIGSectionHeader extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry? margin;
  const HIGSectionHeader({super.key, required this.text, this.margin});

  @override
  Widget build(BuildContext context) {
    final theme = IslamicTheme.of(context);
    return Padding(
      padding: margin ??
          const EdgeInsets.only(
            left: kHIGMargin + 4,
            top: IslamicSpacing.md,
            bottom: IslamicSpacing.xs,
          ),
      child: Text(
        text.tr().toUpperCase(),
        style: IslamicTextStyles.footnote.copyWith(
          color: theme.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// A standalone rounded card (for hero content / summaries), no dividers.
class HIGCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final List<BoxShadow>? shadow;
  final VoidCallback? onTap;

  const HIGCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(IslamicSpacing.md),
    this.margin,
    this.color,
    this.shadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IslamicTheme.of(context);
    final card = Container(
      margin: margin ??
          const EdgeInsets.symmetric(
            horizontal: kHIGMargin,
            vertical: IslamicSpacing.sm,
          ),
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? theme.card,
        borderRadius: BorderRadius.circular(IslamicRadius.lg),
        boxShadow: shadow ?? IslamicShadows.card,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(IslamicRadius.lg), child: card),
    );
  }
}

/// iOS-style segmented control wrapper (uses CupertinoSegmentedControl).
class HIGSegmented<T extends Object> extends StatelessWidget {
  final Map<T, Widget> children;
  final T groupValue;
  final ValueChanged<T> onValueChanged;

  const HIGSegmented({
    super.key,
    required this.children,
    required this.groupValue,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IslamicTheme.of(context);
    return CupertinoSegmentedControl<T>(
      children: children,
      groupValue: groupValue,
      onValueChanged: onValueChanged,
      selectedColor: theme.accent,
      unselectedColor: Colors.transparent,
      borderColor: theme.separator,
      pressedColor: theme.accent.withValues(alpha: 0.1),
    );
  }
}

/// iOS-style toggle row (label + CupertinoSwitch), with fixed 44pt height.
class HIGToggleTile extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String? label;
  final Widget? leading;
  final String? title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const HIGToggleTile({
    super.key,
    this.icon,
    this.iconColor,
    this.label,
    this.leading,
    this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IslamicTheme.of(context);
    return HIGTile(
      icon: icon,
      iconColor: iconColor,
      label: label,
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: theme.accent,
      ),
    );
  }
}

/// iOS-style slider row (title + CupertinoSlider), supporting a leading icon
/// and a live value subtitle.
class HIGSliderTile extends StatelessWidget {
  final Widget? leading;
  final IconData? icon;
  final Color? iconColor;
  final String? title;
  final String? label;
  final String? subtitle;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  const HIGSliderTile({
    super.key,
    this.leading,
    this.icon,
    this.iconColor,
    this.title,
    this.label,
    this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IslamicTheme.of(context);
    final text = title ?? label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HIGTile(
          leading: leading,
          icon: icon,
          iconColor: iconColor,
          label: text,
          subtitle: subtitle,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: CupertinoSlider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: theme.accent,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
