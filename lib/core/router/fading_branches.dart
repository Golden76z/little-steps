import 'package:flutter/widgets.dart';

import '../theme/motion.dart';

/// The tab branches, kept alive like an IndexedStack; the tab you switch
/// to fades in and rises a few pixels.
class FadingBranches extends StatefulWidget {
  const FadingBranches({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  State<FadingBranches> createState() => _FadingBranchesState();
}

class _FadingBranchesState extends State<FadingBranches>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, value: 1);
  late final _curve = CurvedAnimation(parent: _controller, curve: Motion.curve);
  late final _rise = Tween(
    begin: const Offset(0, 0.015),
    end: Offset.zero,
  ).animate(_curve);

  @override
  void didUpdateWidget(FadingBranches old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      _controller.duration = context.motion(Motion.medium);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IndexedStack(
    index: widget.index,
    sizing: StackFit.expand,
    children: [
      for (final (i, child) in widget.children.indexed)
        // Same wrapper for every branch, so switching never rebuilds their state.
        FadeTransition(
          key: ValueKey('branch-$i'),
          opacity: i == widget.index ? _curve : kAlwaysCompleteAnimation,
          child: SlideTransition(
            position: i == widget.index
                ? _rise
                : const AlwaysStoppedAnimation(Offset.zero),
            child: TickerMode(enabled: i == widget.index, child: child),
          ),
        ),
    ],
  );
}
