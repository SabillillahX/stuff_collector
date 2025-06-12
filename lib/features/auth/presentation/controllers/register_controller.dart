import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterController extends StateNotifier<void> {
  RegisterController() : super(null);
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _isDisposed = false;

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    
    try {
      nameController.dispose();
      emailController.dispose();
      passwordController.dispose();
      confirmPasswordController.dispose();
    } catch (e) {
      // Ignore disposal errors
    }
    super.dispose();
  }

  void clearFields() {
    if (_isDisposed) return;
    
    try {
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
    } catch (e) {
      // Ignore if controllers are disposed
    }
  }

  String? validateName() {
    if (nameController.text.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (nameController.text.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
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

  String? validateConfirmPassword() {
    if (confirmPasswordController.text.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (passwordController.text != confirmPasswordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  bool validateForm() {
    return nameController.text.isNotEmpty && 
           emailController.text.isNotEmpty &&
           passwordController.text.isNotEmpty &&
           confirmPasswordController.text.isNotEmpty;
  }

  bool validateAllFields() {
    final nameError = validateName();
    final emailError = validateEmail();
    final passwordError = validatePassword();
    final confirmPasswordError = validateConfirmPassword();
    
    return nameError == null && 
           emailError == null && 
           passwordError == null && 
           confirmPasswordError == null;
  }

  Map<String, String> getFormData() {
    return {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
    };
  }
}

final registerControllerProvider = StateNotifierProvider<RegisterController, void>((ref) {
  return RegisterController();
});
