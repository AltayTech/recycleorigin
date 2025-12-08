# Production Code Guidelines

## Quick Reference for Senior-Level Code

### 1. Logging

**❌ NEVER DO THIS:**
```dart
debugPrint('Password: $password');
debugPrint('Token: $token');
print('User data: $userData');
```

**✅ ALWAYS DO THIS:**
```dart
import 'package:recycleorigin/core/utils/logger.dart';

// For debug information
AppLogger.debug('User logged in', {'userId': userId});

// For errors
AppLogger.error('Login failed', error: error, stackTrace: stackTrace);

// For network requests (automatically sanitized)
AppLogger.networkRequest('POST', '/api/login', body: {'username': email});
```

### 2. Error Handling

**❌ NEVER DO THIS:**
```dart
try {
  final data = await fetchData();
} catch (e) {
  debugPrint(e.toString());
  throw e;
}
```

**✅ ALWAYS DO THIS:**
```dart
import 'package:recycleorigin/core/utils/result.dart';

// Using Result type
final result = await _dataSource.fetchData();
result
  .onSuccess((data) => _handleSuccess(data))
  .onFailure((error) => _handleError(error));

// Or with unwrapping
final data = result.unwrapOr(defaultValue);
```

### 3. Network Requests

**❌ NEVER DO THIS:**
```dart
final response = await http.post(
  Uri.parse(url),
  headers: {'Authorization': 'Bearer $token'},
  body: jsonEncode(data),
);
if (response.statusCode == 200) {
  // handle success
}
```

**✅ ALWAYS DO THIS:**
```dart
import 'package:recycleorigin/core/network/api_client.dart';

final result = await _apiClient.post<MyModel>(
  'endpoint/path',
  data: requestData,
  parser: (json) => MyModel.fromJson(json),
);

result.onSuccess((model) {
  // handle success
}).onFailure((error) {
  // handle error - error message is user-friendly
});
```

### 4. Input Validation

**❌ NEVER DO THIS:**
```dart
if (email.isEmpty) {
  // show error
}
```

**✅ ALWAYS DO THIS:**
```dart
import 'package:recycleorigin/core/utils/input_validator.dart';

final emailError = InputValidator.validateRequired(email, 'Email');
if (emailError != null) {
  return emailError;
}

if (!InputValidator.isValidEmail(email)) {
  return 'Invalid email format';
}

final passwordError = InputValidator.validatePassword(password);
if (passwordError != null) {
  return passwordError;
}
```

### 5. Entity Classes

**❌ NEVER DO THIS:**
```dart
class User with ChangeNotifier {
  String name;
  User(this.name);
}
```

**✅ ALWAYS DO THIS:**
```dart
/// Immutable value object
class User {
  final String name;
  final String email;
  
  const User({
    required this.name,
    required this.email,
  });
  
  // Factory constructor for JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
  
  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
    };
  }
  
  // Copy with for immutability
  User copyWith({
    String? name,
    String? email,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          email == other.email;
  
  @override
  int get hashCode => name.hashCode ^ email.hashCode;
}
```

### 6. Widget Best Practices

**❌ NEVER DO THIS:**
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Hello'),
    );
  }
}
```

**✅ ALWAYS DO THIS:**
```dart
/// Widget description
/// 
/// More detailed documentation if needed
class MyWidget extends StatelessWidget {
  const MyWidget({
    super.key,
    required this.title,
    this.onTap,
  });
  
  final String title;
  final VoidCallback? onTap;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(title),
    );
  }
}
```

### 7. Async Operations

**❌ NEVER DO THIS:**
```dart
Future<void> loadData() async {
  final data = await fetchData();
  setState(() {
    _data = data;
  });
}
```

**✅ ALWAYS DO THIS:**
```dart
Future<void> loadData() async {
  try {
    setState(() => _isLoading = true);
    final result = await _dataSource.fetchData();
    
    result.onSuccess((data) {
      setState(() {
        _data = data;
        _isLoading = false;
      });
    }).onFailure((error) {
      setState(() {
        _isLoading = false;
        _error = error;
      });
      AppLogger.error('Failed to load data', error: error);
    });
  } catch (e, stackTrace) {
    setState(() {
      _isLoading = false;
    });
    AppLogger.error('Unexpected error', error: e, stackTrace: stackTrace);
  }
}
```

### 8. Constants and Configuration

**❌ NEVER DO THIS:**
```dart
final url = 'https://api.example.com/v1/users';
```

**✅ ALWAYS DO THIS:**
```dart
// In lib/core/constants/urls.dart
class ApiEndpoints {
  static const String baseUrl = 'https://api.example.com';
  static const String users = '/v1/users';
}

// Usage
final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.users}';
```

### 9. Null Safety

**❌ NEVER DO THIS:**
```dart
String name = user.name!; // Force unwrap
String email = user.email ?? ''; // Everywhere
```

**✅ ALWAYS DO THIS:**
```dart
// Use null-aware operators and provide defaults
final name = user.name ?? 'Unknown';
final email = user.email ?? '';

// Or use Result type for operations that can fail
final result = await getUser();
final user = result.unwrapOr(defaultUser);
```

### 10. Code Comments

**❌ NEVER DO THIS:**
```dart
// This function does something
void doSomething() {
  // Get data
  final data = getData();
  // Process data
  processData(data);
}
```

**✅ ALWAYS DO THIS:**
```dart
/// Fetches user data from the server and processes it
/// 
/// Returns a [Result] containing either the processed data
/// or an error message if the operation fails.
Future<Result<ProcessedData>> fetchAndProcessUserData() async {
  final data = await _dataSource.getData();
  return processData(data);
}
```

## Security Checklist

- [ ] Never log passwords, tokens, or sensitive data
- [ ] Always validate user input
- [ ] Use HTTPS for all network requests
- [ ] Sanitize data before displaying
- [ ] Implement proper authentication
- [ ] Use secure storage for sensitive data
- [ ] Validate API responses
- [ ] Handle errors without exposing internals

## Performance Checklist

- [ ] Use `const` constructors where possible
- [ ] Implement proper caching
- [ ] Use `ListView.builder` for long lists
- [ ] Optimize image loading
- [ ] Avoid unnecessary rebuilds
- [ ] Use `RepaintBoundary` for complex widgets
- [ ] Implement pagination for large datasets
- [ ] Profile and optimize hot paths

## Testing Checklist

- [ ] Write unit tests for business logic
- [ ] Write widget tests for UI components
- [ ] Test error scenarios
- [ ] Test edge cases
- [ ] Mock external dependencies
- [ ] Achieve 80%+ code coverage
- [ ] Test on multiple devices
- [ ] Test offline scenarios

## Code Review Checklist

- [ ] Code follows style guide
- [ ] No security vulnerabilities
- [ ] Proper error handling
- [ ] Adequate documentation
- [ ] No commented code
- [ ] Proper null safety
- [ ] No hardcoded values
- [ ] Proper separation of concerns

