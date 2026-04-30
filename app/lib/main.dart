import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'features/home/home_page.dart';

void main() {
  runApp(const CuteQuestsApp());
}

class CuteQuestsApp extends StatelessWidget {
  const CuteQuestsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cute Quests AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomePage(),
    );
  }
}
