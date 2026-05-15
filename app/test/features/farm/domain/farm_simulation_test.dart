import 'package:flutter_test/flutter_test.dart';
import 'package:cute_quests_ai/features/farm/domain/farm_levels.dart';
import 'package:cute_quests_ai/features/farm/domain/farm_simulation.dart';

void main() {
  test('Python for blocks expand into executable commands', () {
    final parsed = parseProgram('''
for _ in range(2):
    till()
    plant("hay")
    water()
    harvest()
''');

    expect(parsed.errors, isEmpty);
    expect(parsed.commands, hasLength(8));
    expect(
        parsed.commands
            .where((command) => command.type == FarmCommandType.harvest),
        hasLength(2));
  });

  test('Java for blocks expand into executable commands', () {
    final parsed = parseProgram(
      '''
for (int i = 0; i < 2; i++) {
  till();
  plant("hay");
  water();
  harvest();
}
''',
      language: CodeLanguage.java,
    );

    expect(parsed.errors, isEmpty);
    expect(parsed.commands, hasLength(8));
    expect(
        parsed.commands
            .where((command) => command.type == FarmCommandType.harvest),
        hasLength(2));
  });

  test(
      'Python program harvests resources and moves the drone deterministically',
      () {
    final result = runProgram(FarmGameState.initial(), '''
till()
plant("hay")
water()
harvest()
move()
''');

    expect(result.parseErrors, isEmpty);
    expect(result.state.resources.hay, 1);
    expect(result.state.resources.research, 1);
    expect(result.state.resources.seeds, 7);
    expect(result.state.resources.water, 7);
    expect(result.state.droneX, 1);
    expect(result.state.droneY, 0);
  });

  test('Java program harvests resources and moves the drone deterministically',
      () {
    final result = runProgram(
      FarmGameState.initial(),
      '''
till();
plant("hay");
water();
harvest();
move();
''',
      language: CodeLanguage.java,
    );

    expect(result.parseErrors, isEmpty);
    expect(result.state.resources.hay, 1);
    expect(result.state.resources.research, 1);
    expect(result.state.resources.seeds, 7);
    expect(result.state.resources.water, 7);
    expect(result.state.droneX, 1);
    expect(result.state.droneY, 0);
  });

  test('locked crops require research technology', () {
    final blocked = runProgram(
        FarmGameState.initial(), 'till()\nplant("carrot")\nwater()\nharvest()');
    expect(blocked.state.resources.carrots, 0);
    expect(
        blocked.state.log.any((entry) => entry.contains('bloqueado')), isTrue);

    final researched = FarmGameState.initial()
        .copyWith(resources: const ResourceBag(research: 6))
        .unlock(technologies[1]);
    final harvested =
        runProgram(researched, 'till()\nplant("carrot")\nwater()\nharvest()');
    expect(harvested.state.resources.carrots, 2);
  });

  test('Python parser reports unknown instructions', () {
    final parsed = parseProgram('fly()');

    expect(parsed.hasErrors, isTrue);
    expect(parsed.errors.single, contains('instrucción Python desconocida'));
  });

  test('Java parser reports unknown instructions', () {
    final parsed = parseProgram('fly();', language: CodeLanguage.java);

    expect(parsed.hasErrors, isTrue);
    expect(parsed.errors.single, contains('instrucción Java desconocida'));
  });

  test('defines at least 20 ordered farm levels with starters', () {
    expect(farmLevels, hasLength(greaterThanOrEqualTo(20)));
    for (var index = 0; index < farmLevels.length; index++) {
      final level = farmLevels[index];
      expect(level.number, index + 1);
      expect(level.objectives, isNotEmpty);
      expect(level.starterFor(CodeLanguage.python), isNotEmpty);
      expect(level.starterFor(CodeLanguage.java), isNotEmpty);
    }
  });

  test('first level completes after watering all seeded cells', () {
    final level = farmLevels.first;
    final initial = freshStateForLevel(level);

    expect(evaluateFarmLevel(level, initial).isComplete, isFalse);

    final result = runProgram(initial, '''
water()
move()
water()
move()
water()
''');
    final evaluation = evaluateFarmLevel(level, result.state);

    expect(result.parseErrors, isEmpty);
    expect(evaluation.isComplete, isTrue);
  });

  test('route level validates target position and step budget', () {
    final level = farmLevels[15];
    final result = runProgram(freshStateForLevel(level), '''
for _ in range(3):
    move()
turn_right()
for _ in range(3):
    move()
''');
    final evaluation = evaluateFarmLevel(level, result.state);

    expect(result.parseErrors, isEmpty);
    expect(result.state.droneX, 3);
    expect(result.state.droneY, 3);
    expect(result.state.executedSteps, 7);
    expect(evaluation.isComplete, isTrue);
  });
}
