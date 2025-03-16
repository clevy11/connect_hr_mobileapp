import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../core/database/database_helper.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DatabaseHelper _databaseHelper;
  
  AuthRepository({required DatabaseHelper databaseHelper}) : _databaseHelper = databaseHelper;
  
  // Login user
  Future<User?> login(String username, String password) async {
    final user = await _databaseHelper.getUserByUsername(username);
    
    if (user != null) {
      // In a real app, you would hash the password and compare with the stored hash
      // For simplicity, we're comparing plain text passwords here
      if (user['password'] == password) {
        // Update last login
        final updatedUser = {
          ...user,
          'last_login': DateTime.now().toIso8601String()
        };
        
        await _databaseHelper.updateUser(updatedUser);
        
        // Save user session
        await _saveUserSession(User.fromMap(updatedUser));
        
        return User.fromMap(updatedUser);
      }
    }
    
    return null;
  }
  
  // Register new user
  Future<bool> register(User user) async {
    try {
      // Check if username already exists
      final existingUser = await _databaseHelper.getUserByUsername(user.username);
      if (existingUser != null) {
        return false; // Username already taken
      }
      
      // In a real app, you would hash the password before storing
      final userId = await _databaseHelper.insertUser(user.toMap());
      
      if (userId > 0) {
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }
  
  // Get user by ID
  Future<User?> getUserById(int id) async {
    try {
      final user = await _databaseHelper.getUserById(id);
      if (user != null) {
        return User.fromMap(user);
      }
      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }
  
  // Update user
  Future<bool> updateUser(User user) async {
    try {
      if (user.id == null) {
        return false;
      }
      
      final result = await _databaseHelper.updateUser(user.toMap());
      return result > 0;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }
  
  // Logout user
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('username');
      await prefs.remove('role');
      return true;
    } catch (e) {
      print('Error logging out: $e');
      return false;
    }
  }
  
  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      
      if (userId != null) {
        final user = await _databaseHelper.getUserById(userId);
        if (user != null) {
          return User.fromMap(user);
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
  
  // Save user session
  Future<void> _saveUserSession(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', user.id!);
      await prefs.setString('username', user.username);
      await prefs.setString('role', user.role);
      if (user.employeeId != null) {
        await prefs.setInt('employee_id', user.employeeId!);
      }
    } catch (e) {
      print('Error saving user session: $e');
    }
  }
  
  // Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
