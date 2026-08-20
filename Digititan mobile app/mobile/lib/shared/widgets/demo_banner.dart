import 'package:flutter/material.dart';

import '../theme/digititan_theme.dart';

/// Quiet presentation strip — short, not a wall of demo instructions.
class DemoBanner extends StatelessWidget {
  final String message;
  final bool compact;

  const DemoBanner({
    super.key,
    required this.message,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DigititanColors.primaryDark,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: compact ? 7 : 10,
        ),
        child: Row(
          children: [
            const Icon(Icons.circle, size: 8, color: DigititanColors.teal),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft page atmosphere (login / empty states).
class BrandBackdrop extends StatelessWidget {
  final Widget child;

  const BrandBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            DigititanColors.softBlue,
            DigititanColors.background,
            DigititanColors.softGreen,
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: child,
    );
  }
}

/// Section title used across Home / Store / dashboards.
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAction;
  final String actionLabel;

  const SectionHeader({
    super.key,
    required this.title,
    this.onAction,
    this.actionLabel = 'See all',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          if (onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
        ],
      ),
    );
  }
}

/// Compact metric for Ops / Super dashboards.
class MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DigititanColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DigititanColors.muted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: DigititanColors.primary),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

/// Soft callout without looking like a generic blue info card.
class QuietNotice extends StatelessWidget {
  final String message;
  final Widget? trailing;

  const QuietNotice({
    super.key,
    required this.message,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DigititanColors.softBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
