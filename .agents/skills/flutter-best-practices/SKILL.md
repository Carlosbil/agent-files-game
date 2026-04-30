---
name: flutter-best-practices
description: Use when Codex needs to create, modify, refactor, review, or explain Flutter/Dart app code with high quality. Apply for Flutter widgets, app architecture, feature folders, state management, navigation, theming, accessibility, performance, dependency choices, maintainability improvements, and production-ready code changes.
---

# Flutter Best Practices

## Core Rule

Build Flutter code that is simple, readable, testable, deterministic, and consistent with the existing project.

## Workflow

1. Read `pubspec.yaml`, nearby feature files, theme files, and existing tests before changing code.
2. Follow the app's current architecture before adding a new pattern or dependency.
3. Keep changes small and feature-focused.
4. Prefer deterministic local logic for game rules, scoring, and progression unless the user explicitly asks otherwise.
5. After code changes, run the narrowest useful checks, usually `flutter analyze` and relevant tests.

## Architecture

- Keep app entrypoint code small.
- Put shared design, constants, and app-wide helpers under `core/`.
- Put user-facing domains under `features/<feature_name>/`.
- Keep models simple and immutable.
- Separate pure game logic from widgets so it can be unit tested.
- Keep generated/demo data separate from real state and services.
- Add abstractions only when they remove real duplication or clarify a boundary.

## Widgets

- Prefer composition over large widget classes.
- Extract private widgets when a build method becomes hard to scan.
- Use `const` constructors and widgets where possible.
- Keep layout responsive with constraints, spacing, and predictable sizing.
- Avoid putting business rules directly in `build`.
- Keep text concise and user-facing.
- Use theme values before hard-coded styling when the style is shared.

## State And Data

- Use local widget state only for local UI behavior.
- Use a feature-level state object or controller when state affects multiple widgets.
- Keep state transitions explicit: input, action, result.
- Make progress, XP, unlocks, and scoring deterministic.
- Persist only meaningful user progress.
- Avoid hidden network calls in core gameplay.

## Async And Errors

- Model loading, success, empty, and error states clearly.
- Avoid swallowing exceptions silently.
- Keep async side effects outside pure scoring or validation functions.
- Make retry behavior explicit when it exists.

## Dependencies

- Prefer Flutter and Dart standard libraries first.
- Add a dependency only when it solves a real problem better than local code.
- Check package fit with project size, maintenance cost, platform support, and testability.
- Do not introduce a state management library until the current state shape needs it.

## Quality Checklist

Before finishing a Flutter change, check:

- Code follows the existing folder and naming style.
- Widgets are readable and not overloaded with logic.
- Game rules are deterministic and testable.
- User-facing text fits the app tone.
- Theme usage stays consistent.
- No unrelated refactor was included.
- `flutter analyze` and relevant tests were run, or the reason is stated.
