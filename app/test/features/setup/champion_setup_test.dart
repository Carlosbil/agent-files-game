import 'package:flutter_test/flutter_test.dart';
import 'package:cute_quests_ai/features/setup/champion_setup.dart';

void main() {
  group('ChampionSetup', () {
    test('scores 25 points per completed setup step', () {
      const setup = ChampionSetup(
        name: 'Campeón',
        role: 'Dev de agentes',
        power: null,
        goal: null,
      );

      expect(setup.completedSteps, 2);
      expect(setup.score, 50);
      expect(setup.isComplete, isFalse);
    });

    test('is complete when name, role, power and goal are present', () {
      const setup = ChampionSetup(
        name: 'Campeón',
        role: 'Dev de agentes',
        power: 'Cuidar contexto',
        goal: 'Preparar minijuegos',
      );

      expect(setup.score, 100);
      expect(setup.isComplete, isTrue);
    });
  });
}
