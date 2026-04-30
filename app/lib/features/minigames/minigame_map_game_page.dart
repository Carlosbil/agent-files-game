import 'package:flutter/material.dart';

import 'minigame_catalog.dart';

const _stageSpacing = 156.0;
const _mapStartX = 56.0;
const _mapHeight = 318.0;

double _flagLeft(int index) => _mapStartX + index * _stageSpacing;

Color _worldAccent(MiniGameWorldId id) {
  return switch (id) {
    MiniGameWorldId.agents => const Color(0xFF2F80ED),
    MiniGameWorldId.skills => const Color(0xFF14A06F),
    MiniGameWorldId.instructions => const Color(0xFFE26A2C),
  };
}

Color _worldSoft(MiniGameWorldId id) {
  return switch (id) {
    MiniGameWorldId.agents => const Color(0xFFE9F2FF),
    MiniGameWorldId.skills => const Color(0xFFE7F8F0),
    MiniGameWorldId.instructions => const Color(0xFFFFEFE5),
  };
}

IconData _worldIcon(MiniGameWorldId id) {
  return switch (id) {
    MiniGameWorldId.agents => Icons.smart_toy_outlined,
    MiniGameWorldId.skills => Icons.extension_outlined,
    MiniGameWorldId.instructions => Icons.edit_note_outlined,
  };
}

class MiniGameMapGamePage extends StatefulWidget {
  const MiniGameMapGamePage({super.key});

  @override
  State<MiniGameMapGamePage> createState() => _MiniGameMapGamePageState();
}

class _MiniGameMapGamePageState extends State<MiniGameMapGamePage> {
  final ScrollController _mapScrollController = ScrollController();
  final Set<String> _completedChallengeIds = <String>{};

  String _selectedChallengeId = aiWorldRoute.first.id;
  String? _answeredOptionId;
  bool? _answerWasCorrect;

  WorldRouteProgress get _progress {
    return WorldRouteProgress(Set.unmodifiable(_completedChallengeIds));
  }

  WorldChallenge get _selectedChallenge {
    return challengeById(_selectedChallengeId);
  }

  @override
  void dispose() {
    _mapScrollController.dispose();
    super.dispose();
  }

  void _selectChallenge(WorldChallenge challenge) {
    if (!_progress.isUnlocked(challenge.id)) {
      return;
    }

    setState(() {
      _selectedChallengeId = challenge.id;
      _answeredOptionId = null;
      _answerWasCorrect = null;
    });
    _scrollToChallenge(indexOfChallenge(challenge.id));
  }

  void _answer(ChallengeOption option) {
    final challenge = _selectedChallenge;
    final isCorrect = challenge.isCorrect(option.id);

    setState(() {
      _answeredOptionId = option.id;
      _answerWasCorrect = isCorrect;

      if (isCorrect && _progress.isCurrent(challenge.id)) {
        _completedChallengeIds.add(challenge.id);
      }
    });

    if (isCorrect) {
      _scrollToChallenge(_progress.completedCount);
    }
  }

  void _retry() {
    setState(() {
      _answeredOptionId = null;
      _answerWasCorrect = null;
    });
  }

  void _continueRoute() {
    final progress = _progress;
    if (progress.isComplete) {
      Navigator.of(context).pop(true);
      return;
    }

    final nextChallenge = progress.nextChallenge!;
    setState(() {
      _selectedChallengeId = nextChallenge.id;
      _answeredOptionId = null;
      _answerWasCorrect = null;
    });
    _scrollToChallenge(indexOfChallenge(nextChallenge.id));
  }

  void _scrollToChallenge(int index) {
    final targetIndex = index.clamp(0, aiWorldRoute.length - 1).toInt();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_mapScrollController.hasClients) {
        return;
      }

      final target = (_flagLeft(targetIndex) - 120)
          .clamp(0.0, _mapScrollController.position.maxScrollExtent)
          .toDouble();

      _mapScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress;

    return Scaffold(
      appBar: AppBar(title: const Text('Ruta de Banderas IA')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: _RunHeader(progress: progress),
            ),
            SizedBox(
              height: _mapHeight,
              child: _WorldRouteMap(
                progress: progress,
                selectedChallenge: _selectedChallenge,
                controller: _mapScrollController,
                onChallengeTap: _selectChallenge,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: _ChallengePanel(
                  challenge: _selectedChallenge,
                  progress: progress,
                  answeredOptionId: _answeredOptionId,
                  answerWasCorrect: _answerWasCorrect,
                  onAnswer: _answer,
                  onRetry: _retry,
                  onContinue: _continueRoute,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RunHeader extends StatelessWidget {
  const _RunHeader({required this.progress});

  final WorldRouteProgress progress;

  @override
  Widget build(BuildContext context) {
    final world = progress.currentWorld;
    final accent = _worldAccent(world.id);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withAlpha(70)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _worldSoft(world.id),
                  foregroundColor: accent,
                  child: Icon(_worldIcon(world.id), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        progress.isComplete ? 'Ruta completada' : world.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        progress.isComplete
                            ? 'Has cruzado todos los submundos'
                            : world.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                _ProgressBadge(
                  label:
                      '${progress.completedCount}/${progress.totalChallenges}',
                  icon: Icons.flag_outlined,
                ),
                const SizedBox(width: 8),
                _ProgressBadge(
                  label: '${progress.earnedXp} XP',
                  icon: Icons.bolt_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress.progressRatio,
              minHeight: 8,
              borderRadius: BorderRadius.circular(999),
              backgroundColor: Colors.black.withAlpha(18),
              color: accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  const _ProgressBadge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorldRouteMap extends StatelessWidget {
  const _WorldRouteMap({
    required this.progress,
    required this.selectedChallenge,
    required this.controller,
    required this.onChallengeTap,
  });

  final WorldRouteProgress progress;
  final WorldChallenge selectedChallenge;
  final ScrollController controller;
  final ValueChanged<WorldChallenge> onChallengeTap;

  @override
  Widget build(BuildContext context) {
    final width =
        _mapStartX * 2 + (aiWorldRoute.length - 1) * _stageSpacing + 92;
    final playerIndex =
        progress.completedCount.clamp(0, aiWorldRoute.length - 1).toInt();

    return Scrollbar(
      controller: controller,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: SizedBox(
          width: width,
          height: _mapHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _WorldRoutePainter(
                    completedCount: progress.completedCount,
                  ),
                ),
              ),
              for (final world in miniGameWorlds) _WorldZoneLabel(world: world),
              for (var index = 0; index < aiWorldRoute.length; index++)
                _StageFlag(
                  challenge: aiWorldRoute[index],
                  index: index,
                  completed: progress.isCompleted(aiWorldRoute[index].id),
                  current: progress.isCurrent(aiWorldRoute[index].id),
                  unlocked: progress.isUnlocked(aiWorldRoute[index].id),
                  selected: selectedChallenge.id == aiWorldRoute[index].id,
                  onTap: () => onChallengeTap(aiWorldRoute[index]),
                ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutCubic,
                left: _flagLeft(playerIndex) - 2,
                bottom: 68,
                child: _PlayerMarker(worldId: progress.currentWorld.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorldZoneLabel extends StatelessWidget {
  const _WorldZoneLabel({required this.world});

  final MiniGameWorld world;

  @override
  Widget build(BuildContext context) {
    final start = worldStartIndex(world.id);
    final count = worldChallengeCount(world.id);
    final width = (count - 1) * _stageSpacing + 126;

    return Positioned(
      left: _flagLeft(start) - 38,
      top: 20,
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _worldSoft(world.id).withAlpha(228),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _worldAccent(world.id).withAlpha(60)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Icon(_worldIcon(world.id),
                  size: 18, color: _worldAccent(world.id)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  world.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _worldAccent(world.id),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageFlag extends StatelessWidget {
  const _StageFlag({
    required this.challenge,
    required this.index,
    required this.completed,
    required this.current,
    required this.unlocked,
    required this.selected,
    required this.onTap,
  });

  final WorldChallenge challenge;
  final int index;
  final bool completed;
  final bool current;
  final bool unlocked;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = unlocked ? _worldAccent(challenge.worldId) : Colors.grey;
    final flagColor = completed
        ? const Color(0xFF2DAA67)
        : current
            ? accent
            : unlocked
                ? _worldSoft(challenge.worldId)
                : const Color(0xFFE1E3E8);
    final foreground = completed || current ? Colors.white : accent;

    return Positioned(
      left: _flagLeft(index) - 30,
      bottom: 54,
      width: 112,
      child: Tooltip(
        message: unlocked ? challenge.title : 'Completa la bandera anterior',
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: unlocked ? onTap : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color:
                  selected ? Colors.white.withAlpha(230) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? accent : Colors.transparent,
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 84,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: 4,
                            height: 70,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B5F56),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          left: 38,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: flagColor,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                                topLeft: Radius.circular(2),
                                bottomLeft: Radius.circular(2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(30),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              width: 58,
                              height: 36,
                              child: Center(
                                child: Icon(
                                  completed
                                      ? Icons.check
                                      : unlocked
                                          ? Icons.flag
                                          : Icons.lock_outline,
                                  color: foreground,
                                  size: 19,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            foregroundColor: accent,
                            child: Text(
                              '${challenge.level}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge.fileFocus,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: unlocked ? Colors.black87 : Colors.black38,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerMarker extends StatelessWidget {
  const _PlayerMarker({required this.worldId});

  final MiniGameWorldId worldId;

  @override
  Widget build(BuildContext context) {
    final accent = _worldAccent(worldId);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(34),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.directions_walk,
          color: accent,
          size: 26,
        ),
      ),
    );
  }
}

class _ChallengePanel extends StatelessWidget {
  const _ChallengePanel({
    required this.challenge,
    required this.progress,
    required this.answeredOptionId,
    required this.answerWasCorrect,
    required this.onAnswer,
    required this.onRetry,
    required this.onContinue,
  });

  final WorldChallenge challenge;
  final WorldRouteProgress progress;
  final String? answeredOptionId;
  final bool? answerWasCorrect;
  final ValueChanged<ChallengeOption> onAnswer;
  final VoidCallback onRetry;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final world = worldFor(challenge.worldId);
    final accent = _worldAccent(challenge.worldId);
    final isAnswered = answeredOptionId != null;
    final isCorrect = answerWasCorrect == true;
    final completed = progress.isCompleted(challenge.id);
    final current = progress.isCurrent(challenge.id);
    final canAnswer = !isAnswered && (current || completed);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withAlpha(70)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _StatusChip(
                  icon: _worldIcon(world.id),
                  label: world.title,
                  color: accent,
                ),
                _StatusChip(
                  icon: completed ? Icons.check : Icons.flag_outlined,
                  label: completed
                      ? 'Bandera superada'
                      : current
                          ? 'Reto actual'
                          : 'Repaso',
                  color: completed ? const Color(0xFF2DAA67) : accent,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              challenge.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              challenge.mission,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            DecoratedBox(
              decoration: BoxDecoration(
                color: _worldSoft(challenge.worldId),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.help_outline, color: accent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        challenge.prompt,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            for (final option in challenge.options)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ChallengeOptionTile(
                  option: option,
                  accent: accent,
                  selected: answeredOptionId == option.id,
                  revealed: isAnswered,
                  correct: challenge.isCorrect(option.id),
                  enabled: canAnswer,
                  onTap: () => onAnswer(option),
                ),
              ),
            if (isAnswered) ...[
              _AnswerFeedback(
                correct: isCorrect,
                text: isCorrect
                    ? challenge.successText
                    : 'Casi. Busca la opcion que haga al agente mas fiable y facil de verificar.',
              ),
              const SizedBox(height: 12),
            ],
            if (isAnswered && !isCorrect)
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.replay),
                label: const Text('Reintentar bandera'),
              )
            else if (isCorrect)
              FilledButton.icon(
                onPressed: onContinue,
                icon: Icon(
                  progress.isComplete
                      ? Icons.emoji_events_outlined
                      : Icons.keyboard_arrow_right,
                ),
                label: Text(
                  progress.isComplete
                      ? 'Completar ruta con +120 XP'
                      : 'Caminar a la siguiente bandera',
                ),
              )
            else if (completed)
              OutlinedButton.icon(
                onPressed: onContinue,
                icon: const Icon(Icons.keyboard_arrow_right),
                label: const Text('Volver a la bandera actual'),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(62)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeOptionTile extends StatelessWidget {
  const _ChallengeOptionTile({
    required this.option,
    required this.accent,
    required this.selected,
    required this.revealed,
    required this.correct,
    required this.enabled,
    required this.onTap,
  });

  final ChallengeOption option;
  final Color accent;
  final bool selected;
  final bool revealed;
  final bool correct;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final successColor = const Color(0xFF2DAA67);
    final warningColor = const Color(0xFFD66A00);
    final borderColor = revealed && correct
        ? successColor
        : revealed && selected
            ? warningColor
            : selected
                ? accent
                : const Color(0xFFE4E7EF);
    final icon = revealed && correct
        ? Icons.check_circle
        : revealed && selected
            ? Icons.cancel_outlined
            : Icons.radio_button_unchecked;
    final iconColor = revealed && correct
        ? successColor
        : revealed && selected
            ? warningColor
            : accent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: enabled ? onTap : null,
        child: Ink(
          decoration: BoxDecoration(
            color: revealed && correct
                ? const Color(0xFFEFFFF7)
                : revealed && selected
                    ? const Color(0xFFFFF3E8)
                    : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        option.body,
                        style: const TextStyle(color: Colors.black54),
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

class _AnswerFeedback extends StatelessWidget {
  const _AnswerFeedback({
    required this.correct,
    required this.text,
  });

  final bool correct;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = correct ? const Color(0xFF2DAA67) : const Color(0xFFD66A00);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              correct ? Icons.check_circle_outline : Icons.tips_and_updates,
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorldRoutePainter extends CustomPainter {
  const _WorldRoutePainter({required this.completedCount});

  final int completedCount;

  @override
  void paint(Canvas canvas, Size size) {
    final skyRect = Offset.zero & size;
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFDDF3FF), Color(0xFFFFFAF2)],
      ).createShader(skyRect);
    canvas.drawRect(skyRect, skyPaint);

    for (final world in miniGameWorlds) {
      final start = worldStartIndex(world.id);
      final count = worldChallengeCount(world.id);
      final left = _flagLeft(start) - 46;
      final width = (count - 1) * _stageSpacing + 144;
      final zoneRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, 64, width, 168),
        const Radius.circular(16),
      );
      canvas.drawRRect(
        zoneRect,
        Paint()..color = _worldSoft(world.id).withAlpha(116),
      );
    }

    final groundTop = size.height - 62;
    final pathY = groundTop - 12;
    final pathPaint = Paint()
      ..color = const Color(0xFFE0C884)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final donePathPaint = Paint()
      ..color = const Color(0xFF2DAA67)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final start = Offset(_flagLeft(0) + 28, pathY);
    final end = Offset(_flagLeft(aiWorldRoute.length - 1) + 28, pathY);
    canvas.drawLine(start, end, pathPaint);

    final doneIndex = completedCount.clamp(0, aiWorldRoute.length - 1).toInt();
    final doneEnd = Offset(_flagLeft(doneIndex) + 28, pathY);
    canvas.drawLine(start, doneEnd, donePathPaint);

    final groundPaint = Paint()..color = const Color(0xFF62C37B);
    canvas.drawRect(
      Rect.fromLTWH(0, groundTop, size.width, size.height - groundTop),
      groundPaint,
    );
    final soilPaint = Paint()..color = const Color(0xFFD6A85E);
    canvas.drawRect(
      Rect.fromLTWH(0, groundTop + 28, size.width, size.height - groundTop),
      soilPaint,
    );

    final blockPaint = Paint()..color = const Color(0xFFFFD98A);
    for (var x = 8.0; x < size.width; x += 42) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, groundTop + 36, 24, 14),
          const Radius.circular(3),
        ),
        blockPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WorldRoutePainter oldDelegate) {
    return oldDelegate.completedCount != completedCount;
  }
}
