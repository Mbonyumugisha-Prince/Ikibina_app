import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final String adminId;
  final String inviteCode;
  final double contributionAmount;
  final String contributionFrequency;
  final double totalSavings;
  final int memberCount;
  final List<String> members;
  final String? imageUrl;
  final DateTime createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    String? adminId,
    this.inviteCode = '',
    required this.contributionAmount,
    required this.contributionFrequency,
    this.totalSavings = 0,
    this.memberCount = 0,
    this.members = const [],
    this.imageUrl,
    required this.createdAt,
  }) : adminId = adminId ?? createdBy;

  factory GroupModel.fromMap(String id, Map<String, dynamic> map) {
    return GroupModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      createdBy: map['createdBy'] ?? '',
      adminId: map['adminId'] ?? map['createdBy'] ?? '',
      inviteCode: map['inviteCode'] ?? '',
      contributionAmount: (map['contributionAmount'] ?? 0).toDouble(),
      contributionFrequency: map['contributionFrequency'] ?? 'Monthly',
      totalSavings: (map['totalSavings'] ?? 0).toDouble(),
      members: List<String>.from(map['members'] ?? []),
      memberCount: map['memberCount'] ?? 0,
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'adminId': adminId,
      'inviteCode': inviteCode,
      'contributionAmount': contributionAmount,
      'contributionFrequency': contributionFrequency,
      'totalSavings': totalSavings,
      'memberCount': memberCount,
      'members': members,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
