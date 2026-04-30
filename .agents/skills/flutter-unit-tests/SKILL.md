---
name: flutter-unit-tests
description: Use when Codex needs to create, modify, fix, review, or explain unit tests for Dart or Flutter code. Apply for deterministic business logic, scoring rules, models, controllers, repositories, local persistence helpers, validators, reducers, and any Flutter feature that needs fast automated tests using flutter_test or package:test.
---

# Flutter Unit Tests

## Core Rule

Write fast, deterministic tests that prove behavior, not implementation details.

## Workflow

1. Read the code under test and nearby tests before adding new ones.
2. Identify the behavior that matters to the user or feature.
3. Prefer pure unit tests for rules, scoring, validators, models, and controllers.
4. Use widget tests only when the behavior depends on Flutter rendering or interaction.
5. Keep each test focused on one outcome.
6. Run the narrowest useful command, usually `flutter test <test-file>`.

## What To Test

Prioritize:
- Scoring and XP calculations.
- Quest completion rules.
- Unlock conditions for achievements.
- Prompt/game validation rules.
- Token or budget calculations when represented locally.
- State transitions in controllers.
- Serialization and persistence helpers.
- Error and edge cases.

Avoid testing:
- Private implementation details.
- Flutter framework behavior.
- Static demo data unless it encodes a real contract.
- Styling that is better covered by widget or golden tests.

## Test Shape

Use clear Arrange, Act, Assert structure:

```dart
test('awards xp when all required rules pass', () {
  final round = PromptSurgeryRound.example();

  final result = scorePromptSurgeryRound(round);

  expect(result.xp, 120);
  expect(result.passed, isTrue);
});
```

Prefer descriptive test names:
- `returns zero xp when required output format is missing`
- `unlocks achievement after completing first quest`
- `keeps pending quest incomplete when score is below threshold`

## Determinism

- Do not call real network, AI providers, clocks, random generators, or file systems directly from unit tests.
- Inject time, randomness, storage, and external services.
- Use fakes for local collaborators.
- Keep scoring rules local and predictable.
- Make fixtures small and readable.

## Flutter Patterns

- Put tests under `app/test/` mirroring `app/lib/` where practical.
- Use `flutter_test` for Flutter projects.
- Use `group` for one class, function, or behavior area.
- Use `setUp` only when it improves readability.
- Prefer explicit test data over large shared fixtures.
- Keep widget tests separate from pure unit tests when the distinction helps scanning.

## Quality Checklist

Before finishing a test change, check:

- The test fails for the right reason before the fix when practical.
- Test names explain behavior clearly.
- Tests are deterministic and fast.
- Edge cases are covered.
- No real network, AI, or external service is used.
- Existing tests still pass, or any failure is explained.
