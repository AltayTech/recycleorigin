import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/core/utils/result.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('should create a Success result', () {
        const result = Success('test');
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
        expect(result.value, 'test');
      });

      test('should return valueOrNull for Success', () {
        const result = Success('test');
        expect(result.valueOrNull, 'test');
        expect(result.errorOrNull, isNull);
      });

      test('should map Success value', () {
        const result = Success(5);
        final mapped = result.map((value) => value * 2);
        expect(mapped.isSuccess, isTrue);
        expect(mapped.valueOrNull, 10);
      });

      test('should not map error on Success', () {
        const result = Success('test');
        final mapped = result.mapError((error) => 'mapped: $error');
        expect(mapped.isSuccess, isTrue);
        expect(mapped.valueOrNull, 'test');
      });

      test('should execute onSuccess callback', () {
        const result = Success('test');
        String? captured;
        result.onSuccess((value) {
          captured = value;
        });
        expect(captured, 'test');
      });

      test('should not execute onFailure callback', () {
        const result = Success('test');
        String? captured;
        result.onFailure((error) {
          captured = error;
        });
        expect(captured, isNull);
      });

      test('should unwrap Success value', () {
        const result = Success('test');
        expect(result.unwrap(), 'test');
      });

      test('should unwrapOr return value for Success', () {
        const result = Success('test');
        expect(result.unwrapOr('default'), 'test');
      });

      test('should unwrapOrElse return value for Success', () {
        const result = Success('test');
        expect(result.unwrapOrElse(() => 'default'), 'test');
      });

      test('should have correct equality', () {
        const result1 = Success('test');
        const result2 = Success('test');
        const result3 = Success('other');
        expect(result1 == result2, isTrue);
        expect(result1 == result3, isFalse);
      });

      test('should have correct toString', () {
        const result = Success('test');
        expect(result.toString(), 'Success(test)');
      });
    });

    group('Failure', () {
      test('should create a Failure result', () {
        const result = Failure('error');
        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);
        expect(result.message, 'error');
      });

      test('should return errorOrNull for Failure', () {
        const result = Failure('error');
        expect(result.valueOrNull, isNull);
        expect(result.errorOrNull, 'error');
      });

      test('should not map value on Failure', () {
        const result = Failure('error');
        final mapped = result.map((value) => value * 2);
        expect(mapped.isFailure, isTrue);
        expect(mapped.valueOrNull, isNull);
        expect(mapped.errorOrNull, 'error');
      });

      test('should map error on Failure', () {
        const result = Failure('error');
        final mapped = result.mapError((error) => 'mapped: $error');
        expect(mapped.isFailure, isTrue);
        expect(mapped.errorOrNull, 'mapped: error');
      });

      test('should not execute onSuccess callback', () {
        const result = Failure('error');
        String? captured;
        result.onSuccess((value) {
          captured = value;
        });
        expect(captured, isNull);
      });

      test('should execute onFailure callback', () {
        const result = Failure('error');
        String? captured;
        result.onFailure((error) {
          captured = error;
        });
        expect(captured, 'error');
      });

      test('should throw when unwrapping Failure', () {
        const result = Failure('error');
        expect(() => result.unwrap(), throwsException);
      });

      test('should unwrapOr return default for Failure', () {
        const result = Failure('error');
        expect(result.unwrapOr('default'), 'default');
      });

      test('should unwrapOrElse return computed default for Failure', () {
        const result = Failure('error');
        expect(result.unwrapOrElse(() => 'computed'), 'computed');
      });

      test('should have correct equality', () {
        const result1 = Failure('error');
        const result2 = Failure('error');
        const result3 = Failure('other');
        expect(result1 == result2, isTrue);
        expect(result1 == result3, isFalse);
      });

      test('should have correct toString', () {
        const result = Failure('error');
        expect(result.toString(), 'Failure(error)');
      });
    });

    group('Type safety', () {
      test('should maintain type through map', () {
        const result = Success(5);
        final mapped = result.map((value) => value.toString());
        expect(mapped.valueOrNull, isA<String>());
        expect(mapped.valueOrNull, '5');
      });

      test('should handle null values', () {
        const result = Success<String?>(null);
        expect(result.valueOrNull, isNull);
        expect(result.isSuccess, isTrue);
      });
    });
  });
}
