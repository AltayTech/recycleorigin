# Engineering Notes

This file consolidates engineering guidance and prior refactor notes.

## Coding standards

- Avoid logging secrets/tokens/passwords.
- Use structured app logging utilities.
- Keep domain entities immutable where practical.
- Centralize network and error handling patterns.
- Run quality gates before merging:

```bash
dart format lib test
flutter analyze
flutter test
```

## Refactor history

Phase 1 improvements included:

- migration toward centralized API client usage
- stronger error handling conventions
- cleanup of debug logging and review findings

For detailed commit-level history, use git log and PR history.
