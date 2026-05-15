import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_theme.dart';
import '../domain/farm_levels.dart';
import '../domain/farm_simulation.dart';

class FarmGamePage extends StatefulWidget {
  const FarmGamePage({super.key});

  @override
  State<FarmGamePage> createState() => _FarmGamePageState();
}

class _FarmGamePageState extends State<FarmGamePage> {
  late FarmGameState _state;
  late final TextEditingController _codeController;
  CodeLanguage _language = CodeLanguage.python;
  int _levelIndex = 0;

  FarmLevel get _level => farmLevels[_levelIndex];

  @override
  void initState() {
    super.initState();
    _state = freshStateForLevel(_level);
    _codeController = TextEditingController(text: _level.starterFor(_language));
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _executeProgram() {
    setState(() {
      final nextState =
          runProgram(_state, _codeController.text, language: _language).state;
      final evaluation = evaluateFarmLevel(_level, nextState);
      _state = nextState.appendLog(
        evaluation.isComplete
            ? 'Nivel ${_level.number} completado.'
            : 'Objetivo pendiente: ${evaluation.firstOpen?.description ?? _level.goal}.',
      );
    });
  }

  void _resetFarm() {
    setState(() {
      _state = freshStateForLevel(_level);
      _codeController.text = _level.starterFor(_language);
    });
  }

  void _changeLanguage(CodeLanguage language) {
    setState(() {
      _language = language;
      _codeController.text = _level.starterFor(language);
    });
  }

  void _changeLevel(int levelIndex) {
    setState(() {
      _levelIndex = levelIndex;
      _state = freshStateForLevel(_level);
      _codeController.text = _level.starterFor(_language);
    });
  }

  void _previousLevel() {
    if (_levelIndex == 0) {
      return;
    }
    _changeLevel(_levelIndex - 1);
  }

  void _nextLevel() {
    if (_levelIndex == farmLevels.length - 1) {
      return;
    }
    _changeLevel(_levelIndex + 1);
  }

  void _unlock(Technology technology) {
    setState(() {
      _state = _state.unlock(technology);
    });
  }

  Future<void> _openMissionGuide() async {
    final selectedLevelIndex = await showDialog<int>(
      context: context,
      builder: (context) => _MissionGuideDialog(
        selectedLevelIndex: _levelIndex,
        language: _language,
      ),
    );
    if (selectedLevelIndex != null) {
      _changeLevel(selectedLevelIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final evaluation = evaluateFarmLevel(_level, _state);

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
              _FarmColumn(
                state: _state,
                level: _level,
                selectedLevelIndex: _levelIndex,
                evaluation: evaluation,
                onLevelChanged: _changeLevel,
                onPreviousLevel: _levelIndex == 0 ? null : _previousLevel,
                onNextLevel:
                    _levelIndex == farmLevels.length - 1 ? null : _nextLevel,
                onOpenGuide: _openMissionGuide,
              ),
              _AutomationColumn(
                state: _state,
                controller: _codeController,
                language: _language,
                onExecute: _executeProgram,
                onLanguageChanged: _changeLanguage,
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
                SizedBox(height: 980, child: children.first),
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
  const _FarmColumn({
    required this.state,
    required this.level,
    required this.selectedLevelIndex,
    required this.evaluation,
    required this.onLevelChanged,
    required this.onPreviousLevel,
    required this.onNextLevel,
    required this.onOpenGuide,
  });

  final FarmGameState state;
  final FarmLevel level;
  final int selectedLevelIndex;
  final FarmLevelEvaluation evaluation;
  final ValueChanged<int> onLevelChanged;
  final VoidCallback? onPreviousLevel;
  final VoidCallback? onNextLevel;
  final VoidCallback onOpenGuide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ManualPanel(
            level: level,
            selectedLevelIndex: selectedLevelIndex,
            evaluation: evaluation,
            onLevelChanged: onLevelChanged,
            onPreviousLevel: onPreviousLevel,
            onNextLevel: onNextLevel,
            onOpenGuide: onOpenGuide,
          ),
          const SizedBox(height: 14),
          _ResourceBar(
              resources: state.resources, executedSteps: state.executedSteps),
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

class _ManualPanel extends StatelessWidget {
  const _ManualPanel({
    required this.level,
    required this.selectedLevelIndex,
    required this.evaluation,
    required this.onLevelChanged,
    required this.onPreviousLevel,
    required this.onNextLevel,
    required this.onOpenGuide,
  });

  final FarmLevel level;
  final int selectedLevelIndex;
  final FarmLevelEvaluation evaluation;
  final ValueChanged<int> onLevelChanged;
  final VoidCallback? onPreviousLevel;
  final VoidCallback? onNextLevel;
  final VoidCallback onOpenGuide;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF1F3A2E), Color(0xFF101916)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Manual de misión',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  onPressed: onPreviousLevel,
                  tooltip: 'Nivel anterior',
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  onPressed: onNextLevel,
                  tooltip: 'Nivel siguiente',
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedLevelIndex,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Nivel'),
                    items: [
                      for (var index = 0; index < farmLevels.length; index++)
                        DropdownMenuItem(
                          value: index,
                          child: Text(
                            '${farmLevels[index].number}. ${farmLevels[index].title}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        onLevelChanged(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: onOpenGuide,
                  icon: const Icon(Icons.dashboard_customize),
                  label: const Text('Misiones'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final reference
                    in _functionReferences(CodeLanguage.python).take(4))
                  Chip(
                    avatar: const Icon(Icons.functions, size: 16),
                    label: Text(reference.pythonCall),
                    backgroundColor: Colors.white.withAlpha(16),
                    side: BorderSide(color: Colors.white.withAlpha(18)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Qué se busca',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text(
              'Escribe Python o Java para controlar el dron, transformar parcelas y cumplir el objetivo del nivel con una ejecución determinista.',
              style: TextStyle(color: Colors.white70, height: 1.3),
            ),
            const SizedBox(height: 10),
            Text(
              'Nivel ${level.number} de ${farmLevels.length}: ${level.title}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(level.briefing,
                style: const TextStyle(color: Colors.white70, height: 1.3)),
            const SizedBox(height: 6),
            Text('Objetivo: ${level.goal}',
                style: const TextStyle(
                    color: AppTheme.sprout, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Pista: ${level.hint}',
                style: const TextStyle(color: Colors.white60, height: 1.3)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final progress in evaluation.progress)
                  Chip(
                    avatar: Icon(
                      progress.isComplete
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 16,
                    ),
                    label: Text(
                      '${progress.description}: ${progress.currentText}',
                      overflow: TextOverflow.ellipsis,
                    ),
                    backgroundColor: progress.isComplete
                        ? AppTheme.sprout.withAlpha(40)
                        : Colors.white.withAlpha(18),
                    side: BorderSide(
                      color: progress.isComplete
                          ? AppTheme.sprout
                          : Colors.white.withAlpha(18),
                    ),
                  ),
              ],
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
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: farmSize),
        itemCount: farmSize * farmSize,
        itemBuilder: (context, index) {
          final x = index % farmSize;
          final y = index ~/ farmSize;
          final tile = state.tiles[y][x];
          final hasDrone = state.droneX == x && state.droneY == y;
          return _FarmCell(
              tile: tile,
              hasDrone: hasDrone,
              direction: state.direction,
              x: x,
              y: y);
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
              child: Text('$x,$y',
                  style: const TextStyle(fontSize: 10, color: Colors.white38)),
            ),
            Center(child: Text(icon, style: const TextStyle(fontSize: 28))),
            if (tile.watered)
              const Positioned(
                  right: 6,
                  bottom: 4,
                  child: Text('💧', style: TextStyle(fontSize: 14))),
            if (hasDrone)
              Center(
                child: Text(
                  _droneArrow(direction),
                  style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
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
    required this.language,
    required this.onExecute,
    required this.onLanguageChanged,
    required this.onUnlock,
  });

  final FarmGameState state;
  final TextEditingController controller;
  final CodeLanguage language;
  final VoidCallback onExecute;
  final ValueChanged<CodeLanguage> onLanguageChanged;
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
                          child: Text('Editor del dron',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w900)),
                        ),
                        FilledButton.icon(
                          onPressed: onExecute,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Ejecutar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SegmentedButton<CodeLanguage>(
                        segments: const [
                          ButtonSegment(
                            value: CodeLanguage.python,
                            label: Text('Python'),
                            icon: Icon(Icons.terminal),
                          ),
                          ButtonSegment(
                            value: CodeLanguage.java,
                            label: Text('Java'),
                            icon: Icon(Icons.code),
                          ),
                        ],
                        selected: {language},
                        onSelectionChanged: (selection) =>
                            onLanguageChanged(selection.first),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _syntaxHint(language),
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _CodeEditor(
                        controller: controller,
                        language: language,
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

class _CodeEditor extends StatefulWidget {
  const _CodeEditor({
    required this.controller,
    required this.language,
  });

  final TextEditingController controller;
  final CodeLanguage language;

  @override
  State<_CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<_CodeEditor> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(
      debugLabel: 'Drone code editor',
      onKeyEvent: (_, event) => _handleKeyEvent(event),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.tab) {
      if (HardwareKeyboard.instance.isShiftPressed) {
        _outdentSelection();
      } else {
        _insertText(_indentUnit(widget.language));
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      _insertText(_newlineIndent(widget.controller.text,
          widget.controller.selection.baseOffset, widget.language));
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _insertText(String text) {
    final value = widget.controller.value;
    final selection = value.selection;
    final start = selection.start < 0 ? value.text.length : selection.start;
    final end = selection.end < 0 ? value.text.length : selection.end;
    final normalizedStart = start < end ? start : end;
    final normalizedEnd = start < end ? end : start;
    final updatedText =
        value.text.replaceRange(normalizedStart, normalizedEnd, text);
    final caret = normalizedStart + text.length;
    widget.controller.value = value.copyWith(
      text: updatedText,
      selection: TextSelection.collapsed(offset: caret),
      composing: TextRange.empty,
    );
  }

  void _outdentSelection() {
    final value = widget.controller.value;
    final caret = value.selection.baseOffset;
    if (caret < 0) {
      return;
    }

    final lineStart = value.text.lastIndexOf('\n', caret - 1) + 1;
    final indent = _indentUnit(widget.language);
    final removeCount = value.text.startsWith(indent, lineStart)
        ? indent.length
        : _leadingRemovableSpaces(value.text, lineStart, caret, indent.length);
    if (removeCount == 0) {
      return;
    }

    final updatedText =
        value.text.replaceRange(lineStart, lineStart + removeCount, '');
    widget.controller.value = value.copyWith(
      text: updatedText,
      selection: TextSelection.collapsed(
          offset: (caret - removeCount).clamp(0, updatedText.length)),
      composing: TextRange.empty,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const ValueKey('drone-code-editor'),
      controller: widget.controller,
      focusNode: _focusNode,
      expands: true,
      maxLines: null,
      minLines: null,
      keyboardType: TextInputType.multiline,
      style:
          const TextStyle(fontSize: 14, height: 1.35, color: AppTheme.sprout),
      decoration:
          const InputDecoration(hintText: 'Escribe el plan del dron...'),
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
            const Text('Investigación',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: technologies.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final technology = technologies[index];
                  final unlocked = state.isTechUnlocked(technology.id);
                  final affordable =
                      state.resources.research >= technology.researchCost;
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: unlocked
                              ? AppTheme.sprout
                              : Colors.white.withAlpha(18)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(technology.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 3),
                        Text(technology.description,
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 12)),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: unlocked || !affordable
                              ? null
                              : () => onUnlock(technology),
                          icon: Icon(
                              unlocked ? Icons.check : Icons.science_outlined,
                              size: 16),
                          label: Text(unlocked
                              ? 'Activa'
                              : '${technology.researchCost} datos'),
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
            const Text('Terminal',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: AppTheme.terminal,
                    borderRadius: BorderRadius.circular(12)),
                child: ListView(
                  padding: const EdgeInsets.all(10),
                  children: [
                    for (final entry in log)
                      Text('> $entry',
                          style: const TextStyle(
                              color: AppTheme.cyan,
                              fontSize: 12,
                              height: 1.35)),
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

class _MissionGuideDialog extends StatelessWidget {
  const _MissionGuideDialog({
    required this.selectedLevelIndex,
    required this.language,
  });

  final int selectedLevelIndex;
  final CodeLanguage language;

  @override
  Widget build(BuildContext context) {
    final references = _functionReferences(language);

    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1040, maxHeight: 760),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF14261F), Color(0xFF0B1110)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Centro de misiones',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Elige un nivel y consulta las funciones del dron.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cerrar',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 6,
                        child: _LevelGallery(
                          selectedLevelIndex: selectedLevelIndex,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: _FunctionReferencePanel(references: references),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelGallery extends StatelessWidget {
  const _LevelGallery({required this.selectedLevelIndex});

  final int selectedLevelIndex;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withAlpha(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Niveles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                itemCount: farmLevels.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisExtent: 142,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final level = farmLevels[index];
                  final selected = selectedLevelIndex == index;
                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.of(context).pop(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.sprout.withAlpha(48)
                            : Colors.white.withAlpha(14),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? AppTheme.sprout
                              : Colors.white.withAlpha(20),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: selected
                                    ? AppTheme.sprout
                                    : AppTheme.cyan.withAlpha(48),
                                foregroundColor:
                                    selected ? AppTheme.terminal : Colors.white,
                                child: Text('${level.number}'),
                              ),
                              const Spacer(),
                              Icon(
                                selected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            level.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 5),
                          Expanded(
                            child: Text(
                              level.goal,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.25),
                            ),
                          ),
                        ],
                      ),
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

class _FunctionReferencePanel extends StatelessWidget {
  const _FunctionReferencePanel({required this.references});

  final List<_FunctionReference> references;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withAlpha(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Funciones del dron',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: references.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final reference = references[index];
                  return Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: AppTheme.terminal,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withAlpha(18)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reference.call,
                          style: const TextStyle(
                            color: AppTheme.sprout,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          reference.description,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.25),
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

class _FunctionReference {
  const _FunctionReference({
    required this.pythonCall,
    required this.javaCall,
    required this.description,
  });

  final String pythonCall;
  final String javaCall;
  final String description;

  String get call => pythonCall;
}

List<_FunctionReference> _functionReferences(CodeLanguage language) {
  final references = [
    const _FunctionReference(
      pythonCall: 'move()',
      javaCall: 'move();',
      description: 'Avanza una celda en la dirección actual.',
    ),
    const _FunctionReference(
      pythonCall: 'turn_left()',
      javaCall: 'turnLeft();',
      description: 'Gira el dron 90 grados hacia la izquierda.',
    ),
    const _FunctionReference(
      pythonCall: 'turn_right()',
      javaCall: 'turnRight();',
      description: 'Gira el dron 90 grados hacia la derecha.',
    ),
    const _FunctionReference(
      pythonCall: 'till()',
      javaCall: 'till();',
      description: 'Prepara la parcela actual para poder sembrar.',
    ),
    const _FunctionReference(
      pythonCall: 'plant("hay")',
      javaCall: 'plant("hay");',
      description:
          'Siembra heno. También existen carrot y pumpkin si están desbloqueados.',
    ),
    const _FunctionReference(
      pythonCall: 'water()',
      javaCall: 'water();',
      description: 'Riega el cultivo de la celda actual.',
    ),
    const _FunctionReference(
      pythonCall: 'harvest()',
      javaCall: 'harvest();',
      description: 'Cosecha un cultivo regado y suma recursos.',
    ),
    const _FunctionReference(
      pythonCall: 'scan()',
      javaCall: 'scan();',
      description: 'Lee la celda actual cuando el sensor está desbloqueado.',
    ),
  ];

  if (language == CodeLanguage.python) {
    return references;
  }

  return [
    for (final reference in references)
      _FunctionReference(
        pythonCall: reference.javaCall,
        javaCall: reference.javaCall,
        description: reference.description,
      ),
  ];
}

String _indentUnit(CodeLanguage language) {
  return switch (language) {
    CodeLanguage.python => '    ',
    CodeLanguage.java => '  ',
  };
}

String _newlineIndent(String text, int caretOffset, CodeLanguage language) {
  final safeCaret =
      caretOffset < 0 ? text.length : caretOffset.clamp(0, text.length);
  final lineStart = text.lastIndexOf('\n', safeCaret - 1) + 1;
  final line = text.substring(lineStart, safeCaret);
  final leadingWhitespace = RegExp(r'^\s*').firstMatch(line)?.group(0) ?? '';
  final trimmedRight = line.trimRight();
  final extraIndent =
      _opensBlock(trimmedRight, language) ? _indentUnit(language) : '';

  if (language == CodeLanguage.java && trimmedRight == '}') {
    final reduced = leadingWhitespace.length >= _indentUnit(language).length
        ? leadingWhitespace.substring(_indentUnit(language).length)
        : '';
    return '\n$reduced';
  }

  return '\n$leadingWhitespace$extraIndent';
}

bool _opensBlock(String line, CodeLanguage language) {
  return switch (language) {
    CodeLanguage.python => line.endsWith(':'),
    CodeLanguage.java => line.endsWith('{'),
  };
}

int _leadingRemovableSpaces(
    String text, int lineStart, int caret, int maxSpaces) {
  var removable = 0;
  final limit = caret.clamp(lineStart, text.length);
  for (var index = lineStart; index < limit && removable < maxSpaces; index++) {
    if (text.codeUnitAt(index) != 32) {
      break;
    }
    removable++;
  }
  return removable;
}

String _syntaxHint(CodeLanguage language) {
  return switch (language) {
    CodeLanguage.python =>
      'Python: move(), turn_left(), turn_right(), till(), plant("hay"), water(), harvest(), scan(), for _ in range(3):',
    CodeLanguage.java =>
      'Java: move(); turnLeft(); turnRight(); till(); plant("hay"); water(); harvest(); scan(); for (int i = 0; i < 3; i++) { }',
  };
}

String _droneArrow(Direction direction) {
  return switch (direction) {
    Direction.north => '▲',
    Direction.east => '▶',
    Direction.south => '▼',
    Direction.west => '◀',
  };
}
