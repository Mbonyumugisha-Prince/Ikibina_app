import 'package:cloud_firestore/cloud_firestore.dart';

/// The four escalation tiers for an Ikimina group.
/// Stored as a nested map inside the group document under `penaltyRules`.
class GroupPenaltyRules {
  // Level 1 – Gentle Reminder
  final bool gentleReminderEnabled;
  final int gentleReminderHoursAfterDeadline; // default: 24

  // Level 2 – Late Fee
  final bool lateFeeEnabled;
  final int lateFeeDaysLate; // default: 3
  final double lateFeePercent; // default: 5.0

  // Level 3 – Account Freeze
  final bool accountFreezeEnabled;
  final int accountFreezeCyclesMissed; // default: 1

  // Level 4 – Expulsion
  final bool expulsionEnabled;
  final int expulsionCyclesMissed; // default: 3

  const GroupPenaltyRules({
    this.gentleReminderEnabled = true,
    this.gentleReminderHoursAfterDeadline = 24,
    this.lateFeeEnabled = true,
    this.lateFeeDaysLate = 3,
    this.lateFeePercent = 5.0,
    this.accountFreezeEnabled = false,
    this.accountFreezeCyclesMissed = 1,
    this.expulsionEnabled = false,
    this.expulsionCyclesMissed = 3,
  });

  factory GroupPenaltyRules.defaults() => const GroupPenaltyRules();

  factory GroupPenaltyRules.fromMap(Map<String, dynamic> map) {
    final gr = (map['gentleReminder'] as Map<String, dynamic>?) ?? {};
    final lf = (map['lateFee'] as Map<String, dynamic>?) ?? {};
    final af = (map['accountFreeze'] as Map<String, dynamic>?) ?? {};
    final ex = (map['expulsion'] as Map<String, dynamic>?) ?? {};
    return GroupPenaltyRules(
      gentleReminderEnabled: gr['enabled'] as bool? ?? true,
      gentleReminderHoursAfterDeadline:
          gr['hoursAfterDeadline'] as int? ?? 24,
      lateFeeEnabled: lf['enabled'] as bool? ?? true,
      lateFeeDaysLate: lf['daysLate'] as int? ?? 3,
      lateFeePercent: (lf['feePercent'] as num? ?? 5.0).toDouble(),
      accountFreezeEnabled: af['enabled'] as bool? ?? false,
      accountFreezeCyclesMissed: af['cyclesMissed'] as int? ?? 1,
      expulsionEnabled: ex['enabled'] as bool? ?? false,
      expulsionCyclesMissed: ex['cyclesMissed'] as int? ?? 3,
    );
  }

  Map<String, dynamic> toMap() => {
        'gentleReminder': {
          'enabled': gentleReminderEnabled,
          'hoursAfterDeadline': gentleReminderHoursAfterDeadline,
        },
        'lateFee': {
          'enabled': lateFeeEnabled,
          'daysLate': lateFeeDaysLate,
          'feePercent': lateFeePercent,
        },
        'accountFreeze': {
          'enabled': accountFreezeEnabled,
          'cyclesMissed': accountFreezeCyclesMissed,
        },
        'expulsion': {
          'enabled': expulsionEnabled,
          'cyclesMissed': expulsionCyclesMissed,
        },
      };

  GroupPenaltyRules copyWith({
    bool? gentleReminderEnabled,
    int? gentleReminderHoursAfterDeadline,
    bool? lateFeeEnabled,
    int? lateFeeDaysLate,
    double? lateFeePercent,
    bool? accountFreezeEnabled,
    int? accountFreezeCyclesMissed,
    bool? expulsionEnabled,
    int? expulsionCyclesMissed,
  }) =>
      GroupPenaltyRules(
        gentleReminderEnabled:
            gentleReminderEnabled ?? this.gentleReminderEnabled,
        gentleReminderHoursAfterDeadline: gentleReminderHoursAfterDeadline ??
            this.gentleReminderHoursAfterDeadline,
        lateFeeEnabled: lateFeeEnabled ?? this.lateFeeEnabled,
        lateFeeDaysLate: lateFeeDaysLate ?? this.lateFeeDaysLate,
        lateFeePercent: lateFeePercent ?? this.lateFeePercent,
        accountFreezeEnabled: accountFreezeEnabled ?? this.accountFreezeEnabled,
        accountFreezeCyclesMissed:
            accountFreezeCyclesMissed ?? this.accountFreezeCyclesMissed,
        expulsionEnabled: expulsionEnabled ?? this.expulsionEnabled,
        expulsionCyclesMissed:
            expulsionCyclesMissed ?? this.expulsionCyclesMissed,
      );
}

/// A record of a penalty event applied to a member in a group.
/// Stored in the `penaltyRecords` Firestore collection.
class PenaltyRecordModel {
  final String id;
  final String groupId;
  final String groupName;
  final String userId;
  final String userName;

  /// 'gentle_reminder' | 'late_fee' | 'account_freeze' | 'expulsion'
  final String type;
  final String description;

  /// Non-zero only for `late_fee` type.
  final double amount;
  final DateTime appliedAt;
  final bool resolved;

  const PenaltyRecordModel({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.userId,
    required this.userName,
    required this.type,
    required this.description,
    required this.amount,
    required this.appliedAt,
    this.resolved = false,
  });

  factory PenaltyRecordModel.fromMap(String id, Map<String, dynamic> map) =>
      PenaltyRecordModel(
        id: id,
        groupId: map['groupId'] as String? ?? '',
        groupName: map['groupName'] as String? ?? '',
        userId: map['userId'] as String? ?? '',
        userName: map['userName'] as String? ?? '',
        type: map['type'] as String? ?? '',
        description: map['description'] as String? ?? '',
        amount: (map['amount'] as num? ?? 0).toDouble(),
        appliedAt: map['appliedAt'] is Timestamp
            ? (map['appliedAt'] as Timestamp).toDate()
            : DateTime.now(),
        resolved: map['resolved'] as bool? ?? false,
      );

  Map<String, dynamic> toMap() => {
        'groupId': groupId,
        'groupName': groupName,
        'userId': userId,
        'userName': userName,
        'type': type,
        'description': description,
        'amount': amount,
        'appliedAt': Timestamp.fromDate(appliedAt),
        'resolved': resolved,
      };
}
