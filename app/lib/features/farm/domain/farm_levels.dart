import 'farm_simulation.dart';

enum FarmObjectiveComparison { atLeast, atMost, equals }

enum FarmObjectiveMetric {
  wateredTiles,
  tilledTiles,
  hayTiles,
  carrotTiles,
  pumpkinTiles,
  hayHarvest,
  carrotHarvest,
  pumpkinHarvest,
  totalHarvest,
  research,
  waterRemaining,
  executedSteps,
  dronePosition,
}

class FarmLevelObjective {
  const FarmLevelObjective({
    required this.description,
    required this.metric,
    required this.target,
    this.comparison = FarmObjectiveComparison.atLeast,
    this.targetY,
  });

  const FarmLevelObjective.droneAt({
    required this.description,
    required int x,
    required int y,
  })  : metric = FarmObjectiveMetric.dronePosition,
        target = x,
        targetY = y,
        comparison = FarmObjectiveComparison.equals;

  final String description;
  final FarmObjectiveMetric metric;
  final int target;
  final int? targetY;
  final FarmObjectiveComparison comparison;

  FarmObjectiveProgress progressFor(FarmGameState state) {
    if (metric == FarmObjectiveMetric.dronePosition) {
      final expectedY = targetY ?? 0;
      final completed = state.droneX == target && state.droneY == expectedY;
      return FarmObjectiveProgress(
        description: description,
        currentText:
            '(${state.droneX}, ${state.droneY}) / ($target, $expectedY)',
        isComplete: completed,
      );
    }

    final current = _currentMetricValue(state, metric);
    final completed = switch (comparison) {
      FarmObjectiveComparison.atLeast => current >= target,
      FarmObjectiveComparison.atMost => current <= target,
      FarmObjectiveComparison.equals => current == target,
    };
    final separator = switch (comparison) {
      FarmObjectiveComparison.atLeast => '/',
      FarmObjectiveComparison.atMost => '<=',
      FarmObjectiveComparison.equals => '=',
    };

    return FarmObjectiveProgress(
      description: description,
      currentText: '$current $separator $target',
      isComplete: completed,
    );
  }
}

class FarmObjectiveProgress {
  const FarmObjectiveProgress({
    required this.description,
    required this.currentText,
    required this.isComplete,
  });

  final String description;
  final String currentText;
  final bool isComplete;
}

class FarmLevel {
  const FarmLevel({
    required this.number,
    required this.title,
    required this.briefing,
    required this.goal,
    required this.hint,
    required this.initialState,
    required this.objectives,
    required this.pythonStarter,
    required this.javaStarter,
  });

  final int number;
  final String title;
  final String briefing;
  final String goal;
  final String hint;
  final FarmGameState initialState;
  final List<FarmLevelObjective> objectives;
  final String pythonStarter;
  final String javaStarter;

  String starterFor(CodeLanguage language) {
    return switch (language) {
      CodeLanguage.python => pythonStarter,
      CodeLanguage.java => javaStarter,
    };
  }
}

class FarmLevelEvaluation {
  const FarmLevelEvaluation(this.progress);

  final List<FarmObjectiveProgress> progress;

  bool get isComplete => progress.every((item) => item.isComplete);

  FarmObjectiveProgress? get firstOpen {
    for (final item in progress) {
      if (!item.isComplete) {
        return item;
      }
    }
    return null;
  }
}

FarmLevelEvaluation evaluateFarmLevel(FarmLevel level, FarmGameState state) {
  return FarmLevelEvaluation([
    for (final objective in level.objectives) objective.progressFor(state),
  ]);
}

final List<FarmLevel> farmLevels = [
  FarmLevel(
    number: 1,
    title: 'Riego de arranque',
    briefing: 'El dron empieza sobre una fila de cultivos ya sembrados.',
    goal: 'Riega todas las celdas sembradas de la fila superior.',
    hint:
        'Usa water() en una celda con cultivo y move() para avanzar a la siguiente.',
    initialState: _stateWith(
      resources: const ResourceBag(seeds: 0, water: 3),
      tiles: const [
        _LevelTile(0, 0, crop: CropType.hay),
        _LevelTile(1, 0, crop: CropType.hay),
        _LevelTile(2, 0, crop: CropType.hay),
      ],
    ),
    objectives: const [
      FarmLevelObjective(
        description: 'Celdas regadas',
        metric: FarmObjectiveMetric.wateredTiles,
        target: 3,
      ),
    ],
    pythonStarter: _pythonStarter([
      'water()',
      'move()',
      '# Repite el patrón hasta regar toda la fila.',
    ]),
    javaStarter: _javaStarter([
      'water();',
      'move();',
      '// Repite el patrón hasta regar toda la fila.',
    ]),
  ),
  FarmLevel(
    number: 2,
    title: 'Preparar terreno',
    briefing:
        'Ahora las celdas están vacías y necesitas preparar suelo fértil.',
    goal: 'Prepara cuatro parcelas con till().',
    hint:
        'Cada till() afecta solo a la celda actual. Muévete antes de preparar otra.',
    initialState: _stateWith(resources: const ResourceBag(seeds: 0, water: 0)),
    objectives: const [
      FarmLevelObjective(
        description: 'Parcelas preparadas',
        metric: FarmObjectiveMetric.tilledTiles,
        target: 4,
      ),
    ],
    pythonStarter: _pythonStarter([
      'till()',
      'move()',
      '# Prepara tres celdas más.',
    ]),
    javaStarter: _javaStarter([
      'till();',
      'move();',
      '// Prepara tres celdas más.',
    ]),
  ),
  FarmLevel(
    number: 3,
    title: 'Primera siembra',
    briefing:
        'Tienes semillas, pero la granja solo acepta plantar sobre suelo preparado.',
    goal: 'Siembra heno en tres parcelas distintas.',
    hint: 'El patrón base es till(), plant("hay") y move().',
    initialState: _stateWith(resources: const ResourceBag(seeds: 3, water: 0)),
    objectives: const [
      FarmLevelObjective(
        description: 'Henos sembrados',
        metric: FarmObjectiveMetric.hayTiles,
        target: 3,
      ),
    ],
    pythonStarter: _pythonStarter([
      'till()',
      'plant("hay")',
      'move()',
      '# Siembra dos parcelas más.',
    ]),
    javaStarter: _javaStarter([
      'till();',
      'plant("hay");',
      'move();',
      '// Siembra dos parcelas más.',
    ]),
  ),
  FarmLevel(
    number: 4,
    title: 'Ciclo completo',
    briefing:
        'Una cosecha útil necesita preparación, siembra, agua y recolección.',
    goal: 'Cosecha dos unidades de heno.',
    hint:
        'Después de water(), harvest() recoge el cultivo y libera la parcela.',
    initialState: _stateWith(resources: const ResourceBag(seeds: 2, water: 2)),
    objectives: const [
      FarmLevelObjective(
        description: 'Heno cosechado',
        metric: FarmObjectiveMetric.hayHarvest,
        target: 2,
      ),
    ],
    pythonStarter: _pythonStarter([
      'till()',
      'plant("hay")',
      'water()',
      'harvest()',
      'move()',
      '# Completa otra parcela.',
    ]),
    javaStarter: _javaStarter([
      'till();',
      'plant("hay");',
      'water();',
      'harvest();',
      'move();',
      '// Completa otra parcela.',
    ]),
  ),
  FarmLevel(
    number: 5,
    title: 'Primer giro',
    briefing:
        'La ruta baja por una esquina. Necesitas cambiar la dirección del dron.',
    goal: 'Riega cuatro cultivos formando una L.',
    hint:
        'Al llegar al extremo, usa turnRight() en Java o turn_right() en Python.',
    initialState: _stateWith(
      resources: const ResourceBag(seeds: 0, water: 4),
      tiles: const [
        _LevelTile(0, 0, crop: CropType.hay),
        _LevelTile(1, 0, crop: CropType.hay),
        _LevelTile(1, 1, crop: CropType.hay),
        _LevelTile(1, 2, crop: CropType.hay),
      ],
    ),
    objectives: const [
      FarmLevelObjective(
        description: 'Cultivos regados',
        metric: FarmObjectiveMetric.wateredTiles,
        target: 4,
      ),
    ],
    pythonStarter: _pythonStarter([
      'water()',
      'move()',
      'water()',
      '# Gira hacia abajo y continúa la L.',
    ]),
    javaStarter: _javaStarter([
      'water();',
      'move();',
      'water();',
      '// Gira hacia abajo y continúa la L.',
    ]),
  ),
  FarmLevel(
    number: 6,
    title: 'Bancal 2x2',
    briefing: 'La primera zona compacta obliga a combinar avances y giros.',
    goal: 'Cosecha cuatro unidades de heno en un bloque 2x2.',
    hint:
        'Haz dos parcelas en una fila, gira, baja y vuelve por la fila siguiente.',
    initialState: _stateWith(resources: const ResourceBag(seeds: 4, water: 4)),
    objectives: const [
      FarmLevelObjective(
        description: 'Heno cosechado',
        metric: FarmObjectiveMetric.hayHarvest,
        target: 4,
      ),
    ],
    pythonStarter: _pythonStarter([
      'for _ in range(2):',
      '    till()',
      '    plant("hay")',
      '    water()',
      '    harvest()',
      '    move()',
      '# Baja a la segunda fila.',
    ]),
    javaStarter: _javaStarter([
      'for (int i = 0; i < 2; i++) {',
      '  till();',
      '  plant("hay");',
      '  water();',
      '  harvest();',
      '  move();',
      '}',
      '// Baja a la segunda fila.',
    ]),
  ),
  FarmLevel(
    number: 7,
    title: 'Fila automática',
    briefing: 'Los bucles evitan escribir el mismo bloque una y otra vez.',
    goal: 'Riega seis cultivos en la fila superior.',
    hint: 'Usa un for de 6 pasos y deja move() al final del bloque.',
    initialState: _stateWith(
      resources: const ResourceBag(seeds: 0, water: 6),
      tiles: const [
        _LevelTile(0, 0, crop: CropType.hay),
        _LevelTile(1, 0, crop: CropType.hay),
        _LevelTile(2, 0, crop: CropType.hay),
        _LevelTile(3, 0, crop: CropType.hay),
        _LevelTile(4, 0, crop: CropType.hay),
        _LevelTile(5, 0, crop: CropType.hay),
      ],
    ),
    objectives: const [
      FarmLevelObjective(
        description: 'Cultivos regados',
        metric: FarmObjectiveMetric.wateredTiles,
        target: 6,
      ),
    ],
    pythonStarter: _pythonStarter([
      'for _ in range(6):',
      '    water()',
      '    move()',
    ]),
    javaStarter: _javaStarter([
      'for (int i = 0; i < 6; i++) {',
      '  water();',
      '  move();',
      '}',
    ]),
  ),
  FarmLevel(
    number: 8,
    title: 'Datos de heno',
    briefing: 'Cada cosecha de heno genera una muestra de investigación.',
    goal: 'Consigue 3 datos de investigación.',
    hint: 'Cosecha tres henos completos: till, plant, water, harvest.',
    initialState: _stateWith(resources: const ResourceBag(seeds: 3, water: 3)),
    objectives: const [
      FarmLevelObjective(
        description: 'Datos generados',
        metric: FarmObjectiveMetric.research,
        target: 3,
      ),
    ],
    pythonStarter: _pythonStarter([
      'for _ in range(3):',
      '    till()',
      '    plant("hay")',
      '    water()',
      '    harvest()',
      '    move()',
    ]),
    javaStarter: _javaStarter([
      'for (int i = 0; i < 3; i++) {',
      '  till();',
      '  plant("hay");',
      '  water();',
      '  harvest();',
      '  move();',
      '}',
    ]),
  ),
  FarmLevel(
    number: 9,
    title: 'Semilla naranja',
    briefing: 'La zanahoria ya está desbloqueada y vale más que el heno.',
    goal: 'Cosecha una zanahoria.',
    hint: 'Usa plant("carrot") después de preparar la parcela.',
    initialState: _stateWith(
      resources: const ResourceBag(seeds: 1, water: 1),
      unlockedTechIds: const {'carrot'},
    ),
    objectives: const [
      FarmLevelObjective(
        description: 'Zanahorias cosechadas',
        metric: FarmObjectiveMetric.carrotHarvest,
        target: 2,
      ),
    ],
    pythonStarter: _pythonStarter([
      'till()',
      'plant("carrot")',
      'water()',
      'harvest()',
    ]),
    javaStarter: _javaStarter([
      'till();',
      'plant("carrot");',
      'water();',
      'harvest();',
    ]),
  ),
  FarmLevel(
    number: 10,
    title: 'Doble zanahoria',
    briefing: 'Repite una cosecha de más valor sin perder la ruta.',
    goal: 'Cosecha dos zanahorias.',
    hint: 'Cada zanahoria suma 2 al contador.',
    initialState: _stateWith(
      resources: const ResourceBag(seeds: 2, water: 2),
      unlockedTechIds: const {'carrot'},
    ),
    objectives: const [
      FarmLevelObjective(
        description: 'Zanahorias cosechadas',
        metric: FarmObjectiveMetric.carrotHarvest,
        target: 4,
      ),
    ],
    pythonStarter: _pythonStarter([
      'for _ in range(2):',
      '    till()',
      '    plant("carrot")',
      '    water()',
      '    harvest()',
      '    move()',
    ]),
    javaStarter: _javaStarter([
      'for (int i = 0; i < 2; i++) {',
      '  till();',
      '  plant("carrot");',
      '  water();',
      '  harvest();',
      '  move();',
      '}',
    ]),
  ),
  FarmLevel(
    number: 11,
    title: 'Mega calabaza',
    briefing:
        'La calabaza ocupa el mismo flujo, pero entrega mucha más producción.',
    goal: 'Cosecha una calabaza.',
    hint: 'Usa plant("pumpkin") en una parcela preparada.',
    initialState: _stateWith(
      resources: const ResourceBag(seeds: 1, water: 1),
      unlockedTechIds: const {'pumpkin'},
    ),
    objectives: const [
      FarmLevelObjective(
        description: 'Calabazas cosechadas',
        metric: FarmObjectiveMetric.pumpkinHarvest,
        target: 4,
      ),
    ],
    pythonStarter: _pythonStarter([
      'till()',
      'plant("pumpkin")',
      'water()',
      'harvest()',
    ]),
    javaStarter: _javaStarter([
      'till();',
      'plant("pumpkin");',
      'water();',
      'harvest();',
    ]),
  ),
  FarmLevel(
    number: 12,
    title: 'Laboratorio naranja',
    briefing: 'Las zanahorias producen más datos y ayudan a escalar antes.',
    goal: 'Genera 6 datos con tres zanahorias.',
    hint: 'Cosecha tres zanahorias en fila.',
    initialState: _stateWith(
      resources: const ResourceBag(seeds: 3, water: 3),
      unlockedTechIds: const {'carrot'},
    ),
    objectives: const [
      FarmLevelObjective(
        description: 'Datos generados',
        metric: FarmObjectiveMetric.research,
        target: 6,
      ),
    ],
    pythonStarter: _pythonStarter([
      'for _ in range(3):',
      '    till()',
      '    plant("carrot")',
      '    water()',
      '    harvest()',
      '    move()',
    ]),
    javaStarter: _javaStarter([
      'for (int i = 0; i < 3; i++) {',
      '  till();',
      '  plant("carrot");',
      '  water();',
      '  harvest();',
      '  move();',
      '}',
    ]),
  ),
  FarmLevel(
    number: 13,
    title: 'Zigzag de riego',
    briefing: 'Los cultivos están distribuidos entre dos filas.',
    goal: 'Riega ocho cultivos en patrón zigzag.',
    hint: 'Completa una fila, gira hacia abajo y vuelve por la siguiente.',
    initialState: _stateWith(
      resources: const ResourceBag(seeds: 0, water: 8),
      tiles: const [
        _LevelTile(0, 0, crop: CropType.hay),
        _LevelTile(1, 0, crop: CropType.hay),
        _LevelTile(2, 0, crop: CropType.hay),
        _LevelTile(3, 0, crop: CropType.hay),
        _LevelTile(3, 1, crop: CropType.hay),
        _LevelTile(2, 1, crop: CropType.hay),
        _LevelTile(1, 1, crop: CropType.hay),
        _LevelTile(0, 1, crop: CropType.hay),
      ],
    ),
    objectives: const [
      FarmLevelObjective(
        description: 'Cultivos regados',
        metric: FarmObjectiveMetric.wateredTiles,
        target: 8,
      ),
    ],
    pythonStarter: _pythonStarter([
      'for _ in range(4):',
      '    water()',
      '    move()',
      '# Baja y vuelve por la segunda fila.',
    ]),
    javaStarter: _javaStarter([
      'for (int i = 0; i < 4; i++) {',
      '  water();',
      '  move();',
      '}',
      '// Baja y vuelve por la segunda fila.',
    ]),
  ),
  FarmLevel(
    number: 14,
    title: 'Cosecha mixta',
    briefing: 'Combina cultivos básicos y avanzados en una misma ruta.',
    goal: 'Cosecha al menos 2 unidades de heno y 2 de zanahoria.',
    hint: 'Cambia el argumento de plant() según la parcela.',
    initialState: _stateWith(
      resources: const ResourceBag(seeds: 3, water: 3),
      unlockedTechIds: const {'carrot'},
    ),
    objectives: const [
      FarmLevelObjective(
        description: 'Heno cosechado',
        metric: FarmObjectiveMetric.hayHarvest,
        target: 2,
      ),
      FarmLevelObjective(
        description: 'Zanahorias cosechadas',
        metric: FarmObjectiveMetric.carrotHarvest,
        target: 2,
      ),
    ],
    pythonStarter: _pythonStarter([
      'till()',
      'plant("hay")',
      'water()',
      'harvest()',
      'move()',
      '# Ahora cosecha una zanahoria.',
    ]),
    javaStarter: _javaStarter([
      'till();',
      'plant("hay");',
      'water();',
      'harvest();',
      'move();',
      '// Ahora cosecha una zanahoria.',
    ]),
  ),
  FarmLevel(
    number: 15,
    title: 'Ruta al depósito',
    briefing: 'No siempre hay que cosechar; a veces solo importa llegar.',
    goal: 'Lleva el dron hasta la celda (5, 5).',
    hint: 'Avanza cinco veces, gira a la derecha y baja cinco veces.',
    initialState: _stateWith(resources: const ResourceBag(seeds: 0, water: 0)),
    objectives: const [
      FarmLevelObjective.droneAt(
        description: 'Posición del dron',
        x: 5,
        y: 5,
      ),
    ],
    pythonStarter: _pythonStarter([
      'for _ in range(5):',
      '    move()',
      '# Gira al sur y baja hasta y=5.',
    ]),
    javaStarter: _javaStarter([
      'for (int i = 0; i < 5; i++) {',
      '  move();',
      '}',
      '// Gira al sur y baja hasta y=5.',
    ]),
  ),
  FarmLevel(
    number: 16,
    title: 'Ruta corta',
    briefing: 'El dron debe llegar al punto exacto sin pasos de sobra.',
    goal: 'Termina en (3, 3) usando como máximo 8 instrucciones.',
    hint: 'Tres avances al este, un giro y tres avances al sur bastan.',
    initialState: _stateWith(resources: const ResourceBag(seeds: 0, water: 0)),
    objectives: const [
      FarmLevelObjective.droneAt(
        description: 'Posición del dron',
        x: 3,
        y: 3,
      ),
      FarmLevelObjective(
        description: 'Instrucciones ejecutadas',
        metric: FarmObjectiveMetric.executedSteps,
        target: 8,
        comparison: FarmObjectiveComparison.atMost,
      ),
    ],
    pythonStarter: _pythonStarter([
      'for _ in range(3):',
      '    move()',
      '# Gira y baja tres celdas.',
    ]),
    javaStarter: _javaStarter([
      'for (int i = 0; i < 3; i++) {',
      '  move();',
      '}',
      '// Gira y baja tres celdas.',
    ]),
  ),
  FarmLevel(
    number: 17,
    title: 'Dos calabazas',
    briefing:
        'La producción grande exige repetir un ciclo caro sin perder semillas.',
    goal: 'Cosecha dos calabazas.',
    hint: 'Cada calabaza cuenta como 4 unidades.',
    initialState: _stateWith(
      resources: const ResourceBag(seeds: 2, water: 2),
      unlockedTechIds: const {'pumpkin'},
    ),
    objectives: const [
      FarmLevelObjective(
        description: 'Calabazas cosechadas',
        metric: FarmObjectiveMetric.pumpkinHarvest,
        target: 8,
      ),
    ],
    pythonStarter: _pythonStarter([
      'for _ in range(2):',
      '    till()',
      '    plant("pumpkin")',
      '    water()',
      '    harvest()',
      '    move()',
    ]),
    javaStarter: _javaStarter([
      'for (int i = 0; i < 2; i++) {',
      '  till();',
      '  plant("pumpkin");',
      '  water();',
      '  harvest();',
      '  move();',
      '}',
    ]),
  ),
  FarmLevel(
    number: 18,
    title: 'Agua justa',
    briefing:
        'Tienes el agua exacta para completar todas las parcelas sembradas.',
    goal: 'Riega cinco cultivos y termina sin agua restante.',
    hint: 'No hace falta cosechar: solo riega las parcelas con cultivo.',
    initialState: _stateWith(
      resources: const ResourceBag(seeds: 0, water: 5),
      tiles: const [
        _LevelTile(0, 0, crop: CropType.hay),
        _LevelTile(1, 0, crop: CropType.hay),
        _LevelTile(2, 0, crop: CropType.hay),
        _LevelTile(2, 1, crop: CropType.hay),
        _LevelTile(2, 2, crop: CropType.hay),
      ],
    ),
    objectives: const [
      FarmLevelObjective(
        description: 'Cultivos regados',
        metric: FarmObjectiveMetric.wateredTiles,
        target: 5,
      ),
      FarmLevelObjective(
        description: 'Agua restante',
        metric: FarmObjectiveMetric.waterRemaining,
        target: 0,
        comparison: FarmObjectiveComparison.equals,
      ),
    ],
    pythonStarter: _pythonStarter([
      'water()',
      'move()',
      'water()',
      '# Completa la esquina con el agua exacta.',
    ]),
    javaStarter: _javaStarter([
      'water();',
      'move();',
      'water();',
      '// Completa la esquina con el agua exacta.',
    ]),
  ),
  FarmLevel(
    number: 19,
    title: 'Laboratorio mixto',
    briefing: 'El laboratorio pide combinar datos rápidos y producción alta.',
    goal: 'Genera 10 datos de investigación.',
    hint: 'Mezcla zanahorias y calabazas para llegar antes.',
    initialState: _stateWith(
      resources: const ResourceBag(seeds: 4, water: 4),
      unlockedTechIds: const {'carrot', 'pumpkin'},
    ),
    objectives: const [
      FarmLevelObjective(
        description: 'Datos generados',
        metric: FarmObjectiveMetric.research,
        target: 10,
      ),
    ],
    pythonStarter: _pythonStarter([
      '# Combina plant("carrot") y plant("pumpkin").',
      'till()',
      'plant("pumpkin")',
      'water()',
      'harvest()',
      'move()',
    ]),
    javaStarter: _javaStarter([
      '// Combina plant("carrot") y plant("pumpkin").',
      'till();',
      'plant("pumpkin");',
      'water();',
      'harvest();',
      'move();',
    ]),
  ),
  FarmLevel(
    number: 20,
    title: 'Automatización total',
    briefing: 'La prueba final busca una pequeña producción diversificada.',
    goal: 'Cosecha heno, zanahorias y calabazas en una sola ejecución.',
    hint:
        'Puedes usar varios bloques for o escribir tres ciclos con cultivos distintos.',
    initialState: _stateWith(
      resources: const ResourceBag(seeds: 6, water: 6),
      unlockedTechIds: const {'carrot', 'pumpkin'},
    ),
    objectives: const [
      FarmLevelObjective(
        description: 'Heno cosechado',
        metric: FarmObjectiveMetric.hayHarvest,
        target: 2,
      ),
      FarmLevelObjective(
        description: 'Zanahorias cosechadas',
        metric: FarmObjectiveMetric.carrotHarvest,
        target: 4,
      ),
      FarmLevelObjective(
        description: 'Calabazas cosechadas',
        metric: FarmObjectiveMetric.pumpkinHarvest,
        target: 8,
      ),
    ],
    pythonStarter: _pythonStarter([
      '# Cosecha 2 henos, 2 zanahorias y 2 calabazas.',
      '# Cambia plant("hay") por el cultivo que toque.',
      'till()',
      'plant("hay")',
      'water()',
      'harvest()',
      'move()',
    ]),
    javaStarter: _javaStarter([
      '// Cosecha 2 henos, 2 zanahorias y 2 calabazas.',
      '// Cambia plant("hay") por el cultivo que toque.',
      'till();',
      'plant("hay");',
      'water();',
      'harvest();',
      'move();',
    ]),
  ),
];

FarmGameState freshStateForLevel(FarmLevel level) {
  return level.initialState.copyWith(
    log: [
      'Nivel ${level.number}: ${level.title}.',
      level.goal,
    ],
  );
}

int _currentMetricValue(FarmGameState state, FarmObjectiveMetric metric) {
  return switch (metric) {
    FarmObjectiveMetric.wateredTiles =>
      _allTiles(state).where((tile) => tile.watered).length,
    FarmObjectiveMetric.tilledTiles =>
      _allTiles(state).where((tile) => tile.tilled).length,
    FarmObjectiveMetric.hayTiles =>
      _allTiles(state).where((tile) => tile.crop == CropType.hay).length,
    FarmObjectiveMetric.carrotTiles =>
      _allTiles(state).where((tile) => tile.crop == CropType.carrot).length,
    FarmObjectiveMetric.pumpkinTiles =>
      _allTiles(state).where((tile) => tile.crop == CropType.pumpkin).length,
    FarmObjectiveMetric.hayHarvest => state.resources.hay,
    FarmObjectiveMetric.carrotHarvest => state.resources.carrots,
    FarmObjectiveMetric.pumpkinHarvest => state.resources.pumpkins,
    FarmObjectiveMetric.totalHarvest => state.resources.totalHarvest,
    FarmObjectiveMetric.research => state.resources.research,
    FarmObjectiveMetric.waterRemaining => state.resources.water,
    FarmObjectiveMetric.executedSteps => state.executedSteps,
    FarmObjectiveMetric.dronePosition => 0,
  };
}

Iterable<FarmTile> _allTiles(FarmGameState state) sync* {
  for (final row in state.tiles) {
    for (final tile in row) {
      yield tile;
    }
  }
}

FarmGameState _stateWith({
  ResourceBag resources = const ResourceBag(),
  Set<String> unlockedTechIds = const <String>{},
  List<_LevelTile> tiles = const <_LevelTile>[],
}) {
  final farmTiles = List.generate(
    farmSize,
    (_) => List.generate(farmSize, (_) => const FarmTile()),
  );
  for (final tile in tiles) {
    farmTiles[tile.y][tile.x] = FarmTile(
      tilled: tile.crop != null,
      crop: tile.crop,
    );
  }

  return FarmGameState(
    tiles: farmTiles,
    resources: resources,
    unlockedTechIds: unlockedTechIds,
  );
}

class _LevelTile {
  const _LevelTile(
    this.x,
    this.y, {
    this.crop,
  });

  final int x;
  final int y;
  final CropType? crop;
}

String _pythonStarter(List<String> lines) => lines.join('\n');

String _javaStarter(List<String> lines) => lines.join('\n');
