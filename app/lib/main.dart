import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'features/farm/presentation/farm_game_page.dart';

void main() {
  runApp(const DroneFarmApp());
}

class DroneFarmApp extends StatelessWidget {
  const DroneFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drone Farm Lab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const FarmGamePage(),
    );
  }
}
