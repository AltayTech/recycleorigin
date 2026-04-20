# Testing Guide

This is the canonical testing guide for the customer app.

## Test layout

- `test/unit/` - unit tests
- `test/widget/` - widget tests
- `integration_test/` - integration tests

## Run tests

```bash
flutter test
```

Run a specific folder:

```bash
flutter test test/unit/
flutter test test/widget/
flutter test integration_test/
```

Run with coverage:

```bash
flutter test --coverage
```

## Conventions

- Use Arrange-Act-Assert style.
- Keep tests isolated and deterministic.
- Prefer fakes/stubs over brittle mocks.
