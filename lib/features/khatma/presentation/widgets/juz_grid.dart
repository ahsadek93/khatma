import 'package:flutter/material.dart';
import 'package:khatmah/core/utils/formatting.dart';

/// A tap-to-toggle grid of every juz' in a khatma. Completed cells fill with the
/// primary (emerald); tapping reports the *desired* new state via [onToggle].
class JuzGrid extends StatelessWidget {
  const JuzGrid({
    super.key,
    required this.total,
    required this.completed,
    required this.onToggle,
  });

  final int total;
  final Set<int> completed;
  final void Function(int juz, bool completed) onToggle;

  @override
  Widget build(BuildContext context) {
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
        final done = completed.contains(juz);
        return _JuzCell(
          juz: juz,
          done: done,
          onTap: () => onToggle(juz, !done),
        );
      },
    );
  }
}

class _JuzCell extends StatelessWidget {
  const _JuzCell({required this.juz, required this.done, required this.onTap});

  final int juz;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: done ? scheme.primary : scheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: done ? Colors.transparent : scheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (done)
                Icon(Icons.check_rounded, size: 15, color: scheme.onPrimary),
              Text(
                formatNumber(context, juz),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  color: done ? scheme.onPrimary : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
