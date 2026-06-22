import 'package:flutter/material.dart';
import 'package:khatmah/core/theme/app_colors.dart';
import 'package:khatmah/features/khatma/domain/entities/khatma_schedule.dart';
import 'package:khatmah/l10n/gen/app_localizations.dart';

/// A small status pill conveying how a khatma is tracking against its deadline.
class PaceChip extends StatelessWidget {
  const PaceChip({super.key, required this.pace});

  final KhatmaPace pace;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final (String label, Color color, IconData icon) = switch (pace) {
      KhatmaPace.done => (l10n.paceDone, AppColors.gold, Icons.auto_awesome_rounded),
      KhatmaPace.ahead => (l10n.paceAhead, scheme.primary, Icons.trending_up_rounded),
      KhatmaPace.onTrack => (l10n.paceOnTrack, scheme.primary, Icons.check_circle_outline_rounded),
      KhatmaPace.behind => (l10n.paceBehind, AppColors.behind, Icons.schedule_rounded),
      KhatmaPace.overdue => (l10n.paceOverdue, AppColors.behind, Icons.error_outline_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
