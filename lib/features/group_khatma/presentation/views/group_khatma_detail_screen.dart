import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khatmah/core/theme/app_colors.dart';
import 'package:khatmah/core/utils/formatting.dart';
import 'package:khatmah/features/group_khatma/domain/entities/group_khatma.dart';
import 'package:khatmah/features/group_khatma/domain/entities/group_member.dart';
import 'package:khatmah/features/group_khatma/domain/entities/juz_claim.dart';
import 'package:khatmah/features/group_khatma/group_khatma_providers.dart';
import 'package:khatmah/features/group_khatma/presentation/view_models/group_khatma_view_models.dart';
import 'package:khatmah/features/group_khatma/presentation/widgets/group_juz_grid.dart';
import 'package:khatmah/features/khatma/presentation/widgets/khatma_ring.dart';
import 'package:khatmah/l10n/gen/app_localizations.dart';

/// A shared khatma: the collective progress ring, invite code, member roster,
/// and the live, claim-aware juz grid. Updates in realtime as members work.
class GroupKhatmaDetailScreen extends ConsumerWidget {
  const GroupKhatmaDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(groupDetailProvider(groupId));
    final uid = ref.watch(currentUserIdProvider);
    final group = state.asData?.value.group;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          group?.title ?? l10n.sharedKhatmasTab,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (group != null)
            IconButton(
              icon: const Icon(Icons.copy_rounded),
              tooltip: l10n.copyCode,
              onPressed: () => _copyCode(context, group.inviteCode),
            ),
          if (group != null)
            PopupMenuButton<String>(
              onSelected: (_) => _confirmLeave(context, ref, group),
              itemBuilder: (context) => [
                PopupMenuItem(value: 'leave', child: Text(l10n.leaveGroup)),
              ],
            ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.genericError)),
        data: (data) {
          final g = data.group;
          if (g == null) return Center(child: Text(l10n.groupNotFound));
          return _Body(
            group: g,
            state: data,
            currentUserId: uid,
            onTap: (claim) => _onTap(context, ref, g, claim, uid),
            onLongPress: (claim) => _onLongPress(ref, g, claim, uid),
            onCopy: () => _copyCode(context, g.inviteCode),
          );
        },
      ),
    );
  }

  void _onTap(
    BuildContext context,
    WidgetRef ref,
    GroupKhatma group,
    JuzClaim claim,
    String? uid,
  ) {
    final commands = ref.read(groupKhatmaCommandsProvider);
    final mine = claim.isClaimedBy(uid);
    switch (claim.status) {
      case JuzClaimStatus.unclaimed:
        HapticFeedback.selectionClick();
        commands.claim(group.id, claim.juzNumber);
      case JuzClaimStatus.claimed:
        if (mine) {
          HapticFeedback.selectionClick();
          commands.setCompleted(group.id, claim.juzNumber, completed: true);
        } else {
          _taken(context, claim);
        }
      case JuzClaimStatus.completed:
        if (mine) {
          HapticFeedback.selectionClick();
          commands.setCompleted(group.id, claim.juzNumber, completed: false);
        } else {
          _taken(context, claim);
        }
    }
  }

  void _onLongPress(
    WidgetRef ref,
    GroupKhatma group,
    JuzClaim claim,
    String? uid,
  ) {
    if (claim.isClaimedBy(uid) && claim.status != JuzClaimStatus.unclaimed) {
      HapticFeedback.mediumImpact();
      ref.read(groupKhatmaCommandsProvider).release(group.id, claim.juzNumber);
    }
  }

  void _taken(BuildContext context, JuzClaim claim) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.juzTakenBy(claim.juzNumber, claim.claimedName ?? ''),
        ),
      ),
    );
  }

  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).codeCopied)),
    );
  }

  Future<void> _confirmLeave(
    BuildContext context,
    WidgetRef ref,
    GroupKhatma group,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.leaveGroupTitle),
        content: Text(l10n.leaveGroupBody(group.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.leaveGroup),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(groupKhatmaCommandsProvider).leave(group.id);
      if (context.mounted) context.pop();
    }
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.group,
    required this.state,
    required this.currentUserId,
    required this.onTap,
    required this.onLongPress,
    required this.onCopy,
  });

  final GroupKhatma group;
  final GroupDetailState state;
  final String? currentUserId;
  final void Function(JuzClaim) onTap;
  final void Function(JuzClaim) onLongPress;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: KhatmaRing(
              completed: state.completedUnits,
              total: group.totalUnits,
              strokeWidth: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatNumber(context, state.completedUnits),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  Text(
                    '/ ${formatNumber(context, group.totalUnits)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _InviteCodeCard(code: group.inviteCode, onCopy: onCopy),
        if (state.isComplete) ...[
          const SizedBox(height: 16),
          _CompleteBanner(message: l10n.groupComplete),
        ],
        const SizedBox(height: 28),
        Text(l10n.sectionMembers, style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        _Members(members: state.members, currentUserId: currentUserId),
        const SizedBox(height: 28),
        Text(l10n.sectionAjza, style: theme.textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          l10n.tapToClaim,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        const _Legend(),
        const SizedBox(height: 14),
        GroupJuzGrid(
          total: group.totalUnits,
          claims: state.claims,
          currentUserId: currentUserId,
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      ],
    );
  }
}

class _InviteCodeCard extends StatelessWidget {
  const _InviteCodeCard({required this.code, required this.onCopy});

  final String code;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 10, 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.inviteCode,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              SelectableText(
                code,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const Spacer(),
          FilledButton.tonalIcon(
            onPressed: onCopy,
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: Text(l10n.copyCode),
          ),
        ],
      ),
    );
  }
}

class _Members extends StatelessWidget {
  const _Members({required this.members, required this.currentUserId});

  final List<GroupMember> members;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final m in members)
          Container(
            padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    m.displayName.trim().isEmpty
                        ? '؟'
                        : m.displayName.trim().substring(0, 1),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  m.userId == currentUserId ? l10n.claimedByYou : m.displayName,
                  style: theme.textTheme.labelLarge,
                ),
                if (m.isOwner) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.star_rounded,
                      size: 14, color: AppColors.gold),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        _LegendDot(color: scheme.surfaceContainerHighest, label: l10n.legendOpen,
            border: scheme.outlineVariant),
        _LegendDot(color: scheme.primaryContainer, label: l10n.legendYours,
            border: scheme.primary),
        _LegendDot(color: AppColors.gold.withValues(alpha: 0.16),
            label: l10n.legendTaken, border: AppColors.gold),
        _LegendDot(color: scheme.primary, label: l10n.legendDone,
            border: scheme.primary),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    required this.border,
  });

  final Color color;
  final String label;
  final Color border;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CompleteBanner extends StatelessWidget {
  const _CompleteBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded,
              color: theme.colorScheme.onSecondaryContainer, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
