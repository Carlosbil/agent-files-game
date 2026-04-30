import 'package:flutter_test/flutter_test.dart';
import 'package:cute_quests_ai/features/quests/quest.dart';

void main() {
  group('Quest demo data', () {
    test('phaseOneQuests are pending and belong to phase 1', () {
      expect(phaseOneQuests, isNotEmpty);
      expect(phaseOneQuests.every((q) => q.phase == 1), isTrue);
      expect(phaseOneQuests.every((q) => !q.completed), isTrue);
      expect(phaseOneQuests.first.title, 'Setup de Campeón');
    });

    test('phaseTwoQuests are pending and belong to phase 2', () {
      expect(phaseTwoQuests, isNotEmpty);
      expect(phaseTwoQuests.every((q) => q.phase == 2), isTrue);
      expect(phaseTwoQuests.every((q) => !q.completed), isTrue);
    });

    test('completed xp total starts at 0', () {
      final quests = [...phaseOneQuests, ...phaseTwoQuests];
      final totalXp =
          quests.where((q) => q.completed).fold<int>(0, (sum, q) => sum + q.xp);

      expect(totalXp, 0);
    });
  });
}
