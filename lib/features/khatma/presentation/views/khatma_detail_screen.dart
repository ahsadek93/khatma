import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khatmah/core/theme/app_colors.dart';
import 'package:khatmah/core/utils/formatting.dart';
import 'package:khatmah/features/khatma/domain/entities/khatma.dart';
import 'package:khatmah/features/khatma/domain/entities/khatma_schedule.dart';
import 'package:khatmah/features/khatma/presentation/view_models/khatma_view_models.dart';
import 'package:khatmah/features/khatma/presentation/widgets/juz_grid.dart';
import 'package:khatmah/features/khatma/presentation/widgets/khatma_ring.dart';
import 'package:khatmah/features/khatma/presentation/widgets/pace_chip.dart';
import 'package:khatmah/l10n/gen/app_localizations.dart';

/// A single khatma: its progress ring, schedule stats, and the tap-to-toggle
/// grid of ajzāʾ.
class KhatmaDetailScreen extends ConsumerWidget {
  const KhatmaDetailScreen({super.key, required this.khatmaId});

  final String khatmaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(khatmaDetailProvider(khatmaId));
    final title = state.asData?.value.khatma?.title ?? l10n.khatmaTitle;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (state.asData?.value.khatma case final khatma?)
            PopupMenuButton<_MenuAction>(
              onSelected: (action) => switch (action) {
                _MenuAction.rename => _rename(context, ref, khatma),
                _MenuAction.delete => _confirmDelete(context, ref, khatma),
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _MenuAction.rename,
                  child: Text(l10n.renameKhatma),
                ),
                PopupMenuItem(
                  value: _MenuAction.delete,
                  child: Text(l10n.deleteKhatma),
                ),
              ],
            ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.genericError)),
        data: (data) {
          final khatma = data.khatma;
          final schedule = data.schedule;
          if (khatma == null || schedule == null) {
            return Center(child: Text(l10n.khatmaNotFound));
          }
          return _DetailBody(
            khatma: khatma,
            schedule: schedule,
            completed: data.completed,
            onToggle: (juz, completed) {
              HapticFeedback.selectionClick();
              ref
                  .read(khatmaCommandsProvider)
                  .toggleJuz(khatma.id, juz, completed: completed);
            },
          );
        },
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, Khatma khatma) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: khatma.title);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.renameKhatmaTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.khatmaTitleHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && result.isNotEmpty) {
      await ref.read(khatmaCommandsProvider).rename(khatma.id, result);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Khatma khatma,
  ) async {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteKhatmaTitle),
        content: Text(l10n.deleteKhatmaBody(khatma.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteKhatma),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(khatmaCommandsProvider).delete(khatma.id);
      if (context.mounted) context.pop();
    }
  }
}

enum _MenuAction { rename, delete }

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.khatma,
    required this.schedule,
    required this.completed,
    required this.onToggle,
  });

  final Khatma khatma;
  final KhatmaSchedule schedule;
  final Set<int> completed;
  final void Function(int juz, bool completed) onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        Center(
          child: SizedBox(
            width: 220,
            height: 220,
            child: KhatmaRing(
              completed: khatma.completedJuzCount,
              total: khatma.totalJuz,
              strokeWidth: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatNumber(context, khatma.completedJuzCount),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  Text(
                    '/ ${formatNumber(context, khatma.totalJuz)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  PaceChip(pace: schedule.pace),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _Stat(
              value: formatNumber(context, schedule.remainingJuz),
              label: l10n.statRemaining,
            ),
            _Divider(),
            _Stat(
              value: formatNumber(context, schedule.daysRemaining),
              label: l10n.statDaysLeft,
            ),
            _Divider(),
            _Stat(
              value: formatNumber(context, schedule.dailyTarget),
              label: l10n.statPerDay,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _PaceBanner(pace: schedule.pace),
        const SizedBox(height: 28),
        Text(
          l10n.sectionJuz,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 14),
        JuzGrid(
          total: khatma.totalJuz,
          completed: completed,
          onToggle: onToggle,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

class _PaceBanner extends StatelessWidget {
  const _PaceBanner({required this.pace});

  final KhatmaPace pace;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final (String message, Color background, Color foreground) = switch (pace) {
      KhatmaPace.done => (
          l10n.bannerDone,
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
        ),
      KhatmaPace.ahead => (
          l10n.bannerAhead,
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
        ),
      KhatmaPace.onTrack => (
          l10n.bannerOnTrack,
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
        ),
      KhatmaPace.behind => (
          l10n.bannerBehind,
          AppColors.behind.withValues(alpha: 0.14),
          AppColors.behind,
        ),
      KhatmaPace.overdue => (
          l10n.bannerOverdue,
          AppColors.behind.withValues(alpha: 0.14),
          AppColors.behind,
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
