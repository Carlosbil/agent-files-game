import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cute_quests_ai/main.dart';

void main() {
  testWidgets('renders the automation farm interface', (tester) async {
    await _pumpWideFarm(tester);

    expect(find.text('Drone Farm Lab'), findsOneWidget);
    expect(find.text('Manual de misión'), findsOneWidget);
    expect(find.text('Misiones'), findsOneWidget);
    expect(find.text('Qué se busca'), findsOneWidget);
    expect(find.textContaining('Nivel 1 de 20'), findsOneWidget);
    expect(find.text('Editor del dron'), findsOneWidget);
    expect(find.text('Python'), findsOneWidget);
    expect(find.text('Java'), findsOneWidget);
    expect(find.text('Investigación'), findsOneWidget);
    expect(find.text('Terminal'), findsOneWidget);
    expect(find.textContaining('Riega todas las celdas'), findsWidgets);
  });

  testWidgets('switches the editor template to Java', (tester) async {
    await _pumpWideFarm(tester);

    await tester.tap(find.text('Java'));
    await tester.pump();

    final editor = tester.widget<EditableText>(find.byType(EditableText));
    expect(editor.controller.text, contains('water();'));
    expect(editor.controller.text, contains('// Repite el patrón'));
  });

  testWidgets('moves to the next level and refreshes the starter',
      (tester) async {
    await _pumpWideFarm(tester);

    await tester.tap(find.byTooltip('Nivel siguiente'));
    await tester.pump();

    final editor = tester.widget<EditableText>(find.byType(EditableText));
    expect(find.textContaining('Nivel 2 de 20'), findsOneWidget);
    expect(editor.controller.text, contains('till()'));
    expect(editor.controller.text, contains('Prepara tres celdas más'));
  });

  testWidgets('inserts spaces when pressing tab in the code editor',
      (tester) async {
    await _pumpWideFarm(tester);
    final editor = tester.widget<EditableText>(find.byType(EditableText));

    await tester.tap(find.byType(EditableText));
    await tester.pump();
    editor.controller.value = const TextEditingValue(
      text: 'water()',
      selection: TextSelection.collapsed(offset: 0),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    expect(editor.controller.text, startsWith('    water()'));
  });

  testWidgets('auto indents after a Python block header', (tester) async {
    await _pumpWideFarm(tester);
    final editor = tester.widget<EditableText>(find.byType(EditableText));
    editor.controller.value = const TextEditingValue(
      text: 'for _ in range(3):',
      selection: TextSelection.collapsed(offset: 18),
    );

    await tester.tap(find.byType(EditableText));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(editor.controller.text, 'for _ in range(3):\n    ');
  });

  testWidgets('opens the mission guide and selects a level', (tester) async {
    await _pumpWideFarm(tester);

    await tester.tap(find.text('Misiones'));
    await tester.pumpAndSettle();

    expect(find.text('Centro de misiones'), findsOneWidget);
    expect(find.text('Funciones del dron'), findsOneWidget);
    expect(find.text('move()'), findsWidgets);
    expect(find.text('water()'), findsWidgets);

    await tester.tap(find.text('Preparar terreno'));
    await tester.pumpAndSettle();

    final editor = tester.widget<EditableText>(find.byType(EditableText));
    expect(find.textContaining('Nivel 2 de 20'), findsOneWidget);
    expect(editor.controller.text, contains('till()'));
  });
}

Future<void> _pumpWideFarm(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const DroneFarmApp());
  await tester.pump();
}
