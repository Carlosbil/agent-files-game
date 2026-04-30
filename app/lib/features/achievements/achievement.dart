class Achievement {
  const Achievement({
    required this.name,
    required this.icon,
    required this.unlocked,
  });

  final String name;
  final String icon;
  final bool unlocked;
}

final demoAchievements = <Achievement>[
  const Achievement(name: 'Inicio Estelar', icon: '⭐', unlocked: true),
  const Achievement(name: 'Cirujana de Prompts', icon: '🩺', unlocked: false),
  const Achievement(name: 'Guardiana de Tokens', icon: '💎', unlocked: false),
];
