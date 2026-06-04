import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/core/utils/input_validator.dart';
import '../../../helpers/test_helpers.dart';

/// Widget test for input validation in forms
void main() {
  group('Input Validator Widget Tests', () {
    testWidgets('should validate email input in TextField',
        (WidgetTester tester) async {
      String? emailError;
      final emailController = TextEditingController();

      await tester.pumpWidget(
        TestHelpers.createSimpleTestWidget(
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              errorText: emailError,
            ),
            onChanged: (value) {
              emailError =
                  InputValidator.isValidEmail(value) ? null : 'Invalid email';
            },
          ),
        ),
      );

      // Test invalid email
      await tester.enterText(find.byType(TextField), 'invalid-email');
      await tester.pump();

      // Test valid email
      emailController.clear();
      await tester.enterText(find.byType(TextField), 'test@example.com');
      await tester.pump();
    });

    testWidgets('should validate password input in TextField',
        (WidgetTester tester) async {
      String? passwordError;
      final passwordController = TextEditingController();

      await tester.pumpWidget(
        TestHelpers.createSimpleTestWidget(
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: passwordError,
            ),
            onChanged: (value) {
              passwordError = InputValidator.validatePassword(value);
            },
          ),
        ),
      );

      // Test short password
      await tester.enterText(find.byType(TextField), '12345');
      await tester.pump();

      // Test valid password
      passwordController.clear();
      await tester.enterText(find.byType(TextField), 'password123');
      await tester.pump();
    });

    testWidgets('should validate phone number input',
        (WidgetTester tester) async {
      String? phoneError;
      final phoneController = TextEditingController();

      await tester.pumpWidget(
        TestHelpers.createSimpleTestWidget(
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone',
              errorText: phoneError,
            ),
            onChanged: (value) {
              phoneError = InputValidator.isValidPhoneNumber(value)
                  ? null
                  : 'Invalid phone number';
            },
          ),
        ),
      );

      // Test invalid phone
      await tester.enterText(find.byType(TextField), '123');
      await tester.pump();

      // Test valid phone
      phoneController.clear();
      await tester.enterText(find.byType(TextField), '1234567890');
      await tester.pump();
    });
  });
}
