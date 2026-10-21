import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/habit.dart';
import '../../core/icons/habit_icons.dart';
import '../../core/icons/phosphor_icons.dart';
import '../../core/l10n/l10n.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/sorbet_colors.dart';
import '../../core/widgets/primary_button.dart';
import 'create_flow.dart';
import 'draft_provider.dart';
import 'habit_draft.dart';
import 'labels.dart';

/// P1: pick a popular habit or a type.
class ChooseTypeScreen extends ConsumerStatefulWidget {
  const ChooseTypeScreen({super.key});

  @override
  ConsumerState<ChooseTypeScreen> createState() => _ChooseTypeScreenState();
}

const _popular = [
  Preset.water,
  Preset.read,
  Preset.draw,
  Preset.run,
  Preset.vitamins,
  Preset.gratitude,
];

class _ChooseTypeScreenState extends ConsumerState<ChooseTypeScreen> {
  HabitType _type = HabitType.quantity;
  Preset? _preset;
  String _query = '';

  void _continue(AppLocalizations l10n) {
    final name = _query.trim();
    ref
        .read(draftProvider.notifier)
        .set(
          _preset == null
              ? HabitDraft.forType(_type).copyWith(name: name)
              : HabitDraft.fromPreset(
                  _preset!,
                  name: presetLabel(l10n, _preset!),
                ),
        );
    context.push(Routes.createSettings);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final query = _query.trim().toLowerCase();
    final popular = [
      for (final p in _popular)
        if (presetLabel(l10n, p).toLowerCase().contains(query)) p,
    ];
    return CreateFlowScaffold(
      step: 1,
      title: l10n.newHabit,
      closes: true,
      cta: PrimaryButton(
        label: l10n.continueWith(
          _preset == null ? typeName(l10n, _type) : presetLabel(l10n, _preset!),
        ),
        onPressed: () => _continue(l10n),
      ),
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: c.shadowPill, offset: const Offset(0, 3)),
            ],
          ),
          child: Row(
            spacing: 10,
            children: [
              Icon(
                PhosphorIconsRegular.magnifyingGlass,
                size: 19,
                color: c.muted,
              ),
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: text.bodyLarge!.copyWith(fontWeight: FontWeight.w400),
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    hintStyle: text.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w400,
                      color: c.muted,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    // The field itself fills the 48 px pill, for its tap target.
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (popular.isNotEmpty) ...[
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(child: Text(l10n.popular, style: text.titleSmall)),
                Text(
                  l10n.popularHint,
                  style: text.labelMedium!.copyWith(color: c.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, box) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in popular)
                  SizedBox(
                    width: (box.maxWidth - 16) / 3,
                    child: _PopularTile(
                      preset: p,
                      selected: p == _preset,
                      onTap: () => setState(() {
                        _preset = p;
                        _type = HabitDraft.fromPreset(p, name: '').type;
                      }),
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(l10n.orPickType, style: text.titleSmall),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: c.shadowPill, offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            children: [
              for (final t in HabitType.values)
                _TypeRow(
                  type: t,
                  selected: _preset == null && t == _type,
                  last: t == HabitType.values.last,
                  onTap: () => setState(() {
                    _type = t;
                    _preset = null;
                  }),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PopularTile extends StatelessWidget {
  const _PopularTile({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final Preset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final draft = HabitDraft.fromPreset(preset, name: '');
    final label = presetLabel(l10n, preset);
    final radius = BorderRadius.circular(20);
    return Semantics(
      button: true,
      selected: selected,
      label: '$label, ${typeName(l10n, draft.type)}',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          color: c.habit[draft.color],
          borderRadius: radius,
          boxShadow: selected
              ? null
              : [BoxShadow(color: c.floatShadow, offset: const Offset(0, 3))],
        ),
        // Inset ring drawn on top, so selecting does not shift the content.
        foregroundDecoration: selected
            ? BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: c.ink, width: 2.5),
              )
            : null,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 76),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(habitIcon(draft.icon), size: 22, color: c.ink),
                        const SizedBox(height: 14),
                        Text(
                          label,
                          style: text.labelLarge!.copyWith(height: 1.1),
                        ),
                      ],
                    ),
                  ),
                  PositionedDirectional(
                    top: 9,
                    end: 9,
                    child: Container(
                      height: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: c.badge,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        typeName(l10n, draft.type),
                        style: text.labelSmall!.copyWith(
                          fontSize: 10.5,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeRow extends StatelessWidget {
  const _TypeRow({
    required this.type,
    required this.selected,
    required this.last,
    required this.onTap,
  });

  final HabitType type;
  final bool selected;
  final bool last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    final draft = HabitDraft.forType(type);
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            border: last
                ? null
                : Border(bottom: BorderSide(color: c.sheetDivider, width: 1.5)),
          ),
          child: Row(
            spacing: 12,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c.habit[draft.color],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(habitIcon(draft.icon), size: 19, color: c.ink),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(typeName(l10n, type), style: text.bodyMedium),
                    Text(
                      typeExample(l10n, type),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.labelMedium!.copyWith(
                        fontSize: 12.5,
                        color: c.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.surface,
                  border: Border.all(
                    color: selected ? c.accent : c.radioOff,
                    width: selected ? 7 : 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
