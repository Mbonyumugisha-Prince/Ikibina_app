import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/group_model.dart';
import '../models/penalty_model.dart';

/// Automatically evaluates and applies penalty rules for an Ikimina group.
///
/// Call [runChecks] once per app session per group (e.g. when the admin opens
/// the group). The service is idempotent – a [penaltyChecks] document is
/// written per (group, user, cycle, penaltyType) to prevent double-applying.
class PenaltyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const _resendUrl = 'https://api.resend.com/emails';
  static String get _resendKey => dotenv.env['RESEND_API_KEY'] ?? '';

  // ── Public entry point ──────────────────────────────────────────

  /// Runs all penalty checks for every non-admin member in [group].
  /// Returns a summary list of actions taken.
  Future<List<String>> runChecks(GroupModel group) async {
    if (group.groupType != AppConstants.groupTypeIkimina) return [];
    final rules = group.penaltyRules ?? GroupPenaltyRules.defaults();
    final cycleDays = _cycleDays(group.contributionFrequency);

    // Fetch all contributions once
    final contribSnap = await _db
        .collection(AppConstants.contributionsCollection)
        .where('groupId', isEqualTo: group.id)
        .get();

    final contributionsByUser = <String, List<DateTime>>{};
    for (final doc in contribSnap.docs) {
      final data = doc.data();
      final uid = data['userId'] as String? ?? '';
      final date = (data['date'] as Timestamp).toDate();
      contributionsByUser.putIfAbsent(uid, () => []).add(date);
    }

    // Fetch user emails for notifications
    final userSnap = await _db
        .collection(AppConstants.usersCollection)
        .where(FieldPath.documentId, whereIn: group.members)
        .get();

    final userEmails = <String, String>{};
    final userNames = <String, String>{};
    for (final doc in userSnap.docs) {
      final data = doc.data();
      userEmails[doc.id] = data['email'] as String? ?? '';
      userNames[doc.id] = data['name'] as String? ?? '';
    }

    final log = <String>[];

    for (final memberId in group.members) {
      if (memberId == group.adminId) continue;
      final memberContribs = contributionsByUser[memberId] ?? [];
      final memberName = userNames[memberId] ?? 'Member';
      final memberEmail = userEmails[memberId] ?? '';

      final missedCycles = _countMissedCycles(
        groupCreated: group.createdAt,
        cycleDays: cycleDays,
        contributions: memberContribs,
      );

      final currentCycleStart = _currentCycleStart(
        groupCreated: group.createdAt,
        cycleDays: cycleDays,
      );
      final currentCycleDeadline =
          currentCycleStart.add(Duration(days: cycleDays));
      final now = DateTime.now();
      final hoursLate = now.difference(currentCycleDeadline).inHours;
      final daysLate = now.difference(currentCycleDeadline).inDays;

      final hasContributedThisCycle = memberContribs.any(
        (d) => d.isAfter(currentCycleStart) && d.isBefore(now),
      );

      final cycleKey = _cycleKey(currentCycleStart);

      // ── Level 1: Gentle Reminder ────────────────────────────────
      if (rules.gentleReminderEnabled &&
          !hasContributedThisCycle &&
          hoursLate >= rules.gentleReminderHoursAfterDeadline) {
        final checkKey = '${group.id}_${memberId}_${cycleKey}_gr';
        if (await _notYetApplied(checkKey)) {
          await _sendGentleReminder(
            groupId: group.id,
            groupName: group.name,
            userId: memberId,
            userName: memberName,
            userEmail: memberEmail,
            contributionAmount: group.contributionAmount,
            cycleKey: cycleKey,
          );
          await _markApplied(checkKey);
          log.add('Gentle reminder sent to $memberName');
        }
      }

      // ── Level 2: Late Fee ───────────────────────────────────────
      if (rules.lateFeeEnabled &&
          !hasContributedThisCycle &&
          daysLate >= rules.lateFeeDaysLate) {
        final checkKey = '${group.id}_${memberId}_${cycleKey}_lf';
        if (await _notYetApplied(checkKey)) {
          final feeAmount =
              group.contributionAmount * (rules.lateFeePercent / 100);
          await _applyLateFee(
            groupId: group.id,
            groupName: group.name,
            userId: memberId,
            userName: memberName,
            feeAmount: feeAmount,
            feePercent: rules.lateFeePercent,
          );
          await _markApplied(checkKey);
          log.add(
              'Late fee (RWF ${feeAmount.toStringAsFixed(0)}) applied to $memberName');
        }
      }

      // ── Level 3: Account Freeze ─────────────────────────────────
      if (rules.accountFreezeEnabled &&
          missedCycles >= rules.accountFreezeCyclesMissed) {
        final checkKey =
            '${group.id}_${memberId}_m${missedCycles}_af';
        if (await _notYetApplied(checkKey)) {
          await _applyAccountFreeze(
            groupId: group.id,
            groupName: group.name,
            userId: memberId,
            userName: memberName,
            missedCycles: missedCycles,
          );
          await _markApplied(checkKey);
          log.add('Account freeze applied to $memberName ($missedCycles cycles missed)');
        }
      }

      // ── Level 4: Expulsion ──────────────────────────────────────
      if (rules.expulsionEnabled &&
          missedCycles >= rules.expulsionCyclesMissed) {
        final checkKey =
            '${group.id}_${memberId}_m${missedCycles}_ex';
        if (await _notYetApplied(checkKey)) {
          await _applyExpulsion(
            groupId: group.id,
            groupName: group.name,
            userId: memberId,
            userName: memberName,
            missedCycles: missedCycles,
          );
          await _markApplied(checkKey);
          log.add('$memberName expelled ($missedCycles cycles missed)');
        }
      }
    }

    return log;
  }

  // ── Penalty actions ─────────────────────────────────────────────

  Future<void> _sendGentleReminder({
    required String groupId,
    required String groupName,
    required String userId,
    required String userName,
    required String userEmail,
    required double contributionAmount,
    required String cycleKey,
  }) async {
    final batch = _db.batch();

    // In-app notification
    final notifRef = _db.collection(AppConstants.notificationsCollection).doc();
    batch.set(notifRef, {
      'userId': userId,
      'groupId': groupId,
      'type': AppConstants.penaltyGentleReminder,
      'title': 'Contribution Reminder – $groupName',
      'body':
          'Your contribution of RWF ${contributionAmount.toStringAsFixed(0)} for $groupName is overdue. Please contribute as soon as possible.',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Penalty record
    final record = PenaltyRecordModel(
      id: '',
      groupId: groupId,
      groupName: groupName,
      userId: userId,
      userName: userName,
      type: AppConstants.penaltyGentleReminder,
      description:
          'Contribution reminder sent – cycle $cycleKey',
      amount: 0,
      appliedAt: DateTime.now(),
    );
    final recRef =
        _db.collection(AppConstants.penaltyRecordsCollection).doc();
    batch.set(recRef, record.toMap());

    await batch.commit();

    // Email (best-effort – don't throw on failure)
    if (userEmail.isNotEmpty && _resendKey.isNotEmpty) {
      try {
        await http.post(
          Uri.parse(_resendUrl),
          headers: {
            'Authorization': 'Bearer $_resendKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'from': 'Ikimina <noreply@ikimina.app>',
            'to': [userEmail],
            'subject': 'Contribution Reminder – $groupName',
            'html': _reminderEmailHtml(
                userName, groupName, contributionAmount),
          }),
        );
      } catch (_) {}
    }
  }

  Future<void> _applyLateFee({
    required String groupId,
    required String groupName,
    required String userId,
    required String userName,
    required double feeAmount,
    required double feePercent,
  }) async {
    final batch = _db.batch();

    // Fine transaction
    final txRef = _db.collection(AppConstants.transactionsCollection).doc();
    batch.set(txRef, {
      'groupId': groupId,
      'userId': userId,
      'userName': userName,
      'type': AppConstants.transactionFine,
      'amount': feeAmount,
      'date': FieldValue.serverTimestamp(),
      'description':
          'Late fee: ${feePercent.toStringAsFixed(0)}% of contribution',
    });

    // Penalty record
    final record = PenaltyRecordModel(
      id: '',
      groupId: groupId,
      groupName: groupName,
      userId: userId,
      userName: userName,
      type: AppConstants.penaltyLateFee,
      description:
          'Late fee of ${feePercent.toStringAsFixed(0)}% applied – RWF ${feeAmount.toStringAsFixed(0)}',
      amount: feeAmount,
      appliedAt: DateTime.now(),
    );
    final recRef =
        _db.collection(AppConstants.penaltyRecordsCollection).doc();
    batch.set(recRef, record.toMap());

    // In-app notification
    final notifRef = _db.collection(AppConstants.notificationsCollection).doc();
    batch.set(notifRef, {
      'userId': userId,
      'groupId': groupId,
      'type': AppConstants.penaltyLateFee,
      'title': 'Late Fee Applied – $groupName',
      'body':
          'A late fee of RWF ${feeAmount.toStringAsFixed(0)} (${feePercent.toStringAsFixed(0)}% of your contribution) has been added to your account in $groupName.',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> _applyAccountFreeze({
    required String groupId,
    required String groupName,
    required String userId,
    required String userName,
    required int missedCycles,
  }) async {
    final batch = _db.batch();

    // Suspend member in group
    batch.update(
      _db.collection(AppConstants.groupsCollection).doc(groupId),
      {
        'suspendedMembers': FieldValue.arrayUnion([userId]),
      },
    );

    // Penalty record
    final record = PenaltyRecordModel(
      id: '',
      groupId: groupId,
      groupName: groupName,
      userId: userId,
      userName: userName,
      type: AppConstants.penaltyAccountFreeze,
      description:
          'Account frozen after $missedCycles missed cycle(s) – no loans or payouts until reinstated',
      amount: 0,
      appliedAt: DateTime.now(),
    );
    final recRef =
        _db.collection(AppConstants.penaltyRecordsCollection).doc();
    batch.set(recRef, record.toMap());

    // In-app notification
    final notifRef = _db.collection(AppConstants.notificationsCollection).doc();
    batch.set(notifRef, {
      'userId': userId,
      'groupId': groupId,
      'type': AppConstants.penaltyAccountFreeze,
      'title': 'Account Frozen – $groupName',
      'body':
          'Your account in $groupName has been frozen due to $missedCycles missed contribution cycle(s). Loans and payouts are suspended until you catch up.',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> _applyExpulsion({
    required String groupId,
    required String groupName,
    required String userId,
    required String userName,
    required int missedCycles,
  }) async {
    final batch = _db.batch();

    // Remove from group
    batch.update(
      _db.collection(AppConstants.groupsCollection).doc(groupId),
      {
        'members': FieldValue.arrayRemove([userId]),
        'suspendedMembers': FieldValue.arrayRemove([userId]),
        'memberCount': FieldValue.increment(-1),
      },
    );

    // Clear the user's activeGroupId if this was their active group
    batch.update(
      _db.collection(AppConstants.usersCollection).doc(userId),
      {
        'activeGroupId': FieldValue.delete(),
        'activeGroupRole': FieldValue.delete(),
      },
    );

    // Penalty record (kept for history)
    final record = PenaltyRecordModel(
      id: '',
      groupId: groupId,
      groupName: groupName,
      userId: userId,
      userName: userName,
      type: AppConstants.penaltyExpulsion,
      description:
          'Expelled from group after $missedCycles missed cycles – permanent removal',
      amount: 0,
      appliedAt: DateTime.now(),
    );
    final recRef =
        _db.collection(AppConstants.penaltyRecordsCollection).doc();
    batch.set(recRef, record.toMap());

    // In-app notification
    final notifRef = _db.collection(AppConstants.notificationsCollection).doc();
    batch.set(notifRef, {
      'userId': userId,
      'groupId': groupId,
      'type': AppConstants.penaltyExpulsion,
      'title': 'Removed from Group – $groupName',
      'body':
          'You have been permanently removed from $groupName due to $missedCycles missed contribution cycles.',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // ── Helpers ─────────────────────────────────────────────────────

  int _cycleDays(String frequency) {
    final f = frequency.toLowerCase();
    if (f.contains('bi') && f.contains('week')) return 14;
    if (f.contains('week')) return 7;
    return 30;
  }

  DateTime _currentCycleStart({
    required DateTime groupCreated,
    required int cycleDays,
  }) {
    final elapsed = DateTime.now().difference(groupCreated).inDays;
    final cycleIndex = (elapsed / cycleDays).floor();
    return groupCreated.add(Duration(days: cycleIndex * cycleDays));
  }

  /// Counts how many historical cycles a member has missed entirely.
  int _countMissedCycles({
    required DateTime groupCreated,
    required int cycleDays,
    required List<DateTime> contributions,
  }) {
    final now = DateTime.now();
    final totalCycles =
        ((now.difference(groupCreated).inDays) / cycleDays).floor();
    int missed = 0;
    for (int i = 0; i < totalCycles; i++) {
      final start = groupCreated.add(Duration(days: i * cycleDays));
      final end = start.add(Duration(days: cycleDays));
      final paid = contributions.any((d) => d.isAfter(start) && d.isBefore(end));
      if (!paid) missed++;
    }
    return missed;
  }

  String _cycleKey(DateTime cycleStart) =>
      '${cycleStart.year}-${cycleStart.month.toString().padLeft(2, '0')}-${cycleStart.day.toString().padLeft(2, '0')}';

  Future<bool> _notYetApplied(String checkKey) async {
    final doc = await _db
        .collection(AppConstants.penaltyChecksCollection)
        .doc(checkKey)
        .get();
    return !doc.exists;
  }

  Future<void> _markApplied(String checkKey) async {
    await _db
        .collection(AppConstants.penaltyChecksCollection)
        .doc(checkKey)
        .set({'appliedAt': FieldValue.serverTimestamp()});
  }

  // ── Email templates ─────────────────────────────────────────────

  String _reminderEmailHtml(
      String name, String groupName, double amount) =>
      '''
<!DOCTYPE html>
<html>
<body style="font-family:sans-serif;background:#f5f5f5;padding:24px">
  <div style="background:#fff;border-radius:12px;padding:32px;max-width:480px;margin:0 auto">
    <h2 style="color:#1a1a1a;margin-bottom:8px">Contribution Reminder</h2>
    <p style="color:#555">Hi $name,</p>
    <p style="color:#555">
      Your contribution of <strong>RWF ${amount.toStringAsFixed(0)}</strong>
      for the group <strong>$groupName</strong> is overdue.
    </p>
    <p style="color:#555">Please log in to Ikibina and make your contribution as soon as possible to avoid further penalties.</p>
    <a href="#" style="display:inline-block;background:#1a1a1a;color:#fff;padding:12px 24px;border-radius:8px;text-decoration:none;font-weight:600;margin-top:8px">
      Open Ikibina
    </a>
    <p style="color:#aaa;font-size:12px;margin-top:24px">Ikibina – Community Savings</p>
  </div>
</body>
</html>
''';

  // ── Firestore query helpers (used by UI) ────────────────────────

  Stream<List<PenaltyRecordModel>> getGroupPenaltyRecords(String groupId) {
    return _db
        .collection(AppConstants.penaltyRecordsCollection)
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => PenaltyRecordModel.fromMap(d.id, d.data()))
          .toList()
        ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
      return list;
    });
  }

  Stream<List<PenaltyRecordModel>> getUserPenaltyRecords(String userId) {
    return _db
        .collection(AppConstants.penaltyRecordsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => PenaltyRecordModel.fromMap(d.id, d.data()))
          .toList()
        ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
      return list;
    });
  }

  Future<void> savePenaltyRules(
      String groupId, GroupPenaltyRules rules) async {
    await _db
        .collection(AppConstants.groupsCollection)
        .doc(groupId)
        .update({'penaltyRules': rules.toMap()});
  }
}
