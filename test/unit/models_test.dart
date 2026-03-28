import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikibina/models/contribution_model.dart';
import 'package:ikibina/models/group_model.dart';

void main() {
  // ──────────────────────────────────────────
  // MilestoneModel
  // ──────────────────────────────────────────
  group('MilestoneModel', () {
    test('fromMap parses name and targetAmount', () {
      final m = MilestoneModel.fromMap({'name': 'Phase 1', 'targetAmount': 50000});
      expect(m.name, 'Phase 1');
      expect(m.targetAmount, 50000.0);
    });

    test('fromMap uses defaults for missing fields', () {
      final m = MilestoneModel.fromMap({});
      expect(m.name, '');
      expect(m.targetAmount, 0.0);
    });

    test('toMap returns correct keys and values', () {
      final m = MilestoneModel(name: 'Phase 1', targetAmount: 50000);
      final map = m.toMap();
      expect(map['name'], 'Phase 1');
      expect(map['targetAmount'], 50000.0);
    });

    test('toMap round-trips through fromMap', () {
      final original = MilestoneModel(name: 'Roof', targetAmount: 200000);
      final copy = MilestoneModel.fromMap(original.toMap());
      expect(copy.name, original.name);
      expect(copy.targetAmount, original.targetAmount);
    });
  });

  // ──────────────────────────────────────────
  // GroupModel
  // ──────────────────────────────────────────
  group('GroupModel', () {
    final createdAt = DateTime(2024, 1, 1);

    test('adminId defaults to createdBy when not supplied', () {
      final g = GroupModel(
        id: 'g1',
        name: 'Group A',
        description: 'desc',
        createdBy: 'user1',
        contributionAmount: 5000,
        contributionFrequency: 'Monthly',
        createdAt: createdAt,
      );
      expect(g.adminId, 'user1');
    });

    test('goalAmount sums all milestone targetAmounts', () {
      final g = GroupModel(
        id: 'g1',
        name: 'Goal Group',
        description: '',
        createdBy: 'user1',
        contributionAmount: 0,
        contributionFrequency: 'Monthly',
        createdAt: createdAt,
        groupType: 'goal',
        milestones: [
          MilestoneModel(name: 'M1', targetAmount: 20000),
          MilestoneModel(name: 'M2', targetAmount: 30000),
        ],
      );
      expect(g.goalAmount, 50000.0);
    });

    test('goalAmount is 0.0 when there are no milestones', () {
      final g = GroupModel(
        id: 'g1',
        name: 'Group',
        description: '',
        createdBy: 'user1',
        contributionAmount: 5000,
        contributionFrequency: 'Monthly',
        createdAt: createdAt,
      );
      expect(g.goalAmount, 0.0);
    });

    test('fromMap parses all fields correctly', () {
      final map = {
        'name': 'Test Group',
        'description': 'A test',
        'createdBy': 'user1',
        'adminId': 'user1',
        'inviteCode': 'ABC123',
        'groupType': 'ikimina',
        'contributionAmount': 5000,
        'contributionFrequency': 'Weekly',
        'duration': '6 months',
        'milestones': <Map<String, dynamic>>[],
        'totalSavings': 15000,
        'members': ['user1', 'user2'],
        'suspendedMembers': <String>[],
        'memberCount': 2,
        'imageUrl': null,
        'createdAt': Timestamp.fromDate(DateTime(2024, 6, 1)),
      };
      final g = GroupModel.fromMap('g1', map);
      expect(g.id, 'g1');
      expect(g.name, 'Test Group');
      expect(g.inviteCode, 'ABC123');
      expect(g.contributionFrequency, 'Weekly');
      expect(g.totalSavings, 15000.0);
      expect(g.members.length, 2);
      expect(g.duration, '6 months');
    });

    test('fromMap falls back to defaults for missing fields', () {
      final map = {
        'createdBy': 'user1',
        'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
      };
      final g = GroupModel.fromMap('g2', map);
      expect(g.name, '');
      expect(g.groupType, 'ikimina');
      expect(g.contributionFrequency, 'Monthly');
      expect(g.duration, '3 months');
      expect(g.members, isEmpty);
    });

    test('toMap includes all required keys', () {
      final g = GroupModel(
        id: 'g1',
        name: 'Group A',
        description: 'desc',
        createdBy: 'user1',
        contributionAmount: 5000,
        contributionFrequency: 'Monthly',
        createdAt: createdAt,
      );
      final map = g.toMap();
      expect(map['name'], 'Group A');
      expect(map['contributionAmount'], 5000.0);
      expect(map['createdBy'], 'user1');
      expect(map, contains('createdAt'));
      expect(map, contains('milestones'));
    });
  });

  // ──────────────────────────────────────────
  // ContributionModel
  // ──────────────────────────────────────────
  group('ContributionModel', () {
    final date = DateTime(2024, 3, 10);

    test('fromMap parses all fields correctly', () {
      final map = {
        'groupId': 'g1',
        'userId': 'u1',
        'userName': 'Alice',
        'amount': 3000,
        'date': Timestamp.fromDate(date),
        'note': 'March contribution',
      };
      final c = ContributionModel.fromMap('c1', map);
      expect(c.id, 'c1');
      expect(c.groupId, 'g1');
      expect(c.userId, 'u1');
      expect(c.userName, 'Alice');
      expect(c.amount, 3000.0);
      expect(c.note, 'March contribution');
      expect(c.date, date);
    });

    test('fromMap handles null note', () {
      final map = {
        'groupId': 'g1',
        'userId': 'u1',
        'userName': 'Bob',
        'amount': 1000,
        'date': Timestamp.fromDate(date),
        'note': null,
      };
      final c = ContributionModel.fromMap('c2', map);
      expect(c.note, isNull);
    });

    test('toMap returns correct map', () {
      final c = ContributionModel(
        id: 'c1',
        groupId: 'g1',
        userId: 'u1',
        userName: 'Alice',
        amount: 3000,
        date: date,
        note: 'Test',
      );
      final map = c.toMap();
      expect(map['groupId'], 'g1');
      expect(map['userName'], 'Alice');
      expect(map['amount'], 3000.0);
      expect(map['note'], 'Test');
      expect(map, contains('date'));
    });

    test('toMap stores null note', () {
      final c = ContributionModel(
        id: 'c1',
        groupId: 'g1',
        userId: 'u1',
        userName: 'Bob',
        amount: 1000,
        date: date,
      );
      expect(c.toMap()['note'], isNull);
    });

    test('toMap round-trips amount as double', () {
      final c = ContributionModel(
        id: 'c1',
        groupId: 'g1',
        userId: 'u1',
        userName: 'Carol',
        amount: 7500,
        date: date,
      );
      expect(c.toMap()['amount'], 7500.0);
    });
  });
}
