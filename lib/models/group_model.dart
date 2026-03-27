import 'package:cloud_firestore/cloud_firestore.dart';
import 'penalty_model.dart';

class MilestoneModel {
  final String name;
  final double targetAmount;

  MilestoneModel({required this.name, required this.targetAmount});

  factory MilestoneModel.fromMap(Map<String, dynamic> map) {
    return MilestoneModel(
      name: map['name'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'targetAmount': targetAmount,
      };
}

class GroupModel {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final String adminId;
  final String inviteCode;

  /// 'ikimina' (loan/savings rotation) or 'goal' (save towards a target)
  final String groupType;

  /// Fixed contribution per cycle – used for 'ikimina' groups
  final double contributionAmount;

  /// 'Weekly' | 'Bi-weekly' | 'Monthly' – used for 'ikimina' groups
  final String contributionFrequency;

  /// '3 months' | '6 months' | '1 year' – used for 'ikimina' groups
  final String duration;

  /// Ordered milestones – used for 'goal' groups (3-5 items)
  final List<MilestoneModel> milestones;

  final double totalSavings;
  final int memberCount;
  final List<String> members;
  final List<String> suspendedMembers;
  final String? imageUrl;
  final DateTime createdAt;

  /// Penalty escalation rules – only used for 'ikimina' groups.
  final GroupPenaltyRules? penaltyRules;

  /// Computed total goal for 'goal' groups
  double get goalAmount =>
      milestones.fold(0.0, (acc, m) => acc + m.targetAmount);

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    String? adminId,
    this.inviteCode = '',
    this.groupType = 'ikimina',
    required this.contributionAmount,
    required this.contributionFrequency,
    this.duration = '3 months',
    this.milestones = const [],
    this.totalSavings = 0,
    this.memberCount = 0,
    this.members = const [],
    this.suspendedMembers = const [],
    this.imageUrl,
    required this.createdAt,
    this.penaltyRules,
  }) : adminId = adminId ?? createdBy;

  factory GroupModel.fromMap(String id, Map<String, dynamic> map) {
    final rawMilestones = map['milestones'];
    List<MilestoneModel> milestones = [];
    if (rawMilestones is List) {
      milestones = rawMilestones
          .whereType<Map<String, dynamic>>()
          .map(MilestoneModel.fromMap)
          .toList();
    }

    return GroupModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      createdBy: map['createdBy'] ?? '',
      adminId: map['adminId'] ?? map['createdBy'] ?? '',
      inviteCode: map['inviteCode'] ?? '',
      groupType: map['groupType'] ?? 'ikimina',
      contributionAmount: (map['contributionAmount'] ?? 0).toDouble(),
      contributionFrequency: map['contributionFrequency'] ?? 'Monthly',
      duration: map['duration'] ?? '3 months',
      milestones: milestones,
      totalSavings: (map['totalSavings'] ?? 0).toDouble(),
      members: List<String>.from(map['members'] ?? []),
      suspendedMembers: List<String>.from(map['suspendedMembers'] ?? []),
      memberCount: map['memberCount'] ?? 0,
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      penaltyRules: map['penaltyRules'] is Map<String, dynamic>
          ? GroupPenaltyRules.fromMap(
              map['penaltyRules'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'adminId': adminId,
      'inviteCode': inviteCode,
      'groupType': groupType,
      'contributionAmount': contributionAmount,
      'contributionFrequency': contributionFrequency,
      'duration': duration,
      'milestones': milestones.map((m) => m.toMap()).toList(),
      'totalSavings': totalSavings,
      'memberCount': memberCount,
      'members': members,
      'suspendedMembers': suspendedMembers,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      if (penaltyRules != null) 'penaltyRules': penaltyRules!.toMap(),
    };
  }
}
