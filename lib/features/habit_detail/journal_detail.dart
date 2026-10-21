import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/providers.dart';
import '../../core/domain/habit.dart';
import '../../core/icons/phosphor_icons.dart';
import '../../core/l10n/formatters.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/sorbet_colors.dart';
import '../../core/time/today_provider.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/segmented_strip.dart';
import '../../core/widgets/sorbet_card.dart';
import 'detail_scaffold.dart';

/// The habit's entries with their notes, which History leaves out.
final _entriesProvider = StreamProvider.family<List<HabitEntry>, int>(
  (ref, habitId) => ref
      .watch(habitRepositoryProvider)
      .watchEntries()
      .map(
        (all) => [
          for (final e in all)
            if (e.habitId == habitId) e,
        ],
      ),
);

const _moodIcons = [
  PhosphorIconsRegular.smileySad,
  PhosphorIconsRegular.smileyMeh,
  PhosphorIconsRegular.smiley,
  PhosphorIconsRegular.smileyWink,
];

int _lineCount(String text) =>
    text.split('\n').where((l) => l.trim().isNotEmpty).length;

/// T4: today's page (prompt, lines, mood) and the past entries.
class JournalDetail extends ConsumerStatefulWidget {
  const JournalDetail({super.key, required this.habit});

  final Habit habit;

  @override
  ConsumerState<JournalDetail> createState() => _JournalDetailState();
}

class _JournalDetailState extends ConsumerState<JournalDetail> {
  final _text = TextEditingController();
  var _tab = 0;
  var _prompt = 0;
  int? _mood;
  var _saved = false;
  var _loaded = false;

  @override
  void initState() {
    super.initState();
    _text.addListener(() {
      if (_saved) setState(() => _saved = false);
    });
    // Prefill once with today's entry; later saves must not reset the field.
    ref.listenManual(_entriesProvider(widget.habit.id), (_, next) {
      final entries = next.value;
      if (_loaded || entries == null) return;
      _loaded = true;
      final today = ref.read(todayProvider);
      final e = entries.where((e) => e.day == today).firstOrNull;
      if (e == null) return;
      _text.text = e.note ?? '';
      setState(() => _mood = e.mood);
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  int get _goal => math.max(1, widget.habit.goal.round());

  Future<void> _save(int lines) async {
    await ref
        .read(habitRepositoryProvider)
        .setEntry(
          HabitEntry(
            habitId: widget.habit.id,
            day: ref.read(todayProvider),
            value: lines.toDouble(),
            note: _text.text,
            mood: _mood,
          ),
        );
    if (mounted) setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final h = widget.habit;
    return DetailScaffold(
      habit: h,
      subtitle: '${l10n.journalLabel} · ${context.habitFormat.schedule(h)}',
      strip: Semantics(
        label: l10n.viewLabel,
        container: true,
        child: SegmentedStrip(
          count: 2,
          cellHeight: 40,
          selected: _tab,
          onSelected: (i) => setState(() => _tab = i),
          itemBuilder: (context, i, on) => Text(
            [l10n.tabToday, l10n.historyTab][i],
            style: text.bodyLarge!.copyWith(color: on ? c.ink : c.muted),
          ),
        ),
      ),
      bottom: _tab == 0
          ? ListenableBuilder(listenable: _text, builder: (_, _) => _cta())
          : null,
      children: _tab == 0
          ? [
              ListenableBuilder(listenable: _text, builder: (_, _) => _page()),
              const SizedBox(height: 12),
              _MoodCard(
                mood: _mood,
                tones: c.tones[h.color]!,
                onPick: (m) => setState(() {
                  _mood = m;
                  _saved = false;
                }),
              ),
            ]
          : [_History(habit: h)],
    );
  }

  Widget _cta() {
    final l10n = context.l10n;
    final lines = _lineCount(_text.text);
    if (lines >= _goal) {
      return PrimaryButton(
        label: _saved ? l10n.journalSaved : l10n.journalSave,
        onPressed: () => _save(lines),
      );
    }
    final c = context.sorbet;
    return Semantics(
      button: true,
      enabled: false,
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: c.shadowPill, offset: const Offset(0, 3)),
          ],
        ),
        child: Text(
          l10n.linesLeft(_goal - lines),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontSize: 19,
            fontWeight: FontWeight.w500,
            color: c.faint,
          ),
        ),
      ),
    );
  }

  Widget _page() {
    final l10n = context.l10n;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final tones = c.tones[widget.habit.color]!;
    final prompts = [
      l10n.journalPrompt1,
      l10n.journalPrompt2,
      l10n.journalPrompt3,
    ];
    final lines = math.min(_goal, _lineCount(_text.text));
    final page = text.bodyLarge!.copyWith(
      fontWeight: FontWeight.w400,
      height: 26 / 16,
    );
    final noBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    );
    return Container(
      // Top padding 8 instead of 16: the 8 px above and below the 32 px chip
      // are its 48 px tap area, the prompt gets them back as padding.
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: c.shadowPill, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    prompts[_prompt],
                    style: text.titleMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Semantics(
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _prompt = (_prompt + 1) % 3),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 32),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: c.bg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        l10n.otherQuestion,
                        style: text.labelMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: c.inkSoft,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _text,
            keyboardType: TextInputType.multiline,
            // 4 lines of 26 px + 12 + 8 = the mockup's 124 px; grows with text.
            minLines: 4,
            maxLines: null,
            style: page,
            decoration: InputDecoration(
              hintText: l10n.journalHint,
              hintStyle: page.copyWith(color: c.cellOffInk),
              filled: true,
              fillColor: tones.pale,
              contentPadding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              border: noBorder,
              enabledBorder: noBorder,
              focusedBorder: noBorder.copyWith(
                borderSide: BorderSide(color: c.selectedBorder, width: 2.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: ExcludeSemantics(
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: c.strip,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      spacing: 3,
                      children: [
                        for (var i = 0; i < _goal; i++)
                          Expanded(
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: i < lines ? tones.strong : null,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Text(
                l10n.valueLines(
                  context.habitFormat.number(lines),
                  context.habitFormat.number(_goal),
                  _goal,
                ),
                style: text.labelLarge!.copyWith(color: c.inkSoft),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  const _MoodCard({
    required this.mood,
    required this.tones,
    required this.onPick,
  });

  final int? mood;
  final HabitTones tones;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final labels = [l10n.mood0, l10n.mood1, l10n.mood2, l10n.mood3];
    return SorbetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.moodTitle, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 10),
          Semantics(
            label: l10n.moodLabel,
            container: true,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: c.strip,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < 4; i++)
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: i == mood,
                        inMutuallyExclusiveGroup: true,
                        label: labels[i],
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onPick(i),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: i == mood ? tones.base : null,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: i == mood
                                  ? [
                                      BoxShadow(
                                        color: tones.mid,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              _moodIcons[i],
                              size: 28,
                              color: i == mood ? c.ink : c.faint,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _History extends ConsumerWidget {
  const _History({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final fmt = context.habitFormat;
    final tones = c.tones[habit.color]!;
    final entries = [
      for (final e
          in ref.watch(_entriesProvider(habit.id)).value?.reversed ??
              const <HabitEntry>[])
        if (e.note?.trim().isNotEmpty ?? false) e,
    ];
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Text(
          l10n.noEntries,
          textAlign: TextAlign.center,
          style: text.bodySmall!.copyWith(color: c.muted),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        for (final e in entries)
          SorbetCard(
            radius: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    if (e.mood case final m?)
                      Icon(_moodIcons[m], size: 20, color: tones.ink),
                    Expanded(
                      child: Text(
                        _capitalized(fmt.longDate(e.day)),
                        style: text.bodyMedium,
                      ),
                    ),
                    Text(
                      l10n.linesCount(_lineCount(e.note!)),
                      style: text.labelMedium!.copyWith(color: c.muted),
                    ),
                  ],
                ),
                Text(
                  e.note!.trim(),
                  style: text.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                    color: c.inkSoft,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

String _capitalized(String s) => s[0].toUpperCase() + s.substring(1);
