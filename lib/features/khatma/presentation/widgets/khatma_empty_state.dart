import 'package:flutter/material.dart';
import 'package:khatmah/features/khatma/presentation/widgets/khatma_ring.dart';
import 'package:khatmah/l10n/gen/app_localizations.dart';

/// First-run invitation: an empty 30-segment ring and a single clear call to
/// action. The boldness lives in the ring; everything else stays quiet.
class KhatmaEmptyState extends StatelessWidget {
  const KhatmaEmptyState({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 136,
              height: 136,
              child: KhatmaRing(
                completed: 0,
                total: 30,
                strokeWidth: 8,
                child: Icon(
                  Icons.auto_stories_outlined,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              l10n.startFirstKhatmaTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.startFirstKhatmaBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.add),
              label: Text(l10n.startKhatmaCta),
            ),
          ],
        ),
      ),
    );
  }
}
