import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khatmah/features/group_khatma/group_khatma_providers.dart';
import 'package:khatmah/features/group_khatma/presentation/view_models/group_khatma_view_models.dart';
import 'package:khatmah/l10n/gen/app_localizations.dart';

/// Form to join a shared khatma with an invite code + a display name.
class JoinGroupKhatmaScreen extends ConsumerStatefulWidget {
  const JoinGroupKhatmaScreen({super.key});

  @override
  ConsumerState<JoinGroupKhatmaScreen> createState() =>
      _JoinGroupKhatmaScreenState();
}

class _JoinGroupKhatmaScreenState extends ConsumerState<JoinGroupKhatmaScreen> {
  final _code = TextEditingController();
  late final TextEditingController _name =
      TextEditingController(text: ref.read(displayNameControllerProvider));
  var _submitting = false;

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    super.dispose();
  }

  bool get _valid =>
      _code.text.trim().length >= 4 && _name.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_valid || _submitting) return;
    setState(() => _submitting = true);
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    try {
      await ref.read(displayNameControllerProvider.notifier).set(name);
      final group = await ref.read(groupKhatmaCommandsProvider).join(
            code: _code.text.trim(),
            displayName: name,
          );
      if (mounted) context.pushReplacement('/khatma/group/${group.id}');
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.invalidInviteCode)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.joinWithCode)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _Label(l10n.inviteCodeLabel),
          const SizedBox(height: 8),
          TextField(
            controller: _code,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              UpperCaseFormatter(),
              LengthLimitingTextInputFormatter(8),
            ],
            style: const TextStyle(letterSpacing: 4, fontWeight: FontWeight.w700),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(hintText: l10n.inviteCodeHint),
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
                : Text(l10n.joinButton),
          ),
        ],
      ),
    );
  }
}

/// Forces invite-code input to upper case as the user types.
class UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
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
