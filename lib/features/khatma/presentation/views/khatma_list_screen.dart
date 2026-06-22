import 'package:flutter/material.dart';

import '../../../../l10n/gen/app_localizations.dart';

/// Placeholder list of the user's khatmas. Real content arrives in P1.
class KhatmaListScreen extends StatelessWidget {
  const KhatmaListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.khatmaTitle)),
      body: Center(child: Text(l10n.khatmaEmpty)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
