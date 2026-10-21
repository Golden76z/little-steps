import 'package:flutter/material.dart';

import '../../core/icons/phosphor_icons.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/sorbet_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/round_icon_button.dart';

// ponytail: placeholder until the Premium offer and its purchase flow exist.
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.sorbet;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: RoundIconButton(
                  icon: PhosphorIconsBold.x,
                  iconSize: 16,
                  label: l10n.close,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const Spacer(),
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: c.accent,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Icon(
                    PhosphorIconsFill.sparkle,
                    size: 36,
                    color: c.onAccent,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Semantics(
                header: true,
                child: Text(
                  l10n.premiumTitle,
                  textAlign: TextAlign.center,
                  style: text.headlineLarge,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  l10n.premiumBody,
                  textAlign: TextAlign.center,
                  style: text.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                    color: c.inkSoft,
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(label: l10n.premiumSoon, onPressed: null),
            ],
          ),
        ),
      ),
    );
  }
}
