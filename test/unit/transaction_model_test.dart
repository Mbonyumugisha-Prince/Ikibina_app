import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikibina/models/transaction_model.dart';

void main() {
  group('TransactionModel', () {
    final date = DateTime(2024, 5, 20);

    // ── fromMap ──────────────────────────────
    group('fromMap', () {
      test('parses all fields correctly', () {
        final map = {
          'groupId': 'g1',
          'userId': 'u1',
          'userName': 'Alice',
          'type': 'contribution',
          'amount': 5000,
          'date': Timestamp.fromDate(date),
          'description': 'May contribution',
        };
        final t = TransactionModel.fromMap('t1', map);
        expect(t.id, 't1');
        expect(t.groupId, 'g1');
        expect(t.userId, 'u1');
        expect(t.userName, 'Alice');
        expect(t.type, 'contribution');
        expect(t.amount, 5000.0);
        expect(t.date, date);
        expect(t.description, 'May contribution');
      });

      test('handles null description', () {
        final map = {
          'groupId': 'g1',
          'userId': 'u1',
          'userName': 'Bob',
          'type': 'withdrawal',
          'amount': 3000,
          'date': Timestamp.fromDate(date),
          'description': null,
        };
        final t = TransactionModel.fromMap('t2', map);
        expect(t.description, isNull);
      });

      test('defaults type to empty string when missing', () {
        final map = {
          'groupId': 'g1',
          'userId': 'u1',
          'userName': 'Carol',
          'amount': 2000,
          'date': Timestamp.fromDate(date),
        };
        final t = TransactionModel.fromMap('t3', map);
        expect(t.type, '');
      });

      test('defaults amount to 0.0 when missing', () {
        final map = {
          'groupId': 'g1',
          'userId': 'u1',
          'userName': 'Dan',
          'type': 'fine',
          'date': Timestamp.fromDate(date),
        };
        final t = TransactionModel.fromMap('t4', map);
        expect(t.amount, 0.0);
      });

      test('parses amount as double when stored as int', () {
        final map = {
          'groupId': 'g1',
          'userId': 'u1',
          'userName': 'Eve',
          'type': 'loan',
          'amount': 20000,
          'date': Timestamp.fromDate(date),
        };
        final t = TransactionModel.fromMap('t5', map);
        expect(t.amount, isA<double>());
        expect(t.amount, 20000.0);
      });
    });

    // ── toMap ────────────────────────────────
    group('toMap', () {
      test('returns correct keys and values', () {
        final t = TransactionModel(
          id: 't1',
          groupId: 'g1',
          userId: 'u1',
          userName: 'Alice',
          type: 'loan',
          amount: 20000,
          date: date,
          description: 'Loan disbursement',
        );
        final map = t.toMap();
        expect(map['groupId'], 'g1');
        expect(map['userId'], 'u1');
        expect(map['userName'], 'Alice');
        expect(map['type'], 'loan');
        expect(map['amount'], 20000.0);
        expect(map['description'], 'Loan disbursement');
        expect(map, contains('date'));
      });

      test('stores null description', () {
        final t = TransactionModel(
          id: 't1',
          groupId: 'g1',
          userId: 'u1',
          userName: 'Eve',
          type: 'fine',
          amount: 500,
          date: date,
        );
        expect(t.toMap()['description'], isNull);
      });

      test('amount is stored as double', () {
        final t = TransactionModel(
          id: 't1',
          groupId: 'g1',
          userId: 'u1',
          userName: 'Alice',
          type: 'contribution',
          amount: 7500,
          date: date,
        );
        expect(t.toMap()['amount'], 7500.0);
      });
    });

    // ── round-trip ───────────────────────────
    group('round-trip', () {
      test('fromMap and toMap preserve all fields', () {
        final original = TransactionModel(
          id: 't1',
          groupId: 'g1',
          userId: 'u1',
          userName: 'Alice',
          type: 'contribution',
          amount: 5000,
          date: date,
          description: 'Test note',
        );
        final copy = TransactionModel.fromMap('t1', {
          ...original.toMap(),
          'date': Timestamp.fromDate(date),
        });
        expect(copy.groupId, original.groupId);
        expect(copy.userId, original.userId);
        expect(copy.type, original.type);
        expect(copy.amount, original.amount);
        expect(copy.description, original.description);
        expect(copy.date, original.date);
      });
    });

    // ── transaction types ────────────────────
    group('transaction types', () {
      for (final type in ['contribution', 'loan', 'withdrawal', 'fine']) {
        test('accepts type "$type"', () {
          final map = {
            'groupId': 'g1',
            'userId': 'u1',
            'userName': 'Alice',
            'type': type,
            'amount': 1000,
            'date': Timestamp.fromDate(date),
          };
          final t = TransactionModel.fromMap('tx', map);
          expect(t.type, type);
        });
      }
    });
  });
}
