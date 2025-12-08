# Test Suite Documentation

This directory contains comprehensive tests for the Recycle Origin application.

## Test Structure

```
test/
├── helpers/              # Test utilities and mock data
│   ├── test_helpers.dart
│   └── mock_data.dart
├── unit/                 # Unit tests
│   ├── core/            # Core functionality tests
│   │   ├── config/
│   │   ├── network/
│   │   ├── services/
│   │   └── utils/
│   └── features/        # Feature-specific tests
│       ├── articles/
│       ├── charities/
│       ├── clearings/
│       └── products/
└── widget/              # Widget tests
    ├── core/
    └── features/

integration_test/        # Integration tests
├── app_test.dart
└── user_flows_test.dart
```

## Running Tests

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/unit/core/utils/result_test.dart
```

### Run with coverage
```bash
flutter test --coverage
```

### Run integration tests
```bash
flutter test integration_test/
```

## Test Categories

### Unit Tests
- **Core Utilities**: Result type, InputValidator, AppConfig, ApiClient
- **Services**: SecureStorage, AppInfoService
- **Providers**: Charities, Products, Articles, Clearings, CustomerInfoProvider

### Widget Tests
- Core widgets (AppBackground, MainWrapper, etc.)
- Feature widgets (ProductList, etc.)
- Form validation widgets

### Integration Tests
- App launch and initialization
- User flows (product browsing, cart, authentication, etc.)
- Navigation flows

## Test Coverage Goals

- **Unit Tests**: >80% coverage
- **Widget Tests**: Critical UI components
- **Integration Tests**: Main user journeys

## Best Practices

1. **Isolation**: Each test should be independent
2. **Naming**: Use descriptive test names
3. **Arrange-Act-Assert**: Follow AAA pattern
4. **Mocking**: Use mocks for external dependencies
5. **Edge Cases**: Test error scenarios and edge cases

## Dependencies

- `flutter_test`: Core testing framework
- `mockito`: Mocking framework
- `integration_test`: Integration testing
- `http_mock_adapter`: HTTP mocking for Dio

## Continuous Integration

Tests should run automatically on:
- Pull requests
- Before merging to main branch
- Nightly builds

## Notes

- Some tests require platform channels (SecureStorage) and should be run on actual devices/emulators
- Integration tests require a running app instance
- Mock data is provided in `test/helpers/mock_data.dart`

