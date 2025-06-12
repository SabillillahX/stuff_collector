import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginController extends StateNotifier<void> {
  LoginController() : super(null);
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isDisposed = false;

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    
    try {
      emailController.dispose();
      passwordController.dispose();
    } catch (e) {
      // Ignore disposal errors
    }
    super.dispose();
  }

  void clearFields() {
    if (_isDisposed) return;
    
    try {
      emailController.clear();
      passwordController.clear();
    } catch (e) {
      // Ignore if controllers are disposed
    }
  }

  // Dummy users
  final Map<String, String> _dummyUsers = {
    'admin@gmail.com': '123456',
    'user@gmail.com': 'password',
    'test@gmail.com': 'test123',
  };

  bool validateForm() {
    return emailController.text.isNotEmpty && 
           passwordController.text.isNotEmpty;
  }

  String? validateEmail() {
    if (emailController.text.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validatePassword() {
    if (passwordController.text.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (passwordController.text.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  bool validateLogin() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    
    return _dummyUsers.containsKey(email) && _dummyUsers[email] == password;
  }

  String? getLoginError() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    
    if (!_dummyUsers.containsKey(email)) {
      return 'Email tidak terdaftar';
    }
    
    if (_dummyUsers[email] != password) {
      return 'Password salah';
    }
    
    return null;
  }
}

final loginControllerProvider = StateNotifierProvider<LoginController, void>((ref) {
  return LoginController();
});
