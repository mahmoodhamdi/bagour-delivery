import 'package:flutter_test/flutter_test.dart';
import 'package:customer_app/utils/validators.dart';

void main() {
  group('Validators', () {
    group('required', () {
      test('returns error for null value', () {
        expect(Validators.required(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(Validators.required(''), isNotNull);
      });

      test('returns error for whitespace only', () {
        expect(Validators.required('   '), isNotNull);
      });

      test('returns null for valid value', () {
        expect(Validators.required('test'), isNull);
      });

      test('includes field name in error message', () {
        final error = Validators.required(null, 'الاسم');
        expect(error, contains('الاسم'));
      });
    });

    group('email', () {
      test('returns error for empty email', () {
        expect(Validators.email(''), isNotNull);
      });

      test('returns error for invalid email format', () {
        expect(Validators.email('notanemail'), isNotNull);
        expect(Validators.email('test@'), isNotNull);
        expect(Validators.email('@test.com'), isNotNull);
      });

      test('returns null for valid email', () {
        expect(Validators.email('test@example.com'), isNull);
        expect(Validators.email('user.name@domain.co'), isNull);
      });
    });

    group('phone', () {
      test('returns error for empty phone', () {
        expect(Validators.phone(''), isNotNull);
      });

      test('returns error for invalid Egyptian phone', () {
        expect(Validators.phone('1234567890'), isNotNull);
        expect(Validators.phone('01312345678'), isNotNull);
        expect(Validators.phone('0101234567'), isNotNull); // 10 digits
      });

      test('returns null for valid Egyptian phone', () {
        expect(Validators.phone('01012345678'), isNull);
        expect(Validators.phone('01112345678'), isNull);
        expect(Validators.phone('01212345678'), isNull);
        expect(Validators.phone('01512345678'), isNull);
      });
    });

    group('password', () {
      test('returns error for empty password', () {
        expect(Validators.password(''), isNotNull);
      });

      test('returns error for short password', () {
        expect(Validators.password('1234567'), isNotNull);
      });

      test('returns null for valid password', () {
        expect(Validators.password('12345678'), isNull);
        expect(Validators.password('mypassword123'), isNull);
      });
    });

    group('confirmPassword', () {
      test('returns error for empty confirmation', () {
        expect(Validators.confirmPassword('', 'password'), isNotNull);
      });

      test('returns error for mismatched passwords', () {
        expect(Validators.confirmPassword('password1', 'password2'), isNotNull);
      });

      test('returns null for matching passwords', () {
        expect(Validators.confirmPassword('password', 'password'), isNull);
      });
    });

    group('name', () {
      test('returns error for empty name', () {
        expect(Validators.name(''), isNotNull);
      });

      test('returns error for single character name', () {
        expect(Validators.name('A'), isNotNull);
      });

      test('returns error for name over 50 characters', () {
        expect(Validators.name('A' * 51), isNotNull);
      });

      test('returns null for valid name', () {
        expect(Validators.name('Ahmed'), isNull);
        expect(Validators.name('Ahmed Mohamed'), isNull);
      });
    });

    group('otp', () {
      test('returns error for empty OTP', () {
        expect(Validators.otp(''), isNotNull);
      });

      test('returns error for OTP not 6 digits', () {
        expect(Validators.otp('12345'), isNotNull);
        expect(Validators.otp('1234567'), isNotNull);
      });

      test('returns error for non-numeric OTP', () {
        expect(Validators.otp('abcdef'), isNotNull);
        expect(Validators.otp('12345a'), isNotNull);
      });

      test('returns null for valid OTP', () {
        expect(Validators.otp('123456'), isNull);
        expect(Validators.otp('000000'), isNull);
      });
    });

    group('minLength', () {
      test('returns error when value is too short', () {
        expect(Validators.minLength('ab', 3), isNotNull);
      });

      test('returns null when value meets minimum', () {
        expect(Validators.minLength('abc', 3), isNull);
        expect(Validators.minLength('abcd', 3), isNull);
      });
    });

    group('maxLength', () {
      test('returns error when value is too long', () {
        expect(Validators.maxLength('abcd', 3), isNotNull);
      });

      test('returns null when value is within limit', () {
        expect(Validators.maxLength('abc', 3), isNull);
        expect(Validators.maxLength('ab', 3), isNull);
      });

      test('returns null for null value', () {
        expect(Validators.maxLength(null, 3), isNull);
      });
    });

    group('positiveNumber', () {
      test('returns error for empty value', () {
        expect(Validators.positiveNumber(''), isNotNull);
      });

      test('returns error for non-numeric value', () {
        expect(Validators.positiveNumber('abc'), isNotNull);
      });

      test('returns error for zero', () {
        expect(Validators.positiveNumber('0'), isNotNull);
      });

      test('returns error for negative number', () {
        expect(Validators.positiveNumber('-5'), isNotNull);
      });

      test('returns null for positive number', () {
        expect(Validators.positiveNumber('10'), isNull);
        expect(Validators.positiveNumber('10.5'), isNull);
      });
    });
  });
}
