import 'package:flutter/material.dart';

import '../../../../l10n/gen/app_localizations.dart';

/// Placeholder list of the user's adhkār/wird. Real content arrives in P2.
class WirdListScreen extends StatelessWidget {
  const WirdListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.wirdTitle)),
      body: Center(child: Text(l10n.wirdEmpty)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
