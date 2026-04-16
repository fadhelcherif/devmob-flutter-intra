import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String _error = '';

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isAuthenticated => _authService.currentUser != null;

  Future<void> loadCurrentUser() async {
    final current = _authService.currentUser;
    if (current == null) {
      _user = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _user = await _authService.getUserData(current.uid);
    } catch (e) {
      _error = 'Failed to load user: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _user = await _authService.login(email: email, password: password);
      return _user != null;
    } catch (e) {
      _error = 'Login failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    UserRole role = UserRole.employee,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _user = await _authService.register(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      return _user != null;
    } catch (e) {
      _error = 'Registration failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final current = _authService.currentUser;
    if (current == null) {
      _error = 'No authenticated user.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _authService.updateUserProfile(current.uid, data);
      _user = await _authService.getUserData(current.uid);
    } catch (e) {
      _error = 'Profile update failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
    } catch (e) {
      _error = 'Logout failed: $e';
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