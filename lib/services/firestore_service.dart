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
    final doc = await _db
        .collection(AppConstants.groupsCollection)
        .add({...group.toMap(), 'members': [userId]});
    return GroupModel.fromMap(doc.id, group.toMap());
  }

  Future<GroupModel?> getGroup(String groupId) async {
    final doc = await _db
        .collection(AppConstants.groupsCollection)
        .doc(groupId)
        .get();
    if (!doc.exists) return null;
    return GroupModel.fromMap(doc.id, doc.data()!);
  }

  // Contributions
  Stream<List<ContributionModel>> getGroupContributions(String groupId) {
    return _db
        .collection(AppConstants.contributionsCollection)
        .where('groupId', isEqualTo: groupId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ContributionModel.fromMap(d.id, d.data()))
            .toList());
  }

  Future<void> addContribution(ContributionModel contribution) async {
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
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TransactionModel.fromMap(d.id, d.data()))
            .toList());
  }
}
