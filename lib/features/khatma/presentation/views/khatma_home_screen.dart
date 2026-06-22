import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khatmah/core/config/app_config.dart';
import 'package:khatmah/features/group_khatma/presentation/view_models/group_khatma_view_models.dart';
import 'package:khatmah/features/group_khatma/presentation/widgets/group_khatma_card.dart';
import 'package:khatmah/features/khatma/presentation/view_models/khatma_view_models.dart';
import 'package:khatmah/features/khatma/presentation/widgets/khatma_card.dart';
import 'package:khatmah/features/khatma/presentation/widgets/khatma_empty_state.dart';
import 'package:khatmah/features/khatma/presentation/widgets/khatma_ring.dart';
import 'package:khatmah/l10n/gen/app_localizations.dart';

enum _Tab { mine, shared }

/// The Khatma tab home: a toggle between the reader's **personal** khatmas
/// (local-first) and **shared** group khatmas (Supabase).
class KhatmaHomeScreen extends ConsumerStatefulWidget {
  const KhatmaHomeScreen({super.key});

  @override
  ConsumerState<KhatmaHomeScreen> createState() => _KhatmaHomeScreenState();
}

class _KhatmaHomeScreenState extends ConsumerState<KhatmaHomeScreen> {
  _Tab _tab = _Tab.mine;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isShared = _tab == _Tab.shared;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.khatmaTitle),
        actions: [
          if (isShared)
            IconButton(
              icon: const Icon(Icons.group_add_outlined),
              tooltip: l10n.joinWithCode,
              onPressed: () => context.push('/khatma/group_join'),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push(isShared ? '/khatma/group_new' : '/khatma/new'),
        icon: const Icon(Icons.add),
        label: Text(isShared ? l10n.newGroupKhatma : l10n.newKhatma),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: SegmentedButton<_Tab>(
              segments: [
                ButtonSegment(
                  value: _Tab.mine,
                  label: Text(l10n.personalKhatmasTab),
                  icon: const Icon(Icons.person_outline),
                ),
                ButtonSegment(
                  value: _Tab.shared,
                  label: Text(l10n.sharedKhatmasTab),
                  icon: const Icon(Icons.groups_outlined),
                ),
              ],
              selected: {_tab},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _tab = s.first),
            ),
          ),
          Expanded(
            child: isShared
                ? const _SharedKhatmaListView()
                : const _PersonalKhatmaListView(),
          ),
        ],
      ),
    );
  }
}

class _PersonalKhatmaListView extends ConsumerWidget {
  const _PersonalKhatmaListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final khatmas = ref.watch(khatmaListProvider);

    return khatmas.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.genericError)),
      data: (list) {
        if (list.isEmpty) {
          return KhatmaEmptyState(onStart: () => context.push('/khatma/new'));
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 96),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final khatma = list[index];
            return KhatmaCard(
              khatma: khatma,
              onTap: () => context.push('/khatma/${khatma.id}'),
            );
          },
        );
      },
    );
  }
}

class _SharedKhatmaListView extends ConsumerWidget {
  const _SharedKhatmaListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    if (!AppConfig.isSupabaseConfigured) {
      return _CenteredMessage(text: l10n.needsConnection);
    }

    final groups = ref.watch(groupListProvider);
    return groups.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => _CenteredMessage(text: l10n.genericError),
      data: (list) {
        if (list.isEmpty) return const _SharedEmptyState();
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 96),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final group = list[index];
            return GroupKhatmaCard(
              group: group,
              onTap: () => context.push('/khatma/group/${group.id}'),
            );
          },
        );
      },
    );
  }
}

class _SharedEmptyState extends StatelessWidget {
  const _SharedEmptyState();

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
                child: Icon(Icons.groups_outlined,
                    size: 42, color: theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 28),
            Text(l10n.sharedEmptyTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              l10n.sharedEmptyBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/khatma/group_new'),
              icon: const Icon(Icons.add),
              label: Text(l10n.createGroupCta),
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: () => context.push('/khatma/group_join'),
              icon: const Icon(Icons.group_add_outlined),
              label: Text(l10n.joinWithCode),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}
