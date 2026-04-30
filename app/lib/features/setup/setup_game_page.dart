import 'package:flutter/material.dart';

import 'champion_setup.dart';

class SetupGamePage extends StatefulWidget {
  const SetupGamePage({super.key});

  @override
  State<SetupGamePage> createState() => _SetupGamePageState();
}

class _SetupGamePageState extends State<SetupGamePage> {
  final _nameController = TextEditingController(text: 'Campeón');
  String? _role;
  String? _power;
  String? _goal;
  bool _submitted = false;

  ChampionSetup get _setup {
    return ChampionSetup(
      name: _nameController.text,
      role: _role,
      power: _power,
      goal: _goal,
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_refreshSetup);
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_refreshSetup)
      ..dispose();
    super.dispose();
  }

  void _refreshSetup() {
    setState(() {});
  }

  void _completeSetup() {
    setState(() {
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final setup = _setup;

    return Scaffold(
      appBar: AppBar(title: const Text('Setup de Campeón')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SetupScoreCard(score: setup.score),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Campeón',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                textInputAction: TextInputAction.done,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ChoiceGroup(
            title: 'Rol',
            icon: Icons.person_search_outlined,
            options: championRoles,
            selected: _role,
            onSelected: (value) => setState(() => _role = value),
          ),
          const SizedBox(height: 12),
          _ChoiceGroup(
            title: 'Fortaleza',
            icon: Icons.auto_awesome_outlined,
            options: championPowers,
            selected: _power,
            onSelected: (value) => setState(() => _power = value),
          ),
          const SizedBox(height: 12),
          _ChoiceGroup(
            title: 'Objetivo inicial',
            icon: Icons.flag_outlined,
            options: championGoals,
            selected: _goal,
            onSelected: (value) => setState(() => _goal = value),
          ),
          const SizedBox(height: 16),
          if (_submitted) _SetupResult(setup: setup),
          const SizedBox(height: 8),
          if (!_submitted)
            FilledButton.icon(
              onPressed: setup.isComplete ? _completeSetup : null,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Completar setup'),
            )
          else
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver con +80 XP'),
            ),
        ],
      ),
    );
  }
}

class _SetupScoreCard extends StatelessWidget {
  const _SetupScoreCard({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6FB5), Color(0xFF7AE7C7)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perfil del Campeón',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$score / 100 puntos de setup',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: score / 100),
        ],
      ),
    );
  }
}

class _ChoiceGroup extends StatelessWidget {
  const _ChoiceGroup({
    required this.title,
    required this.icon,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final IconData icon;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                return ChoiceChip(
                  label: Text(option),
                  selected: selected == option,
                  onSelected: (_) => onSelected(option),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupResult extends StatelessWidget {
  const _SetupResult({required this.setup});

  final ChampionSetup setup;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFEFFFF8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.emoji_events_outlined),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                setup.feedback,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
