import 'dart:math' as math;

const farmSize = 6;

enum Direction { north, east, south, west }

enum CropType {
  hay('Heno', 1, '🌾'),
  carrot('Zanahoria', 2, '🥕'),
  pumpkin('Calabaza', 4, '🎃');

  const CropType(this.label, this.cropYield, this.icon);

  final String label;
  final int cropYield;
  final String icon;
}

enum FarmCommandType {
  move,
  turnLeft,
  turnRight,
  till,
  plant,
  water,
  harvest,
  scan
}

enum CodeLanguage {
  python('Python'),
  java('Java');

  const CodeLanguage(this.label);

  final String label;
}

class FarmCommand {
  const FarmCommand(this.type, {this.crop, required this.sourceLine});

  final FarmCommandType type;
  final CropType? crop;
  final int sourceLine;

  String get label {
    return switch (type) {
      FarmCommandType.move => 'move()',
      FarmCommandType.turnLeft => 'turn_left()',
      FarmCommandType.turnRight => 'turn_right()',
      FarmCommandType.till => 'till()',
      FarmCommandType.plant => 'plant(${crop!.name})',
      FarmCommandType.water => 'water()',
      FarmCommandType.harvest => 'harvest()',
      FarmCommandType.scan => 'scan()',
    };
  }
}

class ParseResult {
  const ParseResult({required this.commands, required this.errors});

  final List<FarmCommand> commands;
  final List<String> errors;

  bool get hasErrors => errors.isNotEmpty;
}

class FarmTile {
  const FarmTile({this.tilled = false, this.crop, this.watered = false});

  final bool tilled;
  final CropType? crop;
  final bool watered;

  bool get hasCrop => crop != null;
  bool get readyToHarvest => crop != null && watered;

  FarmTile copyWith(
      {bool? tilled, CropType? crop, bool? watered, bool clearCrop = false}) {
    return FarmTile(
      tilled: tilled ?? this.tilled,
      crop: clearCrop ? null : crop ?? this.crop,
      watered: watered ?? this.watered,
    );
  }
}

class ResourceBag {
  const ResourceBag({
    this.seeds = 8,
    this.water = 8,
    this.hay = 0,
    this.carrots = 0,
    this.pumpkins = 0,
    this.research = 0,
  });

  final int seeds;
  final int water;
  final int hay;
  final int carrots;
  final int pumpkins;
  final int research;

  int get totalHarvest => hay + carrots + pumpkins;

  ResourceBag copyWith({
    int? seeds,
    int? water,
    int? hay,
    int? carrots,
    int? pumpkins,
    int? research,
  }) {
    return ResourceBag(
      seeds: seeds ?? this.seeds,
      water: water ?? this.water,
      hay: hay ?? this.hay,
      carrots: carrots ?? this.carrots,
      pumpkins: pumpkins ?? this.pumpkins,
      research: research ?? this.research,
    );
  }

  ResourceBag addCrop(CropType crop) {
    return switch (crop) {
      CropType.hay =>
        copyWith(hay: hay + crop.cropYield, research: research + 1),
      CropType.carrot =>
        copyWith(carrots: carrots + crop.cropYield, research: research + 2),
      CropType.pumpkin =>
        copyWith(pumpkins: pumpkins + crop.cropYield, research: research + 4),
    };
  }
}

class Technology {
  const Technology({
    required this.id,
    required this.name,
    required this.description,
    required this.researchCost,
    required this.unlocksCrop,
  });

  final String id;
  final String name;
  final String description;
  final int researchCost;
  final CropType? unlocksCrop;
}

const technologies = [
  Technology(
    id: 'scanner',
    name: 'Sensor de terreno',
    description: 'Permite usar scan() para leer la casilla actual en el log.',
    researchCost: 3,
    unlocksCrop: null,
  ),
  Technology(
    id: 'carrot',
    name: 'Semilla naranja',
    description: 'Desbloquea plant(carrot), una cosecha con más datos.',
    researchCost: 6,
    unlocksCrop: CropType.carrot,
  ),
  Technology(
    id: 'pumpkin',
    name: 'Mega calabaza',
    description: 'Desbloquea plant(pumpkin), lenta pero muy valiosa.',
    researchCost: 12,
    unlocksCrop: CropType.pumpkin,
  ),
];

class FarmGameState {
  FarmGameState({
    required this.tiles,
    this.droneX = 0,
    this.droneY = 0,
    this.direction = Direction.east,
    this.resources = const ResourceBag(),
    Set<String>? unlockedTechIds,
    List<String>? log,
    this.executedSteps = 0,
  })  : unlockedTechIds = Set.unmodifiable(unlockedTechIds ?? const <String>{}),
        log = List.unmodifiable(log ?? const <String>[]);

  factory FarmGameState.initial() {
    return FarmGameState(
      tiles: List.generate(
        farmSize,
        (_) => List.generate(farmSize, (_) => const FarmTile()),
      ),
      log: const ['Sistema listo. Escribe un plan y pulsa Ejecutar.'],
    );
  }

  final List<List<FarmTile>> tiles;
  final int droneX;
  final int droneY;
  final Direction direction;
  final ResourceBag resources;
  final Set<String> unlockedTechIds;
  final List<String> log;
  final int executedSteps;

  FarmTile get currentTile => tiles[droneY][droneX];

  bool isCropUnlocked(CropType crop) {
    return crop == CropType.hay || unlockedTechIds.contains(crop.name);
  }

  bool isTechUnlocked(String id) => unlockedTechIds.contains(id);

  FarmGameState copyWith({
    List<List<FarmTile>>? tiles,
    int? droneX,
    int? droneY,
    Direction? direction,
    ResourceBag? resources,
    Set<String>? unlockedTechIds,
    List<String>? log,
    int? executedSteps,
  }) {
    return FarmGameState(
      tiles: tiles ?? this.tiles,
      droneX: droneX ?? this.droneX,
      droneY: droneY ?? this.droneY,
      direction: direction ?? this.direction,
      resources: resources ?? this.resources,
      unlockedTechIds: unlockedTechIds ?? this.unlockedTechIds,
      log: log ?? this.log,
      executedSteps: executedSteps ?? this.executedSteps,
    );
  }

  FarmGameState withTile(int x, int y, FarmTile tile) {
    final nextTiles = [
      for (final row in tiles) [...row],
    ];
    nextTiles[y][x] = tile;
    return copyWith(tiles: nextTiles);
  }

  FarmGameState appendLog(String message) {
    final nextLog = [...log, message];
    final trimmed =
        nextLog.length > 12 ? nextLog.sublist(nextLog.length - 12) : nextLog;
    return copyWith(log: trimmed);
  }

  FarmGameState unlock(Technology technology) {
    if (isTechUnlocked(technology.id)) {
      return appendLog('${technology.name} ya estaba desbloqueada.');
    }
    if (resources.research < technology.researchCost) {
      return appendLog('Investigación insuficiente para ${technology.name}.');
    }

    final unlocked = {...unlockedTechIds, technology.id};
    if (technology.unlocksCrop != null) {
      unlocked.add(technology.unlocksCrop!.name);
    }

    return copyWith(
      resources: resources.copyWith(
          research: resources.research - technology.researchCost),
      unlockedTechIds: unlocked,
    ).appendLog('Tecnología desbloqueada: ${technology.name}.');
  }
}

class SimulationResult {
  const SimulationResult({required this.state, required this.parseErrors});

  final FarmGameState state;
  final List<String> parseErrors;
}

const _maxRepeatCount = 20;
const _maxInstructions = 120;

ParseResult parseProgram(String source,
    {CodeLanguage language = CodeLanguage.python}) {
  final result = switch (language) {
    CodeLanguage.python => _parsePythonProgram(source),
    CodeLanguage.java => _parseJavaProgram(source),
  };
  return _limitInstructionCount(result);
}

SimulationResult runProgram(
  FarmGameState state,
  String source, {
  CodeLanguage language = CodeLanguage.python,
}) {
  final parsed = parseProgram(source, language: language);
  var next = state
      .copyWith(log: ['Ejecutando ${parsed.commands.length} instrucciones...']);

  for (final error in parsed.errors) {
    next = next.appendLog('ERROR: $error');
  }
  if (parsed.hasErrors) {
    return SimulationResult(state: next, parseErrors: parsed.errors);
  }

  for (final command in parsed.commands) {
    next = _applyCommand(next, command);
  }

  return SimulationResult(
    state: next.appendLog(
        'Ejecución terminada. Recursos: ${next.resources.totalHarvest} cosechas.'),
    parseErrors: const [],
  );
}

String defaultProgramFor(CodeLanguage language) {
  return switch (language) {
    CodeLanguage.python => _defaultPythonProgram,
    CodeLanguage.java => _defaultJavaProgram,
  };
}

final String defaultProgram = defaultProgramFor(CodeLanguage.python);

const _defaultPythonProgram = '''# Automatiza la primera parcela
for _ in range(3):
    till()
    plant("hay")
    water()
    harvest()
    move()
turn_right()
move()
turn_right()
for _ in range(3):
    till()
    plant("hay")
    water()
    harvest()
    move()''';

const _defaultJavaProgram = '''// Automatiza la primera parcela
for (int i = 0; i < 3; i++) {
  till();
  plant("hay");
  water();
  harvest();
  move();
}
turnRight();
move();
turnRight();
for (int i = 0; i < 3; i++) {
  till();
  plant("hay");
  water();
  harvest();
  move();
}''';

ParseResult _limitInstructionCount(ParseResult result) {
  if (result.commands.length <= _maxInstructions) {
    return result;
  }

  return ParseResult(
    commands: result.commands.take(_maxInstructions).toList(),
    errors: [
      ...result.errors,
      'El programa se recortó a $_maxInstructions instrucciones para proteger el dron.'
    ],
  );
}

ParseResult _parsePythonProgram(String source) {
  final lines = _pythonSourceLines(source);
  final errors = <String>[];
  final block = _parsePythonBlock(lines, 0, 0, errors);
  return ParseResult(commands: block.commands, errors: errors);
}

_ParsedBlock _parsePythonBlock(
    List<_ProgramLine> lines, int start, int indent, List<String> errors) {
  final commands = <FarmCommand>[];
  var lineIndex = start;

  while (lineIndex < lines.length) {
    final line = lines[lineIndex];
    if (line.indent < indent) {
      break;
    }
    if (line.indent > indent) {
      errors.add('Línea ${line.number}: sangría inesperada.');
      lineIndex++;
      continue;
    }

    final forMatch = RegExp(r'^for\s+\w+\s+in\s+range\(\s*(\d+)\s*\):$')
        .firstMatch(line.code);
    if (forMatch != null) {
      if (lineIndex + 1 >= lines.length ||
          lines[lineIndex + 1].indent <= line.indent) {
        errors.add('Línea ${line.number}: for sin bloque indentado.');
        lineIndex++;
        continue;
      }

      final count = int.parse(forMatch.group(1)!);
      final block = _parsePythonBlock(
          lines, lineIndex + 1, lines[lineIndex + 1].indent, errors);
      if (count > _maxRepeatCount) {
        errors.add(
            'Línea ${line.number}: for máximo permitido es $_maxRepeatCount.');
      } else {
        for (var iteration = 0; iteration < count; iteration++) {
          commands.addAll(block.commands);
        }
      }
      lineIndex = block.nextIndex;
      continue;
    }

    final command = _parsePythonCommand(line.code, line.number, errors);
    if (command != null) {
      commands.add(command);
    }
    lineIndex++;
  }

  return _ParsedBlock(commands, lineIndex);
}

List<_ProgramLine> _pythonSourceLines(String source) {
  final rawLines = source.split('\n');
  final lines = <_ProgramLine>[];

  for (var index = 0; index < rawLines.length; index++) {
    final withoutComment = _stripAfter(rawLines[index], '#');
    final code =
        withoutComment.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    if (code.isEmpty) {
      continue;
    }
    lines.add(_ProgramLine(
        number: index + 1,
        indent: _leadingSpaceCount(withoutComment),
        code: code));
  }

  return lines;
}

FarmCommand? _parsePythonCommand(
    String line, int sourceLine, List<String> errors) {
  final normalized = line.replaceAll(RegExp(r'\s+'), '');
  return switch (normalized) {
    'move()' => FarmCommand(FarmCommandType.move, sourceLine: sourceLine),
    'turn_left()' =>
      FarmCommand(FarmCommandType.turnLeft, sourceLine: sourceLine),
    'turn_right()' =>
      FarmCommand(FarmCommandType.turnRight, sourceLine: sourceLine),
    'till()' => FarmCommand(FarmCommandType.till, sourceLine: sourceLine),
    'water()' => FarmCommand(FarmCommandType.water, sourceLine: sourceLine),
    'harvest()' => FarmCommand(FarmCommandType.harvest, sourceLine: sourceLine),
    'scan()' => FarmCommand(FarmCommandType.scan, sourceLine: sourceLine),
    _ =>
      _parsePlantCall(normalized, sourceLine, errors, languageName: 'Python'),
  };
}

ParseResult _parseJavaProgram(String source) {
  final lines = source.split('\n');
  final errors = <String>[];
  final block = _parseJavaBlock(lines, 0, lines.length, errors);
  return ParseResult(commands: block.commands, errors: errors);
}

_ParsedBlock _parseJavaBlock(
    List<String> lines, int start, int end, List<String> errors) {
  final commands = <FarmCommand>[];
  var lineIndex = start;

  while (lineIndex < end) {
    final line = _cleanJavaLine(lines[lineIndex]);
    if (line.isEmpty) {
      lineIndex++;
      continue;
    }

    if (_isJavaClose(line)) {
      errors.add('Línea ${lineIndex + 1}: cierre de bloque sin apertura.');
      lineIndex++;
      continue;
    }

    final forMatch = _javaForMatch(line);
    if (forMatch != null) {
      final close = _findJavaBlockClose(lines, lineIndex + 1, end);
      if (close == -1) {
        errors.add('Línea ${lineIndex + 1}: for sin cierre "}".');
        return _ParsedBlock(commands, end);
      }

      final count = int.parse(forMatch.group(1)!);
      final block = _parseJavaBlock(lines, lineIndex + 1, close, errors);
      if (count > _maxRepeatCount) {
        errors.add(
            'Línea ${lineIndex + 1}: for máximo permitido es $_maxRepeatCount.');
      } else {
        for (var iteration = 0; iteration < count; iteration++) {
          commands.addAll(block.commands);
        }
      }
      lineIndex = close + 1;
      continue;
    }

    final command = _parseJavaCommand(line, lineIndex + 1, errors);
    if (command != null) {
      commands.add(command);
    }
    lineIndex++;
  }

  return _ParsedBlock(commands, lineIndex);
}

String _cleanJavaLine(String raw) {
  return _stripAfter(raw, '//').trim().replaceAll(RegExp(r'\s+'), ' ');
}

RegExpMatch? _javaForMatch(String line) {
  return RegExp(
    r'^for\s*\(\s*(?:int|var)?\s*\w+\s*=\s*0\s*;\s*\w+\s*<\s*(\d+)\s*;\s*\w+\+\+\s*\)\s*\{?$',
    caseSensitive: false,
  ).firstMatch(line);
}

FarmCommand? _parseJavaCommand(
    String line, int sourceLine, List<String> errors) {
  final normalized = line
      .replaceAll(RegExp(r'\s+'), '')
      .replaceFirst(RegExp(r';$'), '')
      .toLowerCase();
  return switch (normalized) {
    'move()' => FarmCommand(FarmCommandType.move, sourceLine: sourceLine),
    'turnleft()' =>
      FarmCommand(FarmCommandType.turnLeft, sourceLine: sourceLine),
    'turnright()' =>
      FarmCommand(FarmCommandType.turnRight, sourceLine: sourceLine),
    'till()' => FarmCommand(FarmCommandType.till, sourceLine: sourceLine),
    'water()' => FarmCommand(FarmCommandType.water, sourceLine: sourceLine),
    'harvest()' => FarmCommand(FarmCommandType.harvest, sourceLine: sourceLine),
    'scan()' => FarmCommand(FarmCommandType.scan, sourceLine: sourceLine),
    _ => _parsePlantCall(normalized, sourceLine, errors, languageName: 'Java'),
  };
}

FarmCommand? _parsePlantCall(String line, int sourceLine, List<String> errors,
    {required String languageName}) {
  final match =
      RegExp(r'''^plant\(\s*["']?([a-z]+)["']?\s*\)$''', caseSensitive: false)
          .firstMatch(line);
  if (match == null) {
    errors.add(
        'Línea $sourceLine: instrucción $languageName desconocida "$line".');
    return null;
  }

  final cropName = match.group(1)!.toLowerCase();
  final crop = _cropByName(cropName);
  if (crop == null) {
    errors.add('Línea $sourceLine: cultivo desconocido "$cropName".');
    return null;
  }
  return FarmCommand(FarmCommandType.plant, crop: crop, sourceLine: sourceLine);
}

CropType? _cropByName(String cropName) {
  for (final candidate in CropType.values) {
    if (candidate.name == cropName) {
      return candidate;
    }
  }
  return null;
}

int _findJavaBlockClose(List<String> lines, int start, int end) {
  var depth = 0;
  for (var index = start; index < end; index++) {
    final line = _cleanJavaLine(lines[index]);
    if (line.isEmpty) {
      continue;
    }
    if (_isJavaClose(line)) {
      if (depth == 0) {
        return index;
      }
      depth--;
      continue;
    }
    if (_javaForMatch(line) != null) {
      depth++;
    }
  }
  return -1;
}

bool _isJavaClose(String line) => line == '}' || line == '};';

String _stripAfter(String value, String marker) {
  final markerStart = value.indexOf(marker);
  return markerStart == -1 ? value : value.substring(0, markerStart);
}

int _leadingSpaceCount(String value) {
  var count = 0;
  for (final unit in value.codeUnits) {
    if (unit == 32) {
      count++;
      continue;
    }
    if (unit == 9) {
      count += 4;
      continue;
    }
    break;
  }
  return count;
}

class _ProgramLine {
  const _ProgramLine(
      {required this.number, required this.indent, required this.code});

  final int number;
  final int indent;
  final String code;
}

class _ParsedBlock {
  const _ParsedBlock(this.commands, this.nextIndex);

  final List<FarmCommand> commands;
  final int nextIndex;
}

FarmGameState _applyCommand(FarmGameState state, FarmCommand command) {
  var next = state.copyWith(executedSteps: state.executedSteps + 1);
  switch (command.type) {
    case FarmCommandType.move:
      final (dx, dy) = switch (state.direction) {
        Direction.north => (0, -1),
        Direction.east => (1, 0),
        Direction.south => (0, 1),
        Direction.west => (-1, 0),
      };
      final x = math.max(0, math.min(farmSize - 1, state.droneX + dx));
      final y = math.max(0, math.min(farmSize - 1, state.droneY + dy));
      return next
          .copyWith(droneX: x, droneY: y)
          .appendLog('L${command.sourceLine}: dron en ($x, $y).');
    case FarmCommandType.turnLeft:
      final direction = Direction
          .values[(state.direction.index - 1) % Direction.values.length];
      return next
          .copyWith(direction: direction)
          .appendLog('L${command.sourceLine}: giro izquierda.');
    case FarmCommandType.turnRight:
      final direction = Direction
          .values[(state.direction.index + 1) % Direction.values.length];
      return next
          .copyWith(direction: direction)
          .appendLog('L${command.sourceLine}: giro derecha.');
    case FarmCommandType.till:
      return next
          .withTile(state.droneX, state.droneY,
              state.currentTile.copyWith(tilled: true))
          .appendLog('L${command.sourceLine}: suelo preparado.');
    case FarmCommandType.plant:
      final crop = command.crop!;
      if (!state.isCropUnlocked(crop)) {
        return next
            .appendLog('L${command.sourceLine}: ${crop.label} está bloqueado.');
      }
      if (!state.currentTile.tilled || state.currentTile.hasCrop) {
        return next
            .appendLog('L${command.sourceLine}: no se puede plantar aquí.');
      }
      if (state.resources.seeds <= 0) {
        return next.appendLog('L${command.sourceLine}: no quedan semillas.');
      }
      return next
          .copyWith(
              resources:
                  state.resources.copyWith(seeds: state.resources.seeds - 1))
          .withTile(state.droneX, state.droneY,
              state.currentTile.copyWith(crop: crop, watered: false))
          .appendLog('L${command.sourceLine}: ${crop.label} plantado.');
    case FarmCommandType.water:
      if (!state.currentTile.hasCrop) {
        return next
            .appendLog('L${command.sourceLine}: no hay cultivo para regar.');
      }
      if (state.resources.water <= 0) {
        return next
            .appendLog('L${command.sourceLine}: depósito de agua vacío.');
      }
      return next
          .copyWith(
              resources:
                  state.resources.copyWith(water: state.resources.water - 1))
          .withTile(state.droneX, state.droneY,
              state.currentTile.copyWith(watered: true))
          .appendLog('L${command.sourceLine}: cultivo listo.');
    case FarmCommandType.harvest:
      if (!state.currentTile.readyToHarvest) {
        return next
            .appendLog('L${command.sourceLine}: nada listo para cosechar.');
      }
      return next
          .copyWith(resources: state.resources.addCrop(state.currentTile.crop!))
          .withTile(
            state.droneX,
            state.droneY,
            state.currentTile
                .copyWith(tilled: false, watered: false, clearCrop: true),
          )
          .appendLog('L${command.sourceLine}: cosecha recogida.');
    case FarmCommandType.scan:
      if (!state.isTechUnlocked('scanner')) {
        return next.appendLog(
            'L${command.sourceLine}: scan() requiere Sensor de terreno.');
      }
      final tile = state.currentTile;
      final crop = tile.crop?.label ?? 'vacío';
      return next.appendLog(
          'L${command.sourceLine}: (${state.droneX}, ${state.droneY}) $crop, regado=${tile.watered}.');
  }
}
