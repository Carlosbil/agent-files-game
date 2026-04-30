import 'package:flutter_test/flutter_test.dart';
import 'package:cute_quests_ai/features/minigames/minigame_catalog.dart';

void main() {
  group('AI world route', () {
    test('has three subworlds with three flags each', () {
      expect(miniGameWorlds.length, 3);
      expect(aiWorldRoute.length, 9);
      expect(aiWorldRoute.map((challenge) => challenge.level), [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
      ]);

      for (final world in MiniGameWorldId.values) {
        expect(worldChallengeCount(world), 3);
      }
    });

    test('unlocks only the next incomplete flag in the straight route', () {
      const progress = WorldRouteProgress({
        'agents-file-rules',
        'agents-tool-safety',
      });

      expect(progress.completedCount, 1);
      expect(progress.earnedXp, 40);
      expect(progress.nextChallenge?.id, 'agents-delegation');
      expect(progress.isCompleted('agents-file-rules'), isTrue);
      expect(progress.isUnlocked('agents-delegation'), isTrue);
      expect(progress.isUnlocked('agents-tool-safety'), isFalse);
    });

    test('knows the correct option for an instruction challenge', () {
      final challenge = challengeById('instructions-output');

      expect(challenge.isCorrect('goal-constraints-format'), isTrue);
      expect(challenge.isCorrect('longer-answer'), isFalse);
    });
  });
}
