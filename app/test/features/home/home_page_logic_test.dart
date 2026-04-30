import 'package:flutter_test/flutter_test.dart';
import 'package:cute_quests_ai/features/quests/quest.dart';

void main() {
  test('home quest list composition keeps expected quest count', () {
    final quests = [...phaseOneQuests, ...phaseTwoQuests];

    expect(quests.length, 5);
  });
}
