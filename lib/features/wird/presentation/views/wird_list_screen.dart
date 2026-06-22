import 'package:flutter/material.dart';

import '../../../../l10n/gen/app_localizations.dart';

/// The wird (zikr) tab is intentionally deferred for v1 — Khatmah v1 focuses on
/// the Qur'an khatma (personal + shared). This shows a calm "coming soon".
class WirdListScreen extends StatelessWidget {
  const WirdListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.wirdTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                child: Icon(
                  Icons.spa_outlined,
                  size: 42,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(l10n.comingSoon, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                l10n.wirdComingSoonBody,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
