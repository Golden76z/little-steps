import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/database/backup.dart';
import '../../core/database/providers.dart';
import '../../core/icons/phosphor_icons.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/sorbet_colors.dart';
import '../../core/time/today_provider.dart';
import '../../core/widgets/sorbet_sheet.dart';
import 'profile_screen.dart';

/// Hands a file to the system share sheet; swapped in tests.
final shareFileProvider = Provider<Future<void> Function(String, String)>(
  (ref) => (name, contents) async {
    final file = File('${(await getTemporaryDirectory()).path}/$name');
    await file.writeAsString(contents);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: 'application/json')]),
    );
  },
);

/// Lets the user pick a JSON file and returns its text, null if cancelled.
final pickFileProvider = Provider<Future<String?> Function()>(
  (ref) => () async {
    final file = await openFile(
      acceptedTypeGroups: const [
        // Android pickers filter by MIME type, and many apps label a .json
        // file as plain text or bytes: the content is checked anyway.
        XTypeGroup(
          label: 'JSON',
          extensions: ['json'],
          mimeTypes: [
            'application/json',
            'text/plain',
            'application/octet-stream',
          ],
        ),
      ],
    );
    return file?.readAsString();
  },
);

enum _DataAction { export, import }

/// Profile "My data": the sheet, then the chosen export or import.
Future<void> showDataSheet(BuildContext context, WidgetRef ref) async {
  final action = await showSorbetSheet<_DataAction>(
    context,
    (_) => const _DataSheet(),
  );
  if (!context.mounted) return;
  switch (action) {
    case _DataAction.export:
      await _export(context, ref);
    case _DataAction.import:
      await _import(context, ref);
    case null:
  }
}

Future<void> _export(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final now = ref.read(clockProvider)();
  final repo = ref.read(habitRepositoryProvider);
  final share = ref.read(shareFileProvider);
  try {
    final json = encodeBackup(await repo.readBackup(), now);
    final date = [
      now.year.toString().padLeft(4, '0'),
      now.month.toString().padLeft(2, '0'),
      now.day.toString().padLeft(2, '0'),
    ].join('-');
    await share('little-steps-$date.json', json);
  } catch (e, stack) {
    debugPrint('Little Steps: export failed: $e\n$stack');
    messenger.showSnackBar(SnackBar(content: Text(l10n.exportFailed)));
  }
}

Future<void> _import(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final c = context.sorbet;
  final messenger = ScaffoldMessenger.of(context);
  void toast(String text) => messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
  final repo = ref.read(habitRepositoryProvider);
  final pick = ref.read(pickFileProvider);
  final Backup backup;
  try {
    final source = await pick();
    if (source == null) return;
    backup = decodeBackup(source);
  } on Exception catch (e) {
    // FormatException, or a file that could not be read.
    debugPrint('Little Steps: import refused: $e');
    toast(l10n.importInvalid);
    return;
  }
  if (!context.mounted) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.importConfirmTitle),
      content: Text(l10n.importConfirmBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: c.danger),
          child: Text(l10n.importReplace),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    ref.read(dataReplacedProvider.notifier).bump();
    // One transaction: the streams, then the reminders, follow on commit.
    await repo.restore(backup);
    toast(l10n.importDone);
  } catch (e, stack) {
    debugPrint('Little Steps: import failed: $e\n$stack');
    toast(l10n.importFailed);
  }
}

class _DataSheet extends StatelessWidget {
  const _DataSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.sorbet;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetHeader(
          icon: PhosphorIconsRegular.export,
          color: c.habit[HabitColor.sky]!,
          title: l10n.dataSheetTitle,
          closeLabel: l10n.close,
        ),
        const SizedBox(height: 8),
        ProfileRow(
          leading: ProfileIconBox(
            color: c.habit[HabitColor.sky]!,
            icon: PhosphorIconsRegular.uploadSimple,
          ),
          label: l10n.exportJson,
          onTap: () => Navigator.pop(context, _DataAction.export),
        ),
        ProfileRow(
          leading: ProfileIconBox(
            color: c.habit[HabitColor.mint]!,
            icon: PhosphorIconsRegular.downloadSimple,
          ),
          label: l10n.importData,
          onTap: () => Navigator.pop(context, _DataAction.import),
          last: true,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.csvPremium,
          style: Theme.of(context).textTheme.bodySmall!
              .copyWith(color: c.muted),
        ),
      ],
    );
  }
}
