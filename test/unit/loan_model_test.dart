import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikibina/models/loan_model.dart';

// Helper that builds a LoanModel with sensible defaults so each test
// only has to specify the fields it cares about.
LoanModel _makeLoan({
  String id = 'loan1',
  double amount = 10000,
  int durationWeeks = 2,
  String status = 'approved',
  double amountPaid = 0,
  List<String> approvedBy = const [],
  List<String> rejectedBy = const [],
  DateTime? requestedAt,
  DateTime? dueDate,
}) {
  final now = DateTime.now();
  return LoanModel(
    id: id,
    groupId: 'g1',
    userId: 'u1',
    userName: 'Alice',
    amount: amount,
    durationWeeks: durationWeeks,
    requestedAt: requestedAt ?? now,
    dueDate: dueDate ?? now.add(const Duration(days: 14)),
    status: status,
    approvedBy: approvedBy,
    rejectedBy: rejectedBy,
    amountPaid: amountPaid,
  );
}

void main() {
  // ──────────────────────────────────────────
  // Constants
  // ──────────────────────────────────────────
  group('LoanModel constants', () {
    test('processingFee is 1000', () {
      expect(LoanModel.processingFee, 1000.0);
    });

    test('normalRate is 7%', () {
      expect(LoanModel.normalRate, 0.07);
    });

    test('overdueRate is 15%', () {
      expect(LoanModel.overdueRate, 0.15);
    });
  });

  // ──────────────────────────────────────────
  // isOverdue
  // ──────────────────────────────────────────
  group('LoanModel.isOverdue', () {
    test('is true when past due date and status is approved', () {
      final loan = _makeLoan(
        status: 'approved',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(loan.isOverdue, isTrue);
    });

    test('is false when past due date but status is completed', () {
      final loan = _makeLoan(
        status: 'completed',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(loan.isOverdue, isFalse);
    });

    test('is false when status is approved but due date is in the future', () {
      final loan = _makeLoan(
        status: 'approved',
        dueDate: DateTime.now().add(const Duration(days: 7)),
      );
      expect(loan.isOverdue, isFalse);
    });

    test('is false for pending loan past due date', () {
      final loan = _makeLoan(
        status: 'pending',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
      );
      expect(loan.isOverdue, isFalse);
    });

    test('is false for rejected loan past due date', () {
      final loan = _makeLoan(
        status: 'rejected',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
      );
      expect(loan.isOverdue, isFalse);
    });
  });

  // ──────────────────────────────────────────
  // interestRate
  // ──────────────────────────────────────────
  group('LoanModel.interestRate', () {
    test('is normalRate (7%) when not overdue', () {
      final loan = _makeLoan(
        status: 'approved',
        dueDate: DateTime.now().add(const Duration(days: 7)),
      );
      expect(loan.interestRate, LoanModel.normalRate);
    });

    test('is overdueRate (15%) when overdue', () {
      final loan = _makeLoan(
        status: 'approved',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(loan.interestRate, LoanModel.overdueRate);
    });
  });

  // ──────────────────────────────────────────
  // interest
  // ──────────────────────────────────────────
  group('LoanModel.interest', () {
    test('is amount × normalRate when not overdue', () {
      final loan = _makeLoan(amount: 10000);
      expect(loan.interest, closeTo(700.0, 0.001)); // 10 000 × 0.07
    });

    test('is amount × overdueRate when overdue', () {
      final loan = _makeLoan(
        amount: 10000,
        status: 'approved',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(loan.interest, 1500.0); // 10 000 × 0.15
    });

    test('scales correctly for a smaller amount', () {
      final loan = _makeLoan(amount: 5000);
      expect(loan.interest, closeTo(350.0, 0.001)); // 5 000 × 0.07
    });
  });

  // ──────────────────────────────────────────
  // totalToRepay
  // ──────────────────────────────────────────
  group('LoanModel.totalToRepay', () {
    test('is amount + normal interest + processingFee when not overdue', () {
      final loan = _makeLoan(amount: 10000);
      // 10 000 + 700 + 1 000 = 11 700
      expect(loan.totalToRepay, 11700.0);
    });

    test('is amount + overdue interest + processingFee when overdue', () {
      final loan = _makeLoan(
        amount: 10000,
        status: 'approved',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      // 10 000 + 1 500 + 1 000 = 12 500
      expect(loan.totalToRepay, 12500.0);
    });

    test('always includes the fixed processingFee of 1000', () {
      final loan = _makeLoan(amount: 20000);
      expect(loan.totalToRepay - loan.amount - loan.interest, closeTo(1000.0, 0.001));
    });
  });

  // ──────────────────────────────────────────
  // remaining
  // ──────────────────────────────────────────
  group('LoanModel.remaining', () {
    test('equals totalToRepay when nothing has been paid', () {
      final loan = _makeLoan(amount: 10000, amountPaid: 0);
      expect(loan.remaining, loan.totalToRepay);
    });

    test('subtracts amountPaid from totalToRepay', () {
      final loan = _makeLoan(amount: 10000, amountPaid: 5000);
      expect(loan.remaining, loan.totalToRepay - 5000);
    });

    test('is 0 when amountPaid equals totalToRepay', () {
      final loan = _makeLoan(amount: 10000);
      final paid = _makeLoan(amount: 10000, amountPaid: loan.totalToRepay);
      expect(paid.remaining, 0.0);
    });

    test('clamps to 0 when amountPaid exceeds totalToRepay', () {
      final loan = _makeLoan(amount: 10000, amountPaid: 99999);
      expect(loan.remaining, 0.0);
    });
  });

  // ──────────────────────────────────────────
  // progress
  // ──────────────────────────────────────────
  group('LoanModel.progress', () {
    test('is 0.0 when nothing has been paid', () {
      final loan = _makeLoan(amount: 10000, amountPaid: 0);
      expect(loan.progress, 0.0);
    });

    test('is 1.0 when fully paid', () {
      final loan = _makeLoan(amount: 10000);
      final paid = _makeLoan(amount: 10000, amountPaid: loan.totalToRepay);
      expect(paid.progress, 1.0);
    });

    test('is between 0 and 1 for a partial payment', () {
      final loan = _makeLoan(amount: 10000, amountPaid: 5000);
      expect(loan.progress, greaterThan(0.0));
      expect(loan.progress, lessThan(1.0));
    });

    test('clamps to 1.0 when overpaid', () {
      final loan = _makeLoan(amount: 10000, amountPaid: 999999);
      expect(loan.progress, 1.0);
    });

    test('is approximately 0.5 when half paid', () {
      final loan = _makeLoan(amount: 10000);
      final halfPaid =
          _makeLoan(amount: 10000, amountPaid: loan.totalToRepay / 2);
      expect(halfPaid.progress, closeTo(0.5, 0.001));
    });
  });

  // ──────────────────────────────────────────
  // fromMap
  // ──────────────────────────────────────────
  group('LoanModel.fromMap', () {
    final requestedAt = DateTime(2024, 3, 1);
    final dueDate = DateTime(2024, 3, 15);

    test('parses all fields correctly', () {
      final map = {
        'groupId': 'g1',
        'userId': 'u1',
        'userName': 'Alice',
        'amount': 15000,
        'durationWeeks': 2,
        'requestedAt': Timestamp.fromDate(requestedAt),
        'dueDate': Timestamp.fromDate(dueDate),
        'status': 'approved',
        'approvedBy': ['admin1'],
        'rejectedBy': <String>[],
        'amountPaid': 5000,
      };
      final loan = LoanModel.fromMap('loan1', map);
      expect(loan.id, 'loan1');
      expect(loan.groupId, 'g1');
      expect(loan.userId, 'u1');
      expect(loan.userName, 'Alice');
      expect(loan.amount, 15000.0);
      expect(loan.durationWeeks, 2);
      expect(loan.status, 'approved');
      expect(loan.approvedBy, ['admin1']);
      expect(loan.rejectedBy, isEmpty);
      expect(loan.amountPaid, 5000.0);
      expect(loan.requestedAt, requestedAt);
      expect(loan.dueDate, dueDate);
    });

    test('defaults status to "pending" when missing', () {
      final map = {
        'groupId': 'g1',
        'userId': 'u1',
        'userName': 'Bob',
        'amount': 5000,
        'durationWeeks': 1,
        'requestedAt': Timestamp.fromDate(requestedAt),
        'dueDate': Timestamp.fromDate(dueDate),
      };
      final loan = LoanModel.fromMap('loan2', map);
      expect(loan.status, 'pending');
    });

    test('defaults amountPaid to 0.0 when missing', () {
      final map = {
        'groupId': 'g1',
        'userId': 'u1',
        'userName': 'Carol',
        'amount': 5000,
        'durationWeeks': 1,
        'requestedAt': Timestamp.fromDate(requestedAt),
        'dueDate': Timestamp.fromDate(dueDate),
      };
      final loan = LoanModel.fromMap('loan3', map);
      expect(loan.amountPaid, 0.0);
    });

    test('defaults approvedBy and rejectedBy to empty lists', () {
      final map = {
        'groupId': 'g1',
        'userId': 'u1',
        'userName': 'Dan',
        'amount': 5000,
        'durationWeeks': 1,
        'requestedAt': Timestamp.fromDate(requestedAt),
        'dueDate': Timestamp.fromDate(dueDate),
      };
      final loan = LoanModel.fromMap('loan4', map);
      expect(loan.approvedBy, isEmpty);
      expect(loan.rejectedBy, isEmpty);
    });

    test('defaults durationWeeks to 1 when missing', () {
      final map = {
        'groupId': 'g1',
        'userId': 'u1',
        'userName': 'Eve',
        'amount': 5000,
        'requestedAt': Timestamp.fromDate(requestedAt),
        'dueDate': Timestamp.fromDate(dueDate),
      };
      final loan = LoanModel.fromMap('loan5', map);
      expect(loan.durationWeeks, 1);
    });
  });

  // ──────────────────────────────────────────
  // toMap
  // ──────────────────────────────────────────
  group('LoanModel.toMap', () {
    test('includes all required keys', () {
      final loan = _makeLoan(
        amount: 10000,
        status: 'approved',
        approvedBy: ['admin1'],
      );
      final map = loan.toMap();
      expect(map['groupId'], 'g1');
      expect(map['userId'], 'u1');
      expect(map['userName'], 'Alice');
      expect(map['amount'], 10000.0);
      expect(map['durationWeeks'], 2);
      expect(map['status'], 'approved');
      expect(map['approvedBy'], ['admin1']);
      expect(map['amountPaid'], 0.0);
      expect(map, contains('requestedAt'));
      expect(map, contains('dueDate'));
    });

    test('toMap round-trips approvedBy list', () {
      final loan = _makeLoan(approvedBy: ['admin1', 'admin2']);
      expect(loan.toMap()['approvedBy'], ['admin1', 'admin2']);
    });
  });
}
