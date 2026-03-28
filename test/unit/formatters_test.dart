import 'package:flutter_test/flutter_test.dart';
import 'package:ikibina/core/utils/formatters.dart';

void main() {
  // ──────────────────────────────────────────
  // Formatters.currency
  // ──────────────────────────────────────────
  group('Formatters.currency', () {
    test('formats amount with default RWF symbol', () {
      final result = Formatters.currency(1000);
      expect(result, contains('RWF'));
      expect(result, contains('1,000'));
    });

    test('formats zero correctly', () {
      final result = Formatters.currency(0);
      expect(result, contains('0'));
    });

    test('formats large amount with thousands separator', () {
      final result = Formatters.currency(1000000);
      expect(result, contains('1,000,000'));
    });

    test('uses custom currency symbol', () {
      final result = Formatters.currency(500, symbol: 'USD');
      expect(result, contains('USD'));
      expect(result, contains('500'));
    });

    test('no decimal digits in output', () {
      final result = Formatters.currency(1234.9);
      expect(result, isNot(contains('.')));
    });
  });

  // ──────────────────────────────────────────
  // Formatters.date
  // ──────────────────────────────────────────
  group('Formatters.date', () {
    test('formats date as dd MMM yyyy', () {
      expect(Formatters.date(DateTime(2024, 3, 15)), '15 Mar 2024');
    });

    test('formats January with leading zero day', () {
      expect(Formatters.date(DateTime(2023, 1, 1)), '01 Jan 2023');
    });

    test('formats December correctly', () {
      expect(Formatters.date(DateTime(2025, 12, 31)), '31 Dec 2025');
    });
  });

  // ──────────────────────────────────────────
  // Formatters.shortDate
  // ──────────────────────────────────────────
  group('Formatters.shortDate', () {
    test('formats date as dd/MM/yyyy', () {
      expect(Formatters.shortDate(DateTime(2024, 3, 15)), '15/03/2024');
    });

    test('pads single-digit day and month with zero', () {
      expect(Formatters.shortDate(DateTime(2024, 1, 5)), '05/01/2024');
    });
  });

  // ──────────────────────────────────────────
  // Formatters.dateTime
  // ──────────────────────────────────────────
  group('Formatters.dateTime', () {
    test('includes date and 24-hour time', () {
      final result = Formatters.dateTime(DateTime(2024, 3, 15, 14, 30));
      expect(result, contains('15 Mar 2024'));
      expect(result, contains('14:30'));
    });

    test('formats midnight correctly', () {
      final result = Formatters.dateTime(DateTime(2024, 6, 1, 0, 0));
      expect(result, contains('00:00'));
    });
  });

  // ──────────────────────────────────────────
  // Formatters.relativeTime
  // ──────────────────────────────────────────
  group('Formatters.relativeTime', () {
    test('returns "Just now" for time within the last minute', () {
      final date = DateTime.now().subtract(const Duration(seconds: 30));
      expect(Formatters.relativeTime(date), 'Just now');
    });

    test('returns minutes ago', () {
      final date = DateTime.now().subtract(const Duration(minutes: 5));
      expect(Formatters.relativeTime(date), '5m ago');
    });

    test('returns hours ago', () {
      final date = DateTime.now().subtract(const Duration(hours: 3));
      expect(Formatters.relativeTime(date), '3h ago');
    });

    test('returns days ago', () {
      final date = DateTime.now().subtract(const Duration(days: 2));
      expect(Formatters.relativeTime(date), '2d ago');
    });

    test('returns months ago', () {
      final date = DateTime.now().subtract(const Duration(days: 45));
      expect(Formatters.relativeTime(date), '1mo ago');
    });

    test('returns years ago', () {
      final date = DateTime.now().subtract(const Duration(days: 400));
      expect(Formatters.relativeTime(date), '1y ago');
    });
  });
}
