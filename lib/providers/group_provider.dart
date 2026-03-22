import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../models/contribution_model.dart';
import '../services/firestore_service.dart';

class GroupProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<GroupModel> _groups = [];
  bool _loading = false;
  String? _error;

  List<GroupModel> get groups => _groups;
  bool get loading => _loading;
  String? get error => _error;

  void loadUserGroups(String userId) {
    _service.getUserGroups(userId).listen((groups) {
      _groups = groups;
      notifyListeners();
    });
  }

  Future<bool> createGroup(GroupModel group, String userId) async {
    _setLoading(true);
    try {
      await _service.createGroup(group, userId);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
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
