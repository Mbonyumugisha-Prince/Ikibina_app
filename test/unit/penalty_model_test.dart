import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikibina/models/penalty_model.dart';

void main() {
  // ══════════════════════════════════════════
  // GroupPenaltyRules
  // ══════════════════════════════════════════

  group('GroupPenaltyRules.defaults()', () {
    test('gentleReminder is enabled with 24-hour window', () {
      final r = GroupPenaltyRules.defaults();
      expect(r.gentleReminderEnabled, isTrue);
      expect(r.gentleReminderHoursAfterDeadline, 24);
    });

    test('lateFee is enabled at 5% after 3 days', () {
      final r = GroupPenaltyRules.defaults();
      expect(r.lateFeeEnabled, isTrue);
      expect(r.lateFeeDaysLate, 3);
      expect(r.lateFeePercent, 5.0);
    });

    test('accountFreeze is disabled by default', () {
      final r = GroupPenaltyRules.defaults();
      expect(r.accountFreezeEnabled, isFalse);
      expect(r.accountFreezeCyclesMissed, 1);
    });

    test('expulsion is disabled by default', () {
      final r = GroupPenaltyRules.defaults();
      expect(r.expulsionEnabled, isFalse);
      expect(r.expulsionCyclesMissed, 3);
    });
  });

  group('GroupPenaltyRules.fromMap', () {
    test('parses all four tiers from a full nested map', () {
      final map = {
        'gentleReminder': {'enabled': true, 'hoursAfterDeadline': 48},
        'lateFee': {'enabled': true, 'daysLate': 5, 'feePercent': 10.0},
        'accountFreeze': {'enabled': true, 'cyclesMissed': 2},
        'expulsion': {'enabled': true, 'cyclesMissed': 4},
      };
      final r = GroupPenaltyRules.fromMap(map);
      expect(r.gentleReminderHoursAfterDeadline, 48);
      expect(r.lateFeeDaysLate, 5);
      expect(r.lateFeePercent, 10.0);
      expect(r.accountFreezeEnabled, isTrue);
      expect(r.accountFreezeCyclesMissed, 2);
      expect(r.expulsionEnabled, isTrue);
      expect(r.expulsionCyclesMissed, 4);
    });

    test('uses defaults when tier maps are missing entirely', () {
      final r = GroupPenaltyRules.fromMap({});
      expect(r.gentleReminderEnabled, isTrue);
      expect(r.lateFeeEnabled, isTrue);
      expect(r.accountFreezeEnabled, isFalse);
      expect(r.expulsionEnabled, isFalse);
    });

    test('uses defaults for missing fields within a tier', () {
      final map = {
        'gentleReminder': <String, dynamic>{},
        'lateFee': <String, dynamic>{},
        'accountFreeze': <String, dynamic>{},
        'expulsion': <String, dynamic>{},
      };
      final r = GroupPenaltyRules.fromMap(map);
      expect(r.gentleReminderHoursAfterDeadline, 24);
      expect(r.lateFeeDaysLate, 3);
      expect(r.lateFeePercent, 5.0);
      expect(r.accountFreezeCyclesMissed, 1);
      expect(r.expulsionCyclesMissed, 3);
    });

    test('correctly parses lateFeePercent stored as int', () {
      final map = {
        'lateFee': {'enabled': true, 'daysLate': 3, 'feePercent': 8},
      };
      final r = GroupPenaltyRules.fromMap(map);
      expect(r.lateFeePercent, 8.0);
      expect(r.lateFeePercent, isA<double>());
    });
  });

  group('GroupPenaltyRules.toMap', () {
    test('includes all four tier keys', () {
      final map = GroupPenaltyRules.defaults().toMap();
      expect(map, contains('gentleReminder'));
      expect(map, contains('lateFee'));
      expect(map, contains('accountFreeze'));
      expect(map, contains('expulsion'));
    });

    test('encodes gentleReminder tier correctly', () {
      final gr = GroupPenaltyRules.defaults().toMap()['gentleReminder'] as Map;
      expect(gr['enabled'], isTrue);
      expect(gr['hoursAfterDeadline'], 24);
    });

    test('encodes lateFee tier correctly', () {
      final lf = GroupPenaltyRules.defaults().toMap()['lateFee'] as Map;
      expect(lf['enabled'], isTrue);
      expect(lf['daysLate'], 3);
      expect(lf['feePercent'], 5.0);
    });

    test('encodes accountFreeze tier correctly', () {
      final af = GroupPenaltyRules.defaults().toMap()['accountFreeze'] as Map;
      expect(af['enabled'], isFalse);
      expect(af['cyclesMissed'], 1);
    });

    test('encodes expulsion tier correctly', () {
      final ex = GroupPenaltyRules.defaults().toMap()['expulsion'] as Map;
      expect(ex['enabled'], isFalse);
      expect(ex['cyclesMissed'], 3);
    });

    test('round-trips through fromMap without data loss', () {
      final original = GroupPenaltyRules.defaults();
      final copy = GroupPenaltyRules.fromMap(original.toMap());
      expect(copy.gentleReminderEnabled, original.gentleReminderEnabled);
      expect(copy.gentleReminderHoursAfterDeadline,
          original.gentleReminderHoursAfterDeadline);
      expect(copy.lateFeePercent, original.lateFeePercent);
      expect(copy.accountFreezeEnabled, original.accountFreezeEnabled);
      expect(copy.expulsionCyclesMissed, original.expulsionCyclesMissed);
    });
  });

  group('GroupPenaltyRules.copyWith', () {
    test('updates only the specified fields', () {
      final original = GroupPenaltyRules.defaults();
      final updated = original.copyWith(
        lateFeePercent: 8.0,
        expulsionEnabled: true,
        expulsionCyclesMissed: 2,
      );
      expect(updated.lateFeePercent, 8.0);
      expect(updated.expulsionEnabled, isTrue);
      expect(updated.expulsionCyclesMissed, 2);
    });

    test('leaves unchanged fields at their original values', () {
      final original = GroupPenaltyRules.defaults();
      final updated = original.copyWith(lateFeePercent: 8.0);
      expect(updated.gentleReminderEnabled, original.gentleReminderEnabled);
      expect(updated.gentleReminderHoursAfterDeadline,
          original.gentleReminderHoursAfterDeadline);
      expect(updated.lateFeeDaysLate, original.lateFeeDaysLate);
      expect(updated.accountFreezeEnabled, original.accountFreezeEnabled);
      expect(updated.accountFreezeCyclesMissed,
          original.accountFreezeCyclesMissed);
    });

    test('returns an equal copy when called with no arguments', () {
      final original = GroupPenaltyRules.defaults();
      final copy = original.copyWith();
      expect(copy.gentleReminderEnabled, original.gentleReminderEnabled);
      expect(copy.lateFeePercent, original.lateFeePercent);
      expect(copy.expulsionCyclesMissed, original.expulsionCyclesMissed);
    });

    test('can enable all tiers at once', () {
      final updated = GroupPenaltyRules.defaults().copyWith(
        accountFreezeEnabled: true,
        expulsionEnabled: true,
      );
      expect(updated.accountFreezeEnabled, isTrue);
      expect(updated.expulsionEnabled, isTrue);
    });
  });

  // ══════════════════════════════════════════
  // PenaltyRecordModel
  // ══════════════════════════════════════════

  group('PenaltyRecordModel', () {
    final appliedAt = DateTime(2024, 4, 10);

    // ── fromMap ────────────────────────────
    group('fromMap', () {
      test('parses all fields correctly', () {
        final map = {
          'groupId': 'g1',
          'groupName': 'Savings Club',
          'userId': 'u1',
          'userName': 'Alice',
          'type': 'late_fee',
          'description': 'Late by 3 days',
          'amount': 250.0,
          'appliedAt': Timestamp.fromDate(appliedAt),
          'resolved': false,
        };
        final r = PenaltyRecordModel.fromMap('pr1', map);
        expect(r.id, 'pr1');
        expect(r.groupId, 'g1');
        expect(r.groupName, 'Savings Club');
        expect(r.userId, 'u1');
        expect(r.userName, 'Alice');
        expect(r.type, 'late_fee');
        expect(r.description, 'Late by 3 days');
        expect(r.amount, 250.0);
        expect(r.resolved, isFalse);
        expect(r.appliedAt, appliedAt);
      });

      test('defaults resolved to false when missing', () {
        final map = {
          'groupId': 'g1',
          'groupName': 'Group',
          'userId': 'u1',
          'userName': 'Bob',
          'type': 'gentle_reminder',
          'description': 'Reminder',
          'amount': 0,
          'appliedAt': Timestamp.fromDate(appliedAt),
        };
        final r = PenaltyRecordModel.fromMap('pr2', map);
        expect(r.resolved, isFalse);
      });

      test('defaults amount to 0.0 when missing', () {
        final map = {
          'groupId': 'g1',
          'groupName': 'Group',
          'userId': 'u1',
          'userName': 'Carol',
          'type': 'account_freeze',
          'description': 'Frozen',
          'appliedAt': Timestamp.fromDate(appliedAt),
        };
        final r = PenaltyRecordModel.fromMap('pr3', map);
        expect(r.amount, 0.0);
      });

      test('defaults string fields to empty string when missing', () {
        final map = {
          'appliedAt': Timestamp.fromDate(appliedAt),
        };
        final r = PenaltyRecordModel.fromMap('pr4', map);
        expect(r.groupId, '');
        expect(r.groupName, '');
        expect(r.userId, '');
        expect(r.userName, '');
        expect(r.type, '');
        expect(r.description, '');
      });
    });

    // ── toMap ──────────────────────────────
    group('toMap', () {
      test('returns all required keys and values', () {
        final r = PenaltyRecordModel(
          id: 'pr1',
          groupId: 'g1',
          groupName: 'Savings Club',
          userId: 'u1',
          userName: 'Alice',
          type: 'late_fee',
          description: 'Late by 3 days',
          amount: 250.0,
          appliedAt: appliedAt,
          resolved: false,
        );
        final map = r.toMap();
        expect(map['groupId'], 'g1');
        expect(map['groupName'], 'Savings Club');
        expect(map['userId'], 'u1');
        expect(map['userName'], 'Alice');
        expect(map['type'], 'late_fee');
        expect(map['amount'], 250.0);
        expect(map['resolved'], isFalse);
        expect(map, contains('appliedAt'));
      });

      test('toMap round-trips through fromMap', () {
        final original = PenaltyRecordModel(
          id: 'pr1',
          groupId: 'g1',
          groupName: 'Group',
          userId: 'u1',
          userName: 'Alice',
          type: 'late_fee',
          description: 'Test',
          amount: 100,
          appliedAt: appliedAt,
          resolved: true,
        );
        final copy = PenaltyRecordModel.fromMap('pr1', {
          ...original.toMap(),
          'appliedAt': Timestamp.fromDate(appliedAt),
        });
        expect(copy.groupId, original.groupId);
        expect(copy.type, original.type);
        expect(copy.amount, original.amount);
        expect(copy.resolved, original.resolved);
        expect(copy.appliedAt, original.appliedAt);
      });
    });

    // ── constructor ────────────────────────
    group('constructor', () {
      test('resolved defaults to false', () {
        final r = PenaltyRecordModel(
          id: 'pr1',
          groupId: 'g1',
          groupName: 'Group',
          userId: 'u1',
          userName: 'Alice',
          type: 'gentle_reminder',
          description: 'Reminder',
          amount: 0,
          appliedAt: appliedAt,
        );
        expect(r.resolved, isFalse);
      });
    });

    // ── penalty types ──────────────────────
    group('penalty types', () {
      for (final type in [
        'gentle_reminder',
        'late_fee',
        'account_freeze',
        'expulsion',
      ]) {
        test('accepts type "$type"', () {
          final map = {
            'groupId': 'g1',
            'groupName': 'Group',
            'userId': 'u1',
            'userName': 'Alice',
            'type': type,
            'description': 'Test',
            'amount': 0,
            'appliedAt': Timestamp.fromDate(appliedAt),
          };
          expect(PenaltyRecordModel.fromMap('pr', map).type, type);
        });
      }
    });
  });
}
