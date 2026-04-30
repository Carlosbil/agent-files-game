import 'package:flutter/material.dart';

import '../achievements/achievement.dart';
import '../minigames/minigame_map_game_page.dart';
import '../quests/quest.dart';
import '../setup/setup_game_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Set<String> _completedQuestIds;

  @override
  void initState() {
    super.initState();
    final quests = [...phaseOneQuests, ...phaseTwoQuests];
    _completedQuestIds = {
      for (final quest in quests)
        if (quest.completed) quest.id,
    };
  }

  Future<void> _openQuest(Quest quest) async {
    final Widget? page = switch (quest.id) {
      'f1-01' => const SetupGamePage(),
      'f1-02' => const MiniGameMapGamePage(),
      _ => null,
    };

    if (page == null) {
      return;
    }

    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => page),
    );

    if (!mounted || completed != true) {
      return;
    }

    setState(() {
      _completedQuestIds.add(quest.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final quests = [...phaseOneQuests, ...phaseTwoQuests];
    final totalXp = quests
        .where((q) => _completedQuestIds.contains(q.id))
        .fold<int>(0, (sum, q) => sum + q.xp);

    return Scaffold(
      appBar: AppBar(title: const Text('Cute Quests AI 🎀')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProgressBanner(totalXp: totalXp),
          const SizedBox(height: 14),
          const Text('Quests por fases',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...quests.map(
            (q) => _QuestTile(
              quest: q,
              completed: _completedQuestIds.contains(q.id),
              onTap: q.phase == 1 ? () => _openQuest(q) : null,
            ),
          ),
          const SizedBox(height: 18),
          const Text('Logros',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: demoAchievements
                .map((a) => Chip(
                    label:
                        Text('${a.icon} ${a.name} ${a.unlocked ? '✓' : '🔒'}')))
                .toList(),
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
    final level = totalXp >= 200
        ? 'Nivel 2 · Campeón Cute'
        : 'Nivel 1 · Campeón en setup';
    final progress = (totalXp / 200).clamp(0, 1).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFF6FB5), Color(0xFF7C4DFF)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(level,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('XP acumulada: $totalXp',
              style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 8),
          const Text('Siguiente premio: skin "Campeón Cósmico"',
              style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _QuestTile extends StatelessWidget {
  const _QuestTile({
    required this.quest,
    required this.completed,
    required this.onTap,
  });

  final Quest quest;
  final bool completed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final playable = onTap != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor:
              completed ? Colors.green.shade100 : Colors.orange.shade100,
          child: Icon(
            completed ? Icons.check : Icons.flag_outlined,
            size: 20,
          ),
        ),
        title: Text(quest.title),
        subtitle: Text('Fase ${quest.phase} · ${quest.description}'),
        trailing: playable
            ? FilledButton.tonalIcon(
                onPressed: onTap,
                icon: Icon(completed ? Icons.replay : Icons.play_arrow),
                label: Text(completed ? 'Rejugar' : '+${quest.xp} XP'),
              )
            : Text(
                '+${quest.xp} XP',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
