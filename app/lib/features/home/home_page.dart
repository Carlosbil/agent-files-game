import 'package:flutter/material.dart';

import '../achievements/achievement.dart';
import '../quests/quest.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final quests = [...phaseOneQuests, ...phaseTwoQuests];
    final totalXp = quests.where((q) => q.completed).fold<int>(0, (sum, q) => sum + q.xp);

    return Scaffold(
      appBar: AppBar(title: const Text('Cute Quests AI 🎀')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProgressBanner(totalXp: totalXp),
          const SizedBox(height: 14),
          const Text('Quests por fases', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...quests.map((q) => _QuestTile(quest: q)),
          const SizedBox(height: 18),
          const Text('Logros', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: demoAchievements.map((a) => Chip(label: Text('${a.icon} ${a.name} ${a.unlocked ? '✓' : '🔒'}'))).toList(),
          )
        ],
      ),
    );
  }
}

class _ProgressBanner extends StatelessWidget {
  const _ProgressBanner({required this.totalXp});

  final int totalXp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFF6FB5), Color(0xFF7C4DFF)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nivel 2 · Aventurera Cute', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('XP acumulada: $totalXp', style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          const LinearProgressIndicator(value: 0.42),
          const SizedBox(height: 8),
          const Text('Siguiente premio: skin "Capybara Cósmico"', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _QuestTile extends StatelessWidget {
  const _QuestTile({required this.quest});

  final Quest quest;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: quest.completed ? Colors.green.shade100 : Colors.orange.shade100,
          child: Text(quest.completed ? '✅' : '🎯'),
        ),
        title: Text(quest.title),
        subtitle: Text('Fase ${quest.phase} · ${quest.description}'),
        trailing: Text('+${quest.xp} XP', style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
