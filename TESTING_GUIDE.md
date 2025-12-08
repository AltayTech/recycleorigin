# Testing Guide for Recycle Origin

This document provides a comprehensive guide to the test suite for the Recycle Origin application.

## Overview

The test suite is organized into three main categories:

1. **Unit Tests** - Test individual components in isolation
2. **Widget Tests** - Test UI components and widgets
3. **Integration Tests** - Test complete user flows and app behavior

## Test Structure

```
test/
├── helpers/                    # Test utilities and mock data
│   ├── test_helpers.dart      # Widget test helpers
│   └── mock_data.dart         # Mock data factories
├── unit/                      # Unit tests
│   ├── core/                  # Core functionality
│   │   ├── config/           # AppConfig tests
│   │   ├── network/          # ApiClient tests
│   │   ├── services/         # Service tests
│   │   └── utils/            # Utility tests
│   └── features/             # Feature-specific tests
│       ├── articles/         # Articles provider tests
│       ├── charities/        # Charities provider tests
│       ├── clearings/        # Clearings provider tests
│       └── products/         # Products provider tests
└── widget/                   # Widget tests
    ├── core/                 # Core widget tests
    └── features/             # Feature widget tests

integration_test/             # Integration tests
├── app_test.dart            # App launch tests
└── user_flows_test.dart     # User flow tests
```

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test Category
```bash
# Unit tests only
flutter test test/unit/

# Widget tests only
flutter test test/widget/

# Integration tests
flutter test integration_test/
```

### Run with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Run Specific Test File
```bash
flutter test test/unit/core/utils/result_test.dart
```

## Test Categories

### Unit Tests

Unit tests verify the behavior of individual components in isolation.

#### Core Utilities
- **Result Type** (`test/unit/core/utils/result_test.dart`)
  - Tests the Result<T> sealed class for functional error handling
  - Covers Success and Failure cases
  - Tests mapping, unwrapping, and error handling

- **InputValidator** (`test/unit/core/utils/input_validator_test.dart`)
  - Tests email validation
  - Tests password validation
  - Tests phone number validation
  - Tests URL validation
  - Tests required field validation

- **AppConfig** (`test/unit/core/config/app_config_test.dart`)
  - Tests environment variable loading
  - Tests default values
  - Tests configuration initialization

- **ApiClient** (`test/unit/core/network/api_client_test.dart`)
  - Tests HTTP request handling
  - Tests error handling
  - Tests token management

#### Services
- **AppInfoService** (`test/unit/core/services/app_info_service_test.dart`)
  - Tests singleton pattern
  - Tests version formatting
  - Tests initialization

- **SecureStorage** (`test/unit/core/services/secure_storage_test.dart`)
  - Tests token management
  - Tests user data storage
  - Tests login status management

#### Providers
- **Charities Provider** (`test/unit/features/charities/charities_provider_test.dart`)
  - Tests search functionality
  - Tests pagination
  - Tests state management

- **Products Provider** (`test/unit/features/products/products_provider_test.dart`)
  - Tests product search
  - Tests cart management
  - Tests filtering
  - Tests pagination

- **Articles Provider** (`test/unit/features/articles/articles_provider_test.dart`)
  - Tests article search
  - Tests category filtering
  - Tests pagination

- **Clearings Provider** (`test/unit/features/clearings/clearings_provider_test.dart`)
  - Tests clearing search
  - Tests date/time selection
  - Tests filtering

### Widget Tests

Widget tests verify UI components render correctly and respond to user interactions.

- **Input Validator Widget** (`test/widget/core/widgets/input_validator_widget_test.dart`)
  - Tests form validation in TextFields
  - Tests error message display

- **App Background** (`test/widget/core/widgets/app_background_test.dart`)
  - Tests background image display

- **Product List** (`test/widget/features/store/product_list_test.dart`)
  - Tests product list display
  - Tests empty state

### Integration Tests

Integration tests verify complete user flows and app behavior.

- **App Launch** (`integration_test/app_test.dart`)
  - Tests app initialization
  - Tests splash screen

- **User Flows** (`integration_test/user_flows_test.dart`)
  - Product browsing flow
  - Shopping cart flow
  - Authentication flow
  - Charity flow
  - Article flow
  - Navigation flow

## Test Helpers

### TestHelpers
Located in `test/helpers/test_helpers.dart`, provides:
- `createTestWidget()` - Creates widgets with all providers
- `createSimpleTestWidget()` - Creates simple test widgets
- `pumpAndSettle()` - Helper for widget testing
- `waitFor()` - Helper for async operations

### MockData
Located in `test/helpers/mock_data.dart`, provides:
- Mock JSON data for entities
- Factory methods for test data
- Constants for testing

## Best Practices

### 1. Test Isolation
Each test should be independent and not rely on other tests.

### 2. Arrange-Act-Assert Pattern
```dart
test('should do something', () {
  // Arrange
  final provider = Products();
  
  // Act
  provider.searchKey = 'test';
  
  // Assert
  expect(provider.searchKey, 'test');
});
```

### 3. Descriptive Test Names
Use clear, descriptive test names that explain what is being tested.

### 4. Test Edge Cases
Don't just test the happy path - test error cases, edge cases, and boundary conditions.

### 5. Mock External Dependencies
Use mocks for:
- Network requests
- Platform channels
- File system operations
- Database operations

## Coverage Goals

- **Unit Tests**: >80% code coverage
- **Widget Tests**: All critical UI components
- **Integration Tests**: All main user flows

## Continuous Integration

Tests should run automatically on:
- Pull requests
- Before merging to main branch
- Nightly builds

## Troubleshooting

### Tests Failing Due to Platform Channels
Some tests (like SecureStorage) require platform channels. Run these on actual devices or emulators, or use mocks.

### Tests Timing Out
- Increase timeout: `test('name', () async { ... }, timeout: Timeout(Duration(seconds: 30)));`
- Check for infinite loops or blocking operations

### Flaky Tests
- Ensure tests are isolated
- Use `pumpAndSettle()` for async operations
- Avoid relying on timing

## Next Steps

1. Add more unit tests for remaining providers
2. Add widget tests for all major UI components
3. Expand integration tests to cover all user flows
4. Set up CI/CD pipeline for automated testing
5. Add performance tests for critical paths

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Widget Testing Guide](https://docs.flutter.dev/cookbook/testing/widget)
- [Integration Testing Guide](https://docs.flutter.dev/testing/integration-tests)

