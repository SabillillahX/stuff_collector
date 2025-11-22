import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthController extends StateNotifier<void> {
  AuthController() : super(null);
  
  // Login controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  // Registration controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  // Forgot password controller
  final TextEditingController forgotPasswordEmailController = TextEditingController();
  
  bool _isDisposed = false;

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    
    try {
      // Login controllers
      emailController.dispose();
      passwordController.dispose();
      
      // Registration controllers
      nameController.dispose();
      registerEmailController.dispose();
      registerPasswordController.dispose();
      confirmPasswordController.dispose();
      
      // Forgot password controller
      forgotPasswordEmailController.dispose();
    } catch (e) {
      // Ignore disposal errors
    }
    super.dispose();
  }

  // Clear login fields
  void clearLoginFields() {
    if (_isDisposed) return;
    
    try {
      emailController.clear();
      passwordController.clear();
    } catch (e) {
      // Ignore if controllers are disposed
    }
  }

  // Clear registration fields
  void clearRegisterFields() {
    if (_isDisposed) return;
    
    try {
      nameController.clear();
      registerEmailController.clear();
      registerPasswordController.clear();
      confirmPasswordController.clear();
    } catch (e) {
      // Ignore if controllers are disposed
    }
  }

  // Clear forgot password fields
  void clearForgotPasswordFields() {
    if (_isDisposed) return;
    
    try {
      forgotPasswordEmailController.clear();
    } catch (e) {
      // Ignore if controllers are disposed
    }
  }

  // Clear all fields
  void clearAllFields() {
    clearLoginFields();
    clearRegisterFields();
    clearForgotPasswordFields();
  }

  // LOGIN VALIDATION METHODS
  String? validateLoginEmail() {
    if (emailController.text.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validateLoginPassword() {
    if (passwordController.text.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (passwordController.text.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  bool isLoginFormValid() {
    return validateLoginEmail() == null && validateLoginPassword() == null;
  }

  bool validateLoginForm() {
    return emailController.text.isNotEmpty && 
           passwordController.text.isNotEmpty;
  }

  // REGISTRATION VALIDATION METHODS
  String? validateName() {
    if (nameController.text.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (nameController.text.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  String? validateRegisterEmail() {
    if (registerEmailController.text.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(registerEmailController.text)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validateRegisterPassword() {
    if (registerPasswordController.text.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (registerPasswordController.text.length < 6) {
      return 'Password minimal 6 karakter';
    }
    
    final password = registerPasswordController.text;
    
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password harus mengandung minimal 1 huruf kapital';
    }
    
    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password harus mengandung minimal 1 huruf kecil';
    }
    
    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password harus mengandung minimal 1 angka';
    }
    
    return null;
  }

  String? validateConfirmPassword() {
    if (confirmPasswordController.text.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (registerPasswordController.text != confirmPasswordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  bool validateRegisterForm() {
    return nameController.text.isNotEmpty && 
           registerEmailController.text.isNotEmpty &&
           registerPasswordController.text.isNotEmpty &&
           confirmPasswordController.text.isNotEmpty;
  }

  bool validateAllRegisterFields() {
    final nameError = validateName();
    final emailError = validateRegisterEmail();
    final passwordError = validateRegisterPassword();
    final confirmPasswordError = validateConfirmPassword();
    
    return nameError == null && 
           emailError == null && 
           passwordError == null && 
           confirmPasswordError == null;
  }

  Map<String, String> getRegisterFormData() {
    return {
      'name': nameController.text.trim(),
      'email': registerEmailController.text.trim(),
      'password': registerPasswordController.text.trim(),
    };
  }

  Map<String, String> getLoginFormData() {
    return {
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
    };
  }

  // FORGOT PASSWORD VALIDATION METHODS
  String? validateForgotPasswordEmail() {
    if (forgotPasswordEmailController.text.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(forgotPasswordEmailController.text)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  bool isForgotPasswordFormValid() {
    return validateForgotPasswordEmail() == null;
  }

  String getForgotPasswordEmail() {
    return forgotPasswordEmailController.text.trim();
  }

  // Convenience methods for backward compatibility
  void clearFields() => clearLoginFields(); // Default to login fields for existing code
}

final authControllerProvider = StateNotifierProvider<AuthController, void>((ref) {
  return AuthController();
});