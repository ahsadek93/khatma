import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khatmah/core/utils/formatting.dart';
import 'package:khatmah/features/khatma/presentation/view_models/create_khatma_view_model.dart';
import 'package:khatmah/l10n/gen/app_localizations.dart';

/// Form for starting a new khatma: a name, a finish goal, and a live preview of
/// the daily reading pace that goal implies.
class CreateKhatmaScreen extends ConsumerWidget {
  const CreateKhatmaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final form = ref.watch(createKhatmaViewModelProvider);
    final vm = ref.read(createKhatmaViewModelProvider.notifier);

    Future<void> pickDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: form.targetDate,
        firstDate: form.startDate,
        lastDate: form.startDate.add(const Duration(days: 730)),
      );
      if (picked != null) vm.setTargetDate(picked);
    }

    Future<void> submit() async {
      final created = await vm.submit();
      if (created != null && context.mounted) {
        context.pushReplacement('/khatma/${created.id}');
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newKhatma)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _Label(l10n.khatmaTitleLabel),
          const SizedBox(height: 8),
          TextField(
            autofocus: true,
            textInputAction: TextInputAction.done,
            onChanged: vm.setTitle,
            decoration: InputDecoration(hintText: l10n.khatmaTitleHint),
          ),
          const SizedBox(height: 28),
          _Label(l10n.goalLabel),
          const SizedBox(height: 8),
          SegmentedButton<KhatmaGoalPreset>(
            segments: [
              ButtonSegment(
                value: KhatmaGoalPreset.week,
                label: Text(l10n.goalWeek),
              ),
              ButtonSegment(
                value: KhatmaGoalPreset.month,
                label: Text(l10n.goalMonth),
              ),
              ButtonSegment(
                value: KhatmaGoalPreset.custom,
                label: Text(l10n.goalCustom),
              ),
            ],
            selected: {form.preset},
            showSelectedIcon: false,
            onSelectionChanged: (selection) => vm.setPreset(selection.first),
          ),
          const SizedBox(height: 12),
          _DateTile(
            label: l10n.targetDateLabel,
            value: formatMediumDate(context, form.targetDate),
            onTap: pickDate,
          ),
          const SizedBox(height: 24),
          _PacePreview(
            dailyTarget: form.dailyTargetPreview,
            totalDays: form.totalDays,
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: form.isValid && !form.submitting ? submit : null,
            child: form.submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : Text(l10n.createButton),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                Icons.event_outlined,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(label, style: theme.textTheme.bodyMedium),
              const Spacer(),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PacePreview extends StatelessWidget {
  const _PacePreview({required this.dailyTarget, required this.totalDays});

  final int dailyTarget;
  final int totalDays;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department_outlined,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.juzPerDay(dailyTarget),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.daysLeft(totalDays),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer
                        .withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
