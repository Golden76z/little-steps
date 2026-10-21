import 'package:flutter/material.dart';

/// Stand-in body for screens not built yet; shows only their title.
// ponytail: removed screen by screen as steps 3 to 6 land.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: Theme.of(context).textTheme.headlineLarge),
    );
  }
}
