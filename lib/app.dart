import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'data/finance_store.dart';
import 'features/home_shell.dart';

class ArtokuApp extends StatelessWidget {
  const ArtokuApp({super.key, required this.store});

  final FinanceStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARTOKU V2',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: HomeShell(store: store),
    );
  }
}
