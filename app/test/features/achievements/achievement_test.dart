import 'package:flutter_test/flutter_test.dart';
import 'package:cute_quests_ai/features/achievements/achievement.dart';

void main() {
  group('Achievement demo data', () {
    test('contains one unlocked and two locked achievements', () {
      final unlocked = demoAchievements.where((a) => a.unlocked).length;
      final locked = demoAchievements.where((a) => !a.unlocked).length;

      expect(unlocked, 1);
      expect(locked, 2);
    });
  });
}
