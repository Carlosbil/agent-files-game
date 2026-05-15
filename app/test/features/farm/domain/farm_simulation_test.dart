import 'package:flutter_test/flutter_test.dart';
import 'package:cute_quests_ai/features/farm/domain/farm_simulation.dart';

void main() {
  test('repeat blocks expand into executable commands', () {
    final parsed = parseProgram('''
repeat 2 {
  till
  plant hay
  water
  harvest
}
''');

    expect(parsed.errors, isEmpty);
    expect(parsed.commands, hasLength(8));
    expect(parsed.commands.where((command) => command.type == FarmCommandType.harvest), hasLength(2));
  });

  test('program harvests resources and moves the drone deterministically', () {
    final result = runProgram(FarmGameState.initial(), '''
till
plant hay
water
harvest
move
''');

    expect(result.parseErrors, isEmpty);
    expect(result.state.resources.hay, 1);
    expect(result.state.resources.research, 1);
    expect(result.state.resources.seeds, 7);
    expect(result.state.resources.water, 7);
    expect(result.state.droneX, 1);
    expect(result.state.droneY, 0);
  });

  test('locked crops require research technology', () {
    final blocked = runProgram(FarmGameState.initial(), 'till\nplant carrot\nwater\nharvest');
    expect(blocked.state.resources.carrots, 0);
    expect(blocked.state.log.any((entry) => entry.contains('bloqueado')), isTrue);

    final researched = FarmGameState.initial().copyWith(resources: const ResourceBag(research: 6)).unlock(technologies[1]);
    final harvested = runProgram(researched, 'till\nplant carrot\nwater\nharvest');
    expect(harvested.state.resources.carrots, 2);
  });

  test('parser reports unknown instructions', () {
    final parsed = parseProgram('fly');

    expect(parsed.hasErrors, isTrue);
    expect(parsed.errors.single, contains('instrucción desconocida'));
  });
}
