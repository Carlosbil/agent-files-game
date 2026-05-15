import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../domain/farm_simulation.dart';

class FarmGamePage extends StatefulWidget {
  const FarmGamePage({super.key});

  @override
  State<FarmGamePage> createState() => _FarmGamePageState();
}

class _FarmGamePageState extends State<FarmGamePage> {
  late FarmGameState _state;
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _state = FarmGameState.initial();
    _codeController = TextEditingController(text: defaultProgram);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _executeProgram() {
    setState(() {
      _state = runProgram(_state, _codeController.text).state;
    });
  }

  void _resetFarm() {
    setState(() {
      _state = FarmGameState.initial();
      _codeController.text = defaultProgram;
    });
  }

  void _unlock(Technology technology) {
    setState(() {
      _state = _state.unlock(technology);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drone Farm Lab'),
        actions: [
          TextButton.icon(
            onPressed: _resetFarm,
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reiniciar'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            final children = [
              _FarmColumn(state: _state),
              _AutomationColumn(
                state: _state,
                controller: _codeController,
                onExecute: _executeProgram,
                onUnlock: _unlock,
              ),
            ];

            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 6, child: children.first),
                  Expanded(flex: 5, child: children.last),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                SizedBox(height: 760, child: children.first),
                SizedBox(height: 820, child: children.last),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FarmColumn extends StatelessWidget {
  const _FarmColumn({required this.state});

  final FarmGameState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _HeroBriefing(),
          const SizedBox(height: 14),
          _ResourceBar(resources: state.resources, executedSteps: state.executedSteps),
          const SizedBox(height: 14),
          Expanded(
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: _FarmGrid(state: state),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBriefing extends StatelessWidget {
  const _HeroBriefing();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF1F3A2E), Color(0xFF101916)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'La granja ya no necesita manos: necesita un algoritmo.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 8),
            Text(
              'Programa el dron con comandos simples, automatiza parcelas, cosecha recursos e investiga nuevas tecnologías para escalar la producción.',
              style: TextStyle(color: Colors.white70, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceBar extends StatelessWidget {
  const _ResourceBar({required this.resources, required this.executedSteps});

  final ResourceBag resources;
  final int executedSteps;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('🌱', 'Semillas', resources.seeds),
      ('💧', 'Agua', resources.water),
      ('🌾', 'Heno', resources.hay),
      ('🥕', 'Zanahorias', resources.carrots),
      ('🎃', 'Calabazas', resources.pumpkins),
      ('🔬', 'Datos', resources.research),
      ('⚙', 'Pasos', executedSteps),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final item in items)
          Chip(
            avatar: Text(item.$1),
            label: Text('${item.$2}: ${item.$3}'),
            backgroundColor: Colors.white.withAlpha(18),
            side: BorderSide(color: Colors.white.withAlpha(18)),
          ),
      ],
    );
  }
}

class _FarmGrid extends StatelessWidget {
  const _FarmGrid({required this.state});

  final FarmGameState state;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: farmSize),
        itemCount: farmSize * farmSize,
        itemBuilder: (context, index) {
          final x = index % farmSize;
          final y = index ~/ farmSize;
          final tile = state.tiles[y][x];
          final hasDrone = state.droneX == x && state.droneY == y;
          return _FarmCell(tile: tile, hasDrone: hasDrone, direction: state.direction, x: x, y: y);
        },
      ),
    );
  }
}

class _FarmCell extends StatelessWidget {
  const _FarmCell({
    required this.tile,
    required this.hasDrone,
    required this.direction,
    required this.x,
    required this.y,
  });

  final FarmTile tile;
  final bool hasDrone;
  final Direction direction;
  final int x;
  final int y;

  @override
  Widget build(BuildContext context) {
    final icon = tile.crop?.icon ?? (tile.tilled ? '▤' : '·');
    final background = tile.tilled ? AppTheme.soilLight : AppTheme.soil;

    return Semantics(
      label: 'Parcela $x $y',
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasDrone ? AppTheme.cyan : Colors.black.withAlpha(70),
            width: hasDrone ? 3 : 1,
          ),
          boxShadow: hasDrone
              ? [BoxShadow(color: AppTheme.cyan.withAlpha(90), blurRadius: 12)]
              : null,
        ),
        child: Stack(
          children: [
            Positioned(
              left: 6,
              top: 5,
              child: Text('$x,$y', style: const TextStyle(fontSize: 10, color: Colors.white38)),
            ),
            Center(child: Text(icon, style: const TextStyle(fontSize: 28))),
            if (tile.watered)
              const Positioned(right: 6, bottom: 4, child: Text('💧', style: TextStyle(fontSize: 14))),
            if (hasDrone)
              Center(
                child: Text(
                  _droneArrow(direction),
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AutomationColumn extends StatelessWidget {
  const _AutomationColumn({
    required this.state,
    required this.controller,
    required this.onExecute,
    required this.onUnlock,
  });

  final FarmGameState state;
  final TextEditingController controller;
  final VoidCallback onExecute;
  final ValueChanged<Technology> onUnlock;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Editor del dron', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                        ),
                        FilledButton.icon(
                          onPressed: onExecute,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Ejecutar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Comandos: move, turn_left, turn_right, till, plant hay, water, harvest, scan y repeat N { ... }',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        expands: true,
                        maxLines: null,
                        minLines: null,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(fontSize: 14, height: 1.35, color: AppTheme.sprout),
                        decoration: const InputDecoration(hintText: 'Escribe el plan del dron...'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            flex: 4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _TechPanel(state: state, onUnlock: onUnlock)),
                const SizedBox(width: 12),
                Expanded(child: _LogPanel(log: state.log)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TechPanel extends StatelessWidget {
  const _TechPanel({required this.state, required this.onUnlock});

  final FarmGameState state;
  final ValueChanged<Technology> onUnlock;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Investigación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: technologies.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final technology = technologies[index];
                  final unlocked = state.isTechUnlocked(technology.id);
                  final affordable = state.resources.research >= technology.researchCost;
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: unlocked ? AppTheme.sprout : Colors.white.withAlpha(18)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(technology.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 3),
                        Text(technology.description, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: unlocked || !affordable ? null : () => onUnlock(technology),
                          icon: Icon(unlocked ? Icons.check : Icons.science_outlined, size: 16),
                          label: Text(unlocked ? 'Activa' : '${technology.researchCost} datos'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogPanel extends StatelessWidget {
  const _LogPanel({required this.log});

  final List<String> log;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Terminal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(color: AppTheme.terminal, borderRadius: BorderRadius.circular(12)),
                child: ListView(
                  padding: const EdgeInsets.all(10),
                  children: [
                    for (final entry in log)
                      Text('> $entry', style: const TextStyle(color: AppTheme.cyan, fontSize: 12, height: 1.35)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _droneArrow(Direction direction) {
  return switch (direction) {
    Direction.north => '▲',
    Direction.east => '▶',
    Direction.south => '▼',
    Direction.west => '◀',
  };
}
