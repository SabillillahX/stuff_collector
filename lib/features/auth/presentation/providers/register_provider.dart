import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterState {
  final bool isLoading;
  final String? error;
  final bool isRegistered;
  final String? userEmail;

  const RegisterState({
    this.isLoading = false,
    this.error,
    this.isRegistered = false,
    this.userEmail,
  });

  RegisterState copyWith({
    bool? isLoading,
    String? error,
    bool? isRegistered,
    String? userEmail,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isRegistered: isRegistered ?? this.isRegistered,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}

class RegisterNotifier extends StateNotifier<RegisterState> {
  RegisterNotifier() : super(const RegisterState());

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Check if email already exists (dummy check)
      final existingEmails = ['admin@gmail.com', 'user@gmail.com', 'test@gmail.com'];
      
      if (existingEmails.contains(email)) {
        state = state.copyWith(
          isLoading: false,
          error: 'Email sudah terdaftar',
        );
        return;
      }
      
      // Save registration session
      await _saveRegistrationSession(name, email);
      
      state = state.copyWith(
        isLoading: false,
        isRegistered: true,
        userEmail: email,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Terjadi kesalahan. Silakan coba lagi.',
      );
    }
  }

  Future<void> _saveRegistrationSession(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    
    // Save user session
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email);
    await prefs.setString('userName', name);
    await prefs.setString('loginTime', now.toIso8601String());
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final registerProvider = StateNotifierProvider<RegisterNotifier, RegisterState>((ref) {
  return RegisterNotifier();
});
