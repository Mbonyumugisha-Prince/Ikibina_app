import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../models/contribution_model.dart';
import '../services/firestore_service.dart';

class GroupProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<GroupModel> _groups = [];
  GroupModel? _currentGroup;
  bool _loading = false;
  String? _error;
  bool _hasAttemptedLoad = false;

  List<GroupModel> get groups => _groups;
  GroupModel? get currentGroup => _currentGroup;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasAttemptedLoad => _hasAttemptedLoad;

  void loadUserGroups(String userId) {
    _setLoading(true);
    _error = null;
    _hasAttemptedLoad = false;
    
    _service.getUserGroups(userId).listen(
      (groups) {
        _groups = groups;
        if (groups.isEmpty) {
          _currentGroup = null;
        } else if (_currentGroup == null) {
          _currentGroup = groups.first;
        } else {
          // Always sync currentGroup with latest Firestore data
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
        _error = 'Failed to connect to groups. Check your internet connection.';
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

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
