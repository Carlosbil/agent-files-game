import 'package:flutter_test/flutter_test.dart';

import 'package:cute_quests_ai/main.dart';

void main() {
  testWidgets('home renders playable phase one quests', (tester) async {
    await tester.pumpWidget(const CuteQuestsApp());

    expect(find.text('Cute Quests AI 🎀'), findsOneWidget);
    expect(find.text('Setup de Campeón'), findsOneWidget);
    expect(find.text('Ruta de Banderas IA'), findsOneWidget);
    expect(find.text('XP acumulada: 0'), findsOneWidget);
  });
}
