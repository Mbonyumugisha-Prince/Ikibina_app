import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_model.dart';
import '../models/contribution_model.dart';
import '../models/loan_model.dart';
import '../models/transaction_model.dart';
import '../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Groups
  Stream<List<GroupModel>> getUserGroups(String userId) {
    return _db
        .collection(AppConstants.groupsCollection)
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => GroupModel.fromMap(d.id, d.data())).toList());
  }

  Future<GroupModel> createGroup(GroupModel group, String userId) async {
    final batch = _db.batch();
    final groupRef = _db.collection(AppConstants.groupsCollection).doc();
    final groupData = {
      ...group.toMap(),
      'adminId': userId,
      'members': [userId],
      'inviteCode': group.inviteCode,
    };
    batch.set(groupRef, groupData);
    // Update user's activeGroupId and activeGroupRole
    final userRef =
        _db.collection(AppConstants.usersCollection).doc(userId);
    batch.update(userRef, {
      'activeGroupId': groupRef.id,
      'activeGroupRole': 'admin',
    });
    await batch.commit();
    return GroupModel.fromMap(groupRef.id, groupData);
  }

  Future<GroupModel?> getGroup(String groupId) async {
    final doc = await _db
        .collection(AppConstants.groupsCollection)
        .doc(groupId)
        .get();
    if (!doc.exists) return null;
    return GroupModel.fromMap(doc.id, doc.data()!);
  }

  Future<GroupModel?> getGroupByInviteCode(String code) async {
    final snap = await _db
        .collection(AppConstants.groupsCollection)
        .where('inviteCode', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return GroupModel.fromMap(snap.docs.first.id, snap.docs.first.data());
  }

  Future<GroupModel?> joinGroup(String inviteCode, String userId) async {
    final group = await getGroupByInviteCode(inviteCode);
    if (group == null) return null;
    final batch = _db.batch();
    final groupRef =
        _db.collection(AppConstants.groupsCollection).doc(group.id);
    batch.update(groupRef, {
      'members': FieldValue.arrayUnion([userId]),
      'memberCount': FieldValue.increment(1),
    });
    final userRef =
        _db.collection(AppConstants.usersCollection).doc(userId);
    batch.update(userRef, {
      'activeGroupId': group.id,
      'activeGroupRole': 'member',
    });
    await batch.commit();
    return group;
  }

  Future<GroupModel?> getUserFirstGroup(String userId) async {
    final snap = await _db
        .collection(AppConstants.groupsCollection)
        .where('members', arrayContains: userId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return GroupModel.fromMap(snap.docs.first.id, snap.docs.first.data());
  }

  Future<void> removeMember(String groupId, String memberId) async {
    final batch = _db.batch();
    final groupRef = _db.collection(AppConstants.groupsCollection).doc(groupId);
    batch.update(groupRef, {
      'members': FieldValue.arrayRemove([memberId]),
      'suspendedMembers': FieldValue.arrayRemove([memberId]),
      'memberCount': FieldValue.increment(-1),
    });
    final userRef = _db.collection(AppConstants.usersCollection).doc(memberId);
    batch.update(userRef, {
      'activeGroupId': FieldValue.delete(),
      'activeGroupRole': FieldValue.delete(),
    });
    await batch.commit();
  }

  Future<void> updateGroup(GroupModel group) async {
    await _db
        .collection(AppConstants.groupsCollection)
        .doc(group.id)
        .update(group.toMap());
  }

  Future<void> deleteGroup(String groupId) async {
    final groupDoc = await _db
        .collection(AppConstants.groupsCollection)
        .doc(groupId)
        .get();
    if (!groupDoc.exists) return;

    final members =
        List<String>.from(groupDoc.data()?['members'] ?? []);
    final batch = _db.batch();

    // Clear activeGroupId / role for every member
    for (final memberId in members) {
      batch.update(
        _db.collection(AppConstants.usersCollection).doc(memberId),
        {
          'activeGroupId': FieldValue.delete(),
          'activeGroupRole': FieldValue.delete(),
        },
      );
    }

    batch.delete(
        _db.collection(AppConstants.groupsCollection).doc(groupId));
    await batch.commit();
  }

  Future<void> suspendMember(String groupId, String memberId) async {
    await _db.collection(AppConstants.groupsCollection).doc(groupId).update({
      'suspendedMembers': FieldValue.arrayUnion([memberId]),
    });
  }

  Future<void> unsuspendMember(String groupId, String memberId) async {
    await _db.collection(AppConstants.groupsCollection).doc(groupId).update({
      'suspendedMembers': FieldValue.arrayRemove([memberId]),
    });
  }

  // Contributions
  Stream<List<ContributionModel>> getGroupContributions(String groupId) {
    return _db
        .collection(AppConstants.contributionsCollection)
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => ContributionModel.fromMap(d.id, d.data()))
              .toList();
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        });
  }

  Future<void> addContribution(ContributionModel contribution) async {
    // Fetch the group to run checks before writing
    final groupDoc = await _db
        .collection(AppConstants.groupsCollection)
        .doc(contribution.groupId)
        .get();
    if (!groupDoc.exists) throw Exception('Group not found.');

    final groupData = groupDoc.data()!;

    // Block suspended members
    final suspended = List<String>.from(groupData['suspendedMembers'] ?? []);
    if (suspended.contains(contribution.userId)) {
      throw Exception(
          'Your account is suspended. You cannot make contributions.');
    }

    // For ikimina groups: enforce one contribution per cycle
    final groupType = groupData['groupType'] as String? ?? 'ikimina';
    if (groupType == 'ikimina') {
      final freq =
          (groupData['contributionFrequency'] as String? ?? 'Monthly')
              .toLowerCase();
      final int cycleDays;
      if (freq.contains('bi') && freq.contains('week')) {
        cycleDays = 14;
      } else if (freq.contains('week')) {
        cycleDays = 7;
      } else {
        cycleDays = 30;
      }

      final cutoff = DateTime.now().subtract(Duration(days: cycleDays));

      // Query only by groupId (single-field index, no composite index needed),
      // then filter userId and date client-side.
      final recentSnap = await _db
          .collection(AppConstants.contributionsCollection)
          .where('groupId', isEqualTo: contribution.groupId)
          .get();

      final alreadyPaid = recentSnap.docs.any((doc) {
        final data = doc.data();
        if (data['userId'] != contribution.userId) return false;
        final date = (data['date'] as Timestamp).toDate();
        return date.isAfter(cutoff);
      });

      if (alreadyPaid) {
        final period = cycleDays == 7 ? 'week' : cycleDays == 14 ? 'two weeks' : 'month';
        throw Exception(
            'You have already contributed this $period. You will be able to contribute again next $period.');
      }
    }

    final batch = _db.batch();
    final contribRef =
        _db.collection(AppConstants.contributionsCollection).doc();
    batch.set(contribRef, contribution.toMap());

    final groupRef = _db
        .collection(AppConstants.groupsCollection)
        .doc(contribution.groupId);
    batch.update(groupRef, {
      'totalSavings': FieldValue.increment(contribution.amount),
    });
    await batch.commit();
  }

  // ── Loans ──────────────────────────────────────────────────────

  /// Returns the remaining loanable pool (50% of savings minus approved +
  /// pending loans, so a pending request already reserves its amount).
  Future<double> getAvailableLoanLimit(String groupId) async {
    final group = await getGroup(groupId);
    if (group == null) return 0;
    final pool = group.totalSavings * 0.5;

    // Query all loans for the group, filter active/pending client-side
    // to avoid needing a composite Firestore index.
    final snap = await _db
        .collection(AppConstants.loansCollection)
        .where('groupId', isEqualTo: groupId)
        .get();

    final used = snap.docs.fold<double>(0, (acc, d) {
      final status = d.data()['status'] as String? ?? '';
      if (status != 'approved' && status != 'pending') return acc;
      return acc + (d.data()['amount'] as num).toDouble();
    });

    return (pool - used).clamp(0.0, double.infinity);
  }

  /// Cancels a pending loan request by deleting it from Firestore.
  Future<void> cancelLoan(String loanId) async {
    await _db.collection(AppConstants.loansCollection).doc(loanId).delete();
  }

  Stream<List<LoanModel>> getGroupLoans(String groupId) {
    return _db
        .collection(AppConstants.loansCollection)
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => LoanModel.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
      return list;
    });
  }

  Future<void> requestLoan(LoanModel loan) async {
    await _db
        .collection(AppConstants.loansCollection)
        .doc(loan.id)
        .set(loan.toMap());
  }

  /// Vote approve/reject on a loan. Automatically activates or rejects
  /// when a simple majority of the other members has voted.
  Future<void> voteOnLoan({
    required String loanId,
    required String voterId,
    required bool approve,
    required int totalMemberCount,
  }) async {
    final ref = _db.collection(AppConstants.loansCollection).doc(loanId);
    final doc = await ref.get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final approvedBy = List<String>.from(data['approvedBy'] ?? []);
    final rejectedBy = List<String>.from(data['rejectedBy'] ?? []);

    if (approve) {
      if (!approvedBy.contains(voterId)) approvedBy.add(voterId);
      rejectedBy.remove(voterId);
    } else {
      if (!rejectedBy.contains(voterId)) rejectedBy.add(voterId);
      approvedBy.remove(voterId);
    }

    // Voting members = everyone except the requester
    final votingMembers = (totalMemberCount - 1).clamp(1, totalMemberCount);
    String? newStatus;
    if (approvedBy.length > votingMembers / 2) {
      newStatus = 'approved';
    } else if (rejectedBy.length >= (votingMembers / 2).ceil()) {
      newStatus = 'rejected';
    }

    await ref.update({
      'approvedBy': approvedBy,
      'rejectedBy': rejectedBy,
      if (newStatus != null) 'status': newStatus,
    });
  }

  /// Record a loan repayment. Marks loan completed when fully paid.
  Future<void> payLoan({
    required String loanId,
    required double paymentAmount,
  }) async {
    final ref = _db.collection(AppConstants.loansCollection).doc(loanId);
    final doc = await ref.get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final principal = (data['amount'] as num).toDouble();
    final dueDate = (data['dueDate'] as Timestamp).toDate();
    final isOverdue = DateTime.now().isAfter(dueDate);
    final rate = isOverdue ? LoanModel.overdueRate : LoanModel.normalRate;
    final total = principal + (principal * rate) + LoanModel.processingFee;

    final newAmountPaid =
        ((data['amountPaid'] as num? ?? 0).toDouble() + paymentAmount)
            .clamp(0.0, total);
    final isComplete = newAmountPaid >= total;

    await ref.update({
      'amountPaid': newAmountPaid,
      if (isComplete) 'status': 'completed',
    });
  }

  // Transactions
  Stream<List<TransactionModel>> getGroupTransactions(String groupId) {
    return _db
        .collection(AppConstants.transactionsCollection)
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => TransactionModel.fromMap(d.id, d.data()))
              .toList();
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        });
  }
}
