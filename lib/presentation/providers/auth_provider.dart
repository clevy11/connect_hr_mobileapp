import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isAuthenticated = false;
  User? _currentUser;
  bool _isLoading = false;

  AuthProvider({required AuthRepository authRepository}) 
      : _authRepository = authRepository {
    _checkAuthentication();
  }

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAdmin => _currentUser?.role == AppConstants.roleAdmin;
  bool get isHrManager => _currentUser?.role == AppConstants.roleHrManager;
  bool get isManager => _currentUser?.role == AppConstants.roleManager;
  bool get isEmployee => _currentUser?.role == AppConstants.roleEmployee;
  bool get canUseAttendance => _isAuthenticated;

  // Check if user is already authenticated
  Future<void> _checkAuthentication() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      
      if (userId != null) {
        final user = await _authRepository.getUserById(userId);
        if (user != null) {
          _currentUser = user;
          _isAuthenticated = true;
        } else {
          await _logout(notify: false);
        }
      }
    } catch (e) {
      debugPrint('Error checking authentication: $e');
      await _logout(notify: false);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login user
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authRepository.login(username, password);
      
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        
        // Save user session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', user.id!);
        await prefs.setString('username', user.username);
        await prefs.setString('role', user.role);
        
        if (user.employeeId != null) {
          await prefs.setInt('employee_id', user.employeeId!);
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register new user
  Future<bool> register(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authRepository.register(user);
      return success;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authRepository.updateUser(user);
      
      if (success && user.id == _currentUser?.id) {
        _currentUser = user;
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      debugPrint('Update profile error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout user
  Future<void> logout() async {
    await _logout();
  }

  Future<void> _logout({bool notify = true}) async {
    _isLoading = true;
    if (notify) notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('username');
      await prefs.remove('role');
      await prefs.remove('employee_id');
      
      _currentUser = null;
      _isAuthenticated = false;
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _isLoading = false;
      if (notify) notifyListeners();
    }
  }

  // Check if user has permission for a specific action
  bool hasPermission(List<String> allowedRoles) {
    if (_currentUser == null) return false;
    return allowedRoles.contains(_currentUser!.role);
  }
}
