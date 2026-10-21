import 'package:converto/core/layout.dart';
import 'package:converto/features/convert/application/conversion_controller.dart';
import 'package:converto/features/convert/application/conversion_state.dart';
import 'package:converto/features/convert/presentation/progress_view.dart';
import 'package:converto/features/home/pick_view.dart';
import 'package:converto/features/home/ready_view.dart';
import 'package:converto/features/result/result_view.dart';
import 'package:converto/features/settings/about_page.dart';
import 'package:converto/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(conversionControllerProvider);
    ref.listen(conversionControllerProvider, (previous, next) {
      if (next is RunningState && previous is! RunningState) {
        WakelockPlus.enable();
      } else if (next is! RunningState && previous is RunningState) {
        WakelockPlus.disable();
      }
      if (next is PasswordNeededState) _askPassword(context, ref, next);
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            tooltip: l10n.settingsTooltip,
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AboutPage()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentMaxWidth(context)),
            child: AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey(_keyFor(state)),
                child: switch (state) {
                  IdleState() => PickView(failure: state.failure),
                  LoadingState() || PasswordNeededState() => _Loading(label: l10n.loading),
                  ReadyState() => ReadyView(
                    sources: state.sources,
                    targets: state.targets,
                    failure: state.failure,
                  ),
                  RunningState() => ProgressView(
                    converter: state.converter,
                    progress: state.progress,
                    detail: state.detail,
                  ),
                  DoneState() => ResultView(
                    sources: state.sources,
                    result: state.result,
                  ),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _keyFor(FlowState state) => switch (state) {
    IdleState() => 'idle',
    LoadingState() || PasswordNeededState() => 'loading',
    ReadyState() => 'ready',
    RunningState() => 'running',
    DoneState() => 'done',
  };

  Future<void> _askPassword(
    BuildContext context,
    WidgetRef ref,
    PasswordNeededState state,
  ) async {
    final controller = ref.read(conversionControllerProvider.notifier);
    final password = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PasswordDialog(
        name: state.current.name,
        wrong: state.wrongPassword,
      ),
    );
    if (password == null) {
      await controller.reset();
    } else {
      await controller.submitPassword(password);
    }
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      liveRegion: true,
      label: label,
      child: const CircularProgressIndicator(),
    ),
  );
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({required this.name, required this.wrong});

  final String name;
  final bool wrong;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _controller = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.passwordTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.passwordBody(widget.name)),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            obscureText: _obscure,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: l10n.passwordLabel,
              errorText: widget.wrong ? l10n.passwordWrong : null,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l10n.ok),
        ),
      ],
    );
  }
}
