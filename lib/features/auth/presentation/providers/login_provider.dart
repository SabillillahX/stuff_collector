import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  LoginNotifier() : super(const LoginState()) {
    _checkAuthState();
  }

  // Check current Firebase Auth state
  Future<void> _checkAuthState() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      state = state.copyWith(
        isAuthenticated: true,
        userEmail: user.email,
      );
    }
    
    // Listen to auth state changes
    _firebaseAuth.authStateChanges().listen((User? user) {
      if (user != null) {
        state = state.copyWith(
          isAuthenticated: true,
          userEmail: user.email,
        );
      } else {
        state = const LoginState();
      }
    });
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Sign in with Firebase Auth
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        // Save login session for offline tracking
        await _saveLoginSession(user.email!);
        
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          userEmail: user.email,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Email tidak terdaftar';
          break;
        case 'wrong-password':
          errorMessage = 'Password salah';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid';
          break;
        case 'user-disabled':
          errorMessage = 'Akun telah dinonaktifkan';
          break;
        case 'too-many-requests':
          errorMessage = 'Terlalu banyak percobaan. Coba lagi nanti';
          break;
        case 'invalid-credential':
          errorMessage = 'Email atau password salah';
          break;
        default:
          errorMessage = 'Login gagal: ${e.message}';
      }
      
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    } catch (e) {
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
      
      // Save current session
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', email);
      await prefs.setString('loginTime', now.toIso8601String());
      
      // Save login history (simplified to avoid complex operations)
      await prefs.setString('lastLogin_$email', now.toIso8601String());
      
    } catch (e) {
      // Don't throw error here, just log it
    }
  }

  Future<void> logout() async {
    try {
      final userEmail = state.userEmail;
      // Sign out from Firebase
      await _firebaseAuth.signOut();
      
      // Save logout history for tracking
      if (userEmail != null) {
        final prefs = await SharedPreferences.getInstance();
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
      
      // Clear local session
      await _clearSession();
      
      // State will be updated automatically by auth state listener
    } catch (e) {
      state = state.copyWith(
        error: 'Gagal logout: ${e.toString()}',
      );
    }
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

  // Google Sign-In removed: use email/password or other auth flows

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Email tidak terdaftar';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid';
          break;
        default:
          errorMessage = 'Gagal mengirim email reset: ${e.message}';
      }
      throw errorMessage;
    }
  }

  Future<void> googleAuth() async {
    

  }



  void clearError() {
    state = state.copyWith(error: null);
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier();
});
