import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/utils/validators.dart';

void main() {
  group('Validators', () {
    group('required', () {
      test('returns error for null value', () {
        expect(Validators.required(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(Validators.required(''), isNotNull);
      });

      test('returns null for valid value', () {
        expect(Validators.required('test'), isNull);
      });
    });

    group('email', () {
      test('returns error for invalid email', () {
        expect(Validators.email('notanemail'), isNotNull);
      });

      test('returns null for valid email', () {
        expect(Validators.email('test@example.com'), isNull);
      });
    });

    group('phone', () {
      test('returns error for invalid phone', () {
        expect(Validators.phone('1234567890'), isNotNull);
      });

      test('returns null for valid Egyptian phone', () {
        expect(Validators.phone('01012345678'), isNull);
        expect(Validators.phone('01112345678'), isNull);
      });
    });

    group('password', () {
      test('returns error for short password', () {
        expect(Validators.password('1234567'), isNotNull);
      });

      test('returns null for valid password', () {
        expect(Validators.password('12345678'), isNull);
      });
    });

    group('nationalId', () {
      test('returns error for invalid national ID', () {
        expect(Validators.nationalId('1234567890'), isNotNull);
      });

      test('returns null for valid national ID (14 digits)', () {
        expect(Validators.nationalId('29801011234567'), isNull);
      });
    });

    group('licensePlate', () {
      test('returns error for empty plate', () {
        expect(Validators.licensePlate(''), isNotNull);
      });

      test('returns error for short plate', () {
        expect(Validators.licensePlate('AB'), isNotNull);
      });

      test('returns null for valid plate', () {
        expect(Validators.licensePlate('ABC123'), isNull);
      });
    });
  });
}
