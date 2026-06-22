import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khatmah/core/providers/app_providers.dart';
import 'package:khatmah/core/utils/formatting.dart';
import 'package:khatmah/features/khatma/domain/entities/khatma.dart';
import 'package:khatmah/features/khatma/domain/entities/khatma_schedule.dart';
import 'package:khatmah/features/khatma/presentation/widgets/khatma_ring.dart';
import 'package:khatmah/features/khatma/presentation/widgets/pace_chip.dart';
import 'package:khatmah/l10n/gen/app_localizations.dart';

/// A khatma summary on the list screen: the ring, the title, today's target,
/// pace and days remaining.
class KhatmaCard extends ConsumerWidget {
  const KhatmaCard({super.key, required this.khatma, required this.onTap});

  final Khatma khatma;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider)();
    final schedule = KhatmaSchedule.of(khatma, today: now);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 78,
                height: 78,
                child: KhatmaRing(
                  completed: khatma.completedJuzCount,
                  total: khatma.totalJuz,
                  strokeWidth: 7,
                  child: FittedBox(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          formatNumber(context, khatma.completedJuzCount),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                        Text(
                          '/${formatNumber(context, khatma.totalJuz)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      khatma.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      schedule.isDone
                          ? l10n.finishByDate(
                              formatMediumDate(context, khatma.targetDate),
                            )
                          : l10n.readTodayTarget(schedule.dailyTarget),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        PaceChip(pace: schedule.pace),
                        const Spacer(),
                        if (!schedule.isDone)
                          Text(
                            l10n.daysLeft(schedule.daysRemaining),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
