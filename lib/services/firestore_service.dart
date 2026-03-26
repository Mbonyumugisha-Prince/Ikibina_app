import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_model.dart';
import '../models/contribution_model.dart';
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

      final cutoff =
          Timestamp.fromDate(DateTime.now().subtract(Duration(days: cycleDays)));

      final recentSnap = await _db
          .collection(AppConstants.contributionsCollection)
          .where('groupId', isEqualTo: contribution.groupId)
          .where('userId', isEqualTo: contribution.userId)
          .where('date', isGreaterThan: cutoff)
          .limit(1)
          .get();

      if (recentSnap.docs.isNotEmpty) {
        throw Exception(
            'You have already contributed this cycle. Please wait until the next cycle.');
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
