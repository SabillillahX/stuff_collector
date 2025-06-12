import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final String? userEmail;

  const LoginState({
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.userEmail,
  });

  LoginState copyWith({
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    String? userEmail,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(const LoginState()) {
    _checkLoginSession();
  }

  // Check if user is already logged in
  Future<void> _checkLoginSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userEmail = prefs.getString('userEmail');
    final loginTime = prefs.getString('loginTime');
    
    if (isLoggedIn && userEmail != null && loginTime != null) {
      // Check if login session is still valid (e.g., within 30 days)
      final lastLoginTime = DateTime.parse(loginTime);
      final now = DateTime.now();
      final difference = now.difference(lastLoginTime).inDays;
      
      if (difference < 30) { // Session valid for 30 days
        state = state.copyWith(
          isAuthenticated: true,
          userEmail: userEmail,
        );
      } else {
        // Session expired, clear it
        await _clearSession();
      }
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Dummy user validation
      final Map<String, String> dummyUsers = {
        'admin@gmail.com': '123456',
        'user@gmail.com': 'password',
        'test@gmail.com': 'test123',
      };
      
      print('Debug: Attempting login with email: $email, password: $password'); // Debug line
      
      if (dummyUsers.containsKey(email) && dummyUsers[email] == password) {
        print('Debug: Login successful'); // Debug line
        
        // Save login session and history
        await _saveLoginSession(email);
        
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          userEmail: email,
        );
      } else {
        print('Debug: Login failed - invalid credentials'); // Debug line
        state = state.copyWith(
          isLoading: false,
          error: 'Email atau password salah',
        );
      }
    } catch (e) {
      print('Debug: Login error: $e'); // Debug line
      state = state.copyWith(
        isLoading: false,
        error: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<void> _saveLoginSession(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      
      print('Debug: Saving login session for $email'); // Debug line
      
      // Save current session
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', email);
      await prefs.setString('loginTime', now.toIso8601String());
      
      print('Debug: Login session saved successfully'); // Debug line
      
      // Save login history (simplified to avoid complex operations)
      await prefs.setString('lastLogin_$email', now.toIso8601String());
      
    } catch (e) {
      print('Debug: Error saving login session: $e'); // Debug line
      // Don't throw error here, just log it
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = state.userEmail;
    
    if (userEmail != null) {
      // Save logout time in history
      final now = DateTime.now();
      List<String> loginHistory = prefs.getStringList('loginHistory') ?? [];
      
      final logoutEntry = {
        'email': userEmail,
        'logoutTime': now.toIso8601String(),
        'action': 'logout',
      };
      
      loginHistory.add(logoutEntry.toString());
      await prefs.setStringList('loginHistory', loginHistory);
      await prefs.setString('lastLogout_$userEmail', now.toIso8601String());
    }
    
    // Clear current session
    await _clearSession();
    state = const LoginState();
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userEmail');
    await prefs.remove('loginTime');
  }

  // Get login history (optional - for debugging or user info)
  Future<List<String>> getLoginHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('loginHistory') ?? [];
  }

  // Check last login time for specific user
  Future<DateTime?> getLastLoginTime(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoginString = prefs.getString('lastLogin_$email');
    if (lastLoginString != null) {
      return DateTime.parse(lastLoginString);
    }
    return null;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier();
});
