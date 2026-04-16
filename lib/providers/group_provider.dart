import 'package:flutter/material.dart';

import '../models/group_model.dart';
import '../services/group_service.dart';

class GroupProvider extends ChangeNotifier {
  final GroupService _groupService = GroupService();

  List<GroupModel> _groups = [];
  List<GroupModel> _userGroups = [];
  GroupModel? _selectedGroup;
  bool _isLoading = false;
  String _error = '';

  List<GroupModel> get groups => _groups;
  List<GroupModel> get userGroups => _userGroups;
  GroupModel? get selectedGroup => _selectedGroup;
  bool get isLoading => _isLoading;
  String get error => _error;

  Stream<List<GroupModel>> watchAllGroups() {
    return _groupService.getAllGroups();
  }

  Stream<List<GroupModel>> watchUserGroups(String userId) {
    return _groupService.getUserGroups(userId);
  }

  Future<void> refreshAllGroups() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _groups = await _groupService.getAllGroups().first;
    } catch (e) {
      _error = 'Failed to load groups: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUserGroups(String userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _userGroups = await _groupService.getUserGroups(userId).first;
    } catch (e) {
      _error = 'Failed to load user groups: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createGroup({
    required String name,
    required String description,
    required String createdBy,
    required String creatorName,
    required String creatorImage,
    required bool isPublic,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      return await _groupService.createGroup(
        name: name,
        description: description,
        createdBy: createdBy,
        creatorName: creatorName,
        creatorImage: creatorImage,
        isPublic: isPublic,
      );
    } catch (e) {
      _error = 'Failed to create group: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadGroup(String groupId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _selectedGroup = await _groupService.getGroup(groupId);
    } catch (e) {
      _error = 'Failed to load group: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> joinGroup(String groupId, String userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _groupService.joinGroup(groupId, userId);
    } catch (e) {
      _error = 'Failed to join group: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> leaveGroup(String groupId, String userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _groupService.leaveGroup(groupId, userId);
    } catch (e) {
      _error = 'Failed to leave group: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestToJoinGroup(String groupId, String userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _groupService.requestToJoinGroup(groupId, userId);
    } catch (e) {
      _error = 'Failed to request group join: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approveMember(String groupId, String userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _groupService.approveMember(groupId, userId);
    } catch (e) {
      _error = 'Failed to approve member: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectMember(String groupId, String userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _groupService.rejectMember(groupId, userId);
    } catch (e) {
      _error = 'Failed to reject member: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}