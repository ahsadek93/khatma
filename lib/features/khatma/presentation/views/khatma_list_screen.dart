import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khatmah/features/khatma/presentation/view_models/khatma_view_models.dart';
import 'package:khatmah/features/khatma/presentation/widgets/khatma_card.dart';
import 'package:khatmah/features/khatma/presentation/widgets/khatma_empty_state.dart';
import 'package:khatmah/l10n/gen/app_localizations.dart';

/// The home tab: every khatma the reader is tracking, or a first-run invitation.
class KhatmaListScreen extends ConsumerWidget {
  const KhatmaListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final khatmas = ref.watch(khatmaListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.khatmaTitle)),
      floatingActionButton: khatmas.maybeWhen(
        data: (list) => list.isEmpty
            ? null
            : FloatingActionButton.extended(
                onPressed: () => context.push('/khatma/new'),
                icon: const Icon(Icons.add),
                label: Text(l10n.newKhatma),
              ),
        orElse: () => null,
      ),
      body: khatmas.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.genericError)),
        data: (list) {
          if (list.isEmpty) {
            return KhatmaEmptyState(onStart: () => context.push('/khatma/new'));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
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
      ),
    );
  }
}
