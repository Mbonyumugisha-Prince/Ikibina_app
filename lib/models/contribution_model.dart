import 'package:cloud_firestore/cloud_firestore.dart';

class ContributionModel {
  final String id;
  final String groupId;
  final String userId;
  final String userName;
  final double amount;
  final DateTime date;
  final String? note;

  ContributionModel({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.date,
    this.note,
  });

  factory ContributionModel.fromMap(String id, Map<String, dynamic> map) {
    return ContributionModel(
      id: id,
      groupId: map['groupId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'userId': userId,
      'userName': userName,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'note': note,
    };
  }
}
