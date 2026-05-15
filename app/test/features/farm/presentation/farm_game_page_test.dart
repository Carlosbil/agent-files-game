import 'package:flutter_test/flutter_test.dart';
import 'package:cute_quests_ai/main.dart';

void main() {
  testWidgets('renders the automation farm interface', (tester) async {
    await tester.pumpWidget(const DroneFarmApp());

    expect(find.text('Drone Farm Lab'), findsOneWidget);
    expect(find.text('Editor del dron'), findsOneWidget);
    expect(find.text('Investigación'), findsOneWidget);
    expect(find.text('Terminal'), findsOneWidget);
    expect(find.textContaining('La granja ya no necesita manos'), findsOneWidget);
  });
}
