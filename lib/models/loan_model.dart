import 'package:cloud_firestore/cloud_firestore.dart';

class LoanModel {
  final String id;
  final String groupId;
  final String userId;
  final String userName;
  final double amount;       // principal
  final int durationWeeks;   // 1–4
  final DateTime requestedAt;
  final DateTime dueDate;    // requestedAt + durationWeeks * 7 days
  final String status;       // pending | approved | completed | rejected
  final List<String> approvedBy;
  final List<String> rejectedBy;
  final double amountPaid;

  static const double processingFee = 1000;
  static const double normalRate    = 0.07;
  static const double overdueRate   = 0.15;

  LoanModel({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.durationWeeks,
    required this.requestedAt,
    required this.dueDate,
    this.status = 'pending',
    this.approvedBy = const [],
    this.rejectedBy = const [],
    this.amountPaid = 0,
  });

  // ── Computed ────────────────────────────────────────────────────
  bool get isOverdue => DateTime.now().isAfter(dueDate) && status == 'approved';
  double get interestRate => isOverdue ? overdueRate : normalRate;
  double get interest => amount * interestRate;
  double get totalToRepay => amount + interest + processingFee;
  double get remaining => (totalToRepay - amountPaid).clamp(0.0, double.infinity);
  double get progress => amountPaid == 0 ? 0 : (amountPaid / totalToRepay).clamp(0.0, 1.0);

  // ── Serialization ───────────────────────────────────────────────
  factory LoanModel.fromMap(String id, Map<String, dynamic> map) => LoanModel(
        id: id,
        groupId: map['groupId'] ?? '',
        userId: map['userId'] ?? '',
        userName: map['userName'] ?? '',
        amount: (map['amount'] ?? 0).toDouble(),
        durationWeeks: (map['durationWeeks'] ?? 1) as int,
        requestedAt: (map['requestedAt'] as Timestamp).toDate(),
        dueDate: (map['dueDate'] as Timestamp).toDate(),
        status: map['status'] ?? 'pending',
        approvedBy: List<String>.from(map['approvedBy'] ?? []),
        rejectedBy: List<String>.from(map['rejectedBy'] ?? []),
        amountPaid: (map['amountPaid'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'groupId': groupId,
        'userId': userId,
        'userName': userName,
        'amount': amount,
        'durationWeeks': durationWeeks,
        'requestedAt': Timestamp.fromDate(requestedAt),
        'dueDate': Timestamp.fromDate(dueDate),
        'status': status,
        'approvedBy': approvedBy,
        'rejectedBy': rejectedBy,
        'amountPaid': amountPaid,
      };
}
