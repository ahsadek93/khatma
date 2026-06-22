import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khatmah/features/group_khatma/group_khatma_providers.dart';
import 'package:khatmah/features/group_khatma/presentation/view_models/group_khatma_view_models.dart';
import 'package:khatmah/l10n/gen/app_localizations.dart';

/// Form to start a shared khatma: a name for the khatma and the display name
/// other members will see.
class CreateGroupKhatmaScreen extends ConsumerStatefulWidget {
  const CreateGroupKhatmaScreen({super.key});

  @override
  ConsumerState<CreateGroupKhatmaScreen> createState() =>
      _CreateGroupKhatmaScreenState();
}

class _CreateGroupKhatmaScreenState
    extends ConsumerState<CreateGroupKhatmaScreen> {
  final _title = TextEditingController();
  late final TextEditingController _name =
      TextEditingController(text: ref.read(displayNameControllerProvider));
  var _submitting = false;

  @override
  void dispose() {
    _title.dispose();
    _name.dispose();
    super.dispose();
  }

  bool get _valid =>
      _title.text.trim().isNotEmpty && _name.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_valid || _submitting) return;
    setState(() => _submitting = true);
    final name = _name.text.trim();
    try {
      await ref.read(displayNameControllerProvider.notifier).set(name);
      final group = await ref.read(groupKhatmaCommandsProvider).create(
            title: _title.text.trim(),
            displayName: name,
          );
      if (mounted) context.pushReplacement('/khatma/group/${group.id}');
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).genericError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newGroupKhatma)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _Label(l10n.groupNameLabel),
          const SizedBox(height: 8),
          TextField(
            controller: _title,
            autofocus: true,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(hintText: l10n.groupNameHint),
          ),
          const SizedBox(height: 24),
          _Label(l10n.yourNameLabel),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(hintText: l10n.yourNameHint),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _valid && !_submitting ? _submit : null,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : Text(l10n.createGroupButton),
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
      style: Theme.of(context)
          .textTheme
          .labelLarge
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
