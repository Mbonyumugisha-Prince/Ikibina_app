import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String groupId;
  final String userId;
  final String userName;
  final String type; // contribution, loan, withdrawal, fine
  final double amount;
  final DateTime date;
  final String? description;

  TransactionModel({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.userName,
    required this.type,
    required this.amount,
    required this.date,
    this.description,
  });

  factory TransactionModel.fromMap(String id, Map<String, dynamic> map) {
    return TransactionModel(
      id: id,
      groupId: map['groupId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      type: map['type'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'userId': userId,
      'userName': userName,
      'type': type,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'description': description,
    };
  }
}
