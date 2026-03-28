import 'package:flutter_test/flutter_test.dart';
import 'package:ikibina/core/utils/validators.dart';

void main() {
  // ──────────────────────────────────────────
  // Validators.email
  // ──────────────────────────────────────────
  group('Validators.email', () {
    test('returns error for null', () {
      expect(Validators.email(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.email(''), 'Email is required');
    });

    test('returns error for missing @ symbol', () {
      expect(Validators.email('notanemail'), isNotNull);
    });

    test('returns error for missing domain part', () {
      expect(Validators.email('user@'), isNotNull);
    });

    test('returns null for valid email', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('returns null for valid email with subdomain', () {
      expect(Validators.email('user@mail.example.org'), isNull);
    });

    test('returns null for email with dots in local part', () {
      expect(Validators.email('first.last@example.com'), isNull);
    });
  });

  // ──────────────────────────────────────────
  // Validators.password
  // ──────────────────────────────────────────
  group('Validators.password', () {
    test('returns error for null', () {
      expect(Validators.password(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.password(''), 'Password is required');
    });

    test('returns error for password shorter than 6 characters', () {
      expect(Validators.password('abc'), isNotNull);
      expect(Validators.password('12345'), isNotNull);
    });

    test('returns null for password of exactly 6 characters', () {
      expect(Validators.password('abc123'), isNull);
    });

    test('returns null for long password', () {
      expect(Validators.password('securePassword!99'), isNull);
    });
  });

  // ──────────────────────────────────────────
  // Validators.required
  // ──────────────────────────────────────────
  group('Validators.required', () {
    test('returns error for null', () {
      expect(Validators.required(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.required(''), isNotNull);
    });

    test('returns error for whitespace-only string', () {
      expect(Validators.required('   '), isNotNull);
    });

    test('returns null for non-empty string', () {
      expect(Validators.required('Hello'), isNull);
    });

    test('includes custom fieldName in error message', () {
      final msg = Validators.required(null, fieldName: 'Full Name');
      expect(msg, contains('Full Name'));
    });

    test('uses default field name when not provided', () {
      final msg = Validators.required('');
      expect(msg, contains('This field'));
    });
  });

  // ──────────────────────────────────────────
  // Validators.phone
  // ──────────────────────────────────────────
  group('Validators.phone', () {
    test('returns error for null', () {
      expect(Validators.phone(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.phone(''), 'Phone number is required');
    });

    test('returns error for number that is too short (< 9 digits)', () {
      expect(Validators.phone('12345678'), isNotNull);
    });

    test('returns null for valid phone with + prefix', () {
      expect(Validators.phone('+250788123456'), isNull);
    });

    test('returns null for valid 10-digit phone without prefix', () {
      expect(Validators.phone('0788123456'), isNull);
    });

    test('returns null for phone with spaces (stripped internally)', () {
      expect(Validators.phone('+250 788 123 456'), isNull);
    });
  });

  // ──────────────────────────────────────────
  // Validators.amount
  // ──────────────────────────────────────────
  group('Validators.amount', () {
    test('returns error for null', () {
      expect(Validators.amount(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.amount(''), 'Amount is required');
    });

    test('returns error for non-numeric string', () {
      expect(Validators.amount('abc'), isNotNull);
    });

    test('returns error for zero', () {
      expect(Validators.amount('0'), isNotNull);
    });

    test('returns error for negative amount', () {
      expect(Validators.amount('-100'), isNotNull);
    });

    test('returns null for valid positive integer amount', () {
      expect(Validators.amount('5000'), isNull);
    });

    test('returns null for valid decimal amount', () {
      expect(Validators.amount('99.5'), isNull);
    });

    test('returns error for amount of exactly 0.0', () {
      expect(Validators.amount('0.0'), isNotNull);
    });
  });
}
