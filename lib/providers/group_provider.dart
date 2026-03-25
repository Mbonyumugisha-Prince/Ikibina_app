import 'dart:async';

import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../models/contribution_model.dart';
import '../services/firestore_service.dart';

class GroupProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  StreamSubscription<List<GroupModel>>? _subscription;

  List<GroupModel> _groups = [];
  GroupModel? _currentGroup;
  bool _loading = false;
  String? _error;
  bool _hasAttemptedLoad = false;
  String? _loadedUserId;

  List<GroupModel> get groups => _groups;
  GroupModel? get currentGroup => _currentGroup;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasAttemptedLoad => _hasAttemptedLoad;
  String? get loadedUserId => _loadedUserId;

  /// Clears all state and cancels the active stream. Call this on logout.
  void reset() {
    _subscription?.cancel();
    _subscription = null;
    _groups = [];
    _currentGroup = null;
    _loading = false;
    _error = null;
    _hasAttemptedLoad = false;
    _loadedUserId = null;
    notifyListeners();
  }

  void loadUserGroups(String userId) {
    // Cancel the previous subscription so the old user's data stops arriving.
    _subscription?.cancel();
    _subscription = null;

    _setLoading(true);
    _error = null;
    _hasAttemptedLoad = false;
    _loadedUserId = userId;

    _subscription = _service.getUserGroups(userId).listen(
      (groups) {
        _groups = groups;
        if (groups.isEmpty) {
          _currentGroup = null;
        } else if (_currentGroup == null) {
          _currentGroup = groups.first;
        } else {
          _currentGroup = groups.firstWhere(
            (g) => g.id == _currentGroup!.id,
            orElse: () => groups.first,
          );
        }
        _hasAttemptedLoad = true;
        _setLoading(false);
        _error = null;
      },
      onError: (e) {
        _error = 'Failed to load groups: ${e.toString()}';
        _hasAttemptedLoad = true;
        _setLoading(false);
      },
    );

    // Timeout after 10 seconds if no data received
    Future.delayed(const Duration(seconds: 10), () {
      if (!_hasAttemptedLoad && _loading) {
        _error = 'Failed to connect. Check your internet connection.';
        _setLoading(false);
        _hasAttemptedLoad = true;
      }
    });
  }

  Future<bool> createGroup(GroupModel group, String userId) async {
    _setLoading(true);
    try {
      _currentGroup = await _service.createGroup(group, userId);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<GroupModel?> joinGroup(String inviteCode, String userId) async {
    _setLoading(true);
    try {
      final group = await _service.joinGroup(inviteCode, userId);
      if (group != null) _currentGroup = group;
      _error = group == null ? 'Group not found. Check the invite code.' : null;
      return group;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addContribution(ContributionModel contribution) async {
    _setLoading(true);
    try {
      await _service.addContribution(contribution);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
