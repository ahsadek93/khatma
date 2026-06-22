import 'package:flutter/material.dart';
import 'package:khatmah/core/theme/app_colors.dart';
import 'package:khatmah/core/utils/formatting.dart';
import 'package:khatmah/features/group_khatma/domain/entities/juz_claim.dart';

/// A claim-aware grid of every juz in a shared khatma. Cells are colour-coded:
/// open (surface), yours (emerald-tinted), taken by someone else (gold-tinted,
/// shows their initial), done (filled emerald). Tap/long-press are reported up.
class GroupJuzGrid extends StatelessWidget {
  const GroupJuzGrid({
    super.key,
    required this.total,
    required this.claims,
    required this.currentUserId,
    required this.onTap,
    required this.onLongPress,
  });

  final int total;
  final List<JuzClaim> claims;
  final String? currentUserId;
  final void Function(JuzClaim claim) onTap;
  final void Function(JuzClaim claim) onLongPress;

  @override
  Widget build(BuildContext context) {
    final byNumber = {for (final c in claims) c.juzNumber: c};
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: total,
      itemBuilder: (context, index) {
        final juz = index + 1;
        final claim = byNumber[juz] ?? JuzClaim(juzNumber: juz, completed: false);
        return _GroupJuzCell(
          claim: claim,
          mine: claim.isClaimedBy(currentUserId),
          onTap: () => onTap(claim),
          onLongPress: () => onLongPress(claim),
        );
      },
    );
  }
}

class _GroupJuzCell extends StatelessWidget {
  const _GroupJuzCell({
    required this.claim,
    required this.mine,
    required this.onTap,
    required this.onLongPress,
  });

  final JuzClaim claim;
  final bool mine;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    late final Color bg;
    late final Color fg;
    late final Color border;
    Widget? badge;

    switch (claim.status) {
      case JuzClaimStatus.completed:
        bg = mine ? scheme.primary : scheme.primary.withValues(alpha: 0.5);
        fg = scheme.onPrimary;
        border = Colors.transparent;
        badge = Icon(Icons.check_rounded, size: 14, color: fg);
      case JuzClaimStatus.claimed:
        if (mine) {
          bg = scheme.primaryContainer;
          fg = scheme.onPrimaryContainer;
          border = scheme.primary;
        } else {
          bg = AppColors.gold.withValues(alpha: 0.16);
          fg = scheme.onSurface;
          border = AppColors.gold.withValues(alpha: 0.55);
        }
      case JuzClaimStatus.unclaimed:
        bg = scheme.surfaceContainerHighest;
        fg = scheme.onSurfaceVariant;
        border = scheme.outlineVariant;
    }

    final showInitial = !mine &&
        claim.status != JuzClaimStatus.unclaimed &&
        (claim.claimedName?.trim().isNotEmpty ?? false);
    final initial =
        showInitial ? claim.claimedName!.trim().substring(0, 1) : null;

    return Material(
      color: bg,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: border),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ?badge,
                  Text(
                    formatNumber(context, claim.juzNumber),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      color: fg,
                    ),
                  ),
                ],
              ),
            ),
            if (initial != null)
              Positioned(
                top: 3,
                right: 4,
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: fg.withValues(alpha: 0.85),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
