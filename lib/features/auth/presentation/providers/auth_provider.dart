import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Unified Auth State
class AuthState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final String? userEmail;
  final String? userName;

  // Registration specific
  final bool isRegistered;

  // Forgot password specific
  final bool isPasswordResetEmailSent;
  final String? passwordResetEmailSentTo;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.userEmail,
    this.userName,
    this.isRegistered = false,
    this.isPasswordResetEmailSent = false,
    this.passwordResetEmailSentTo,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    String? userEmail,
    String? userName,
    bool? isRegistered,
    bool? isPasswordResetEmailSent,
    String? passwordResetEmailSentTo,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      isRegistered: isRegistered ?? this.isRegistered,
      isPasswordResetEmailSent:
          isPasswordResetEmailSent ?? this.isPasswordResetEmailSent,
      passwordResetEmailSentTo:
          passwordResetEmailSentTo ?? this.passwordResetEmailSentTo,
    );
  }

  // Reset registration state
  AuthState resetRegistration() {
    return copyWith(isRegistered: false, error: null);
  }

  // Reset password reset state
  AuthState resetPasswordReset() {
    return copyWith(
      isPasswordResetEmailSent: false,
      passwordResetEmailSentTo: null,
      error: null,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _isGoogleSignInInitialized = false;

  AuthNotifier() : super(const AuthState()) {
    _checkAuthState();
  }

  authService() {
    _initializeGoogleSignIn();
  }

  // google sign in initialization
  Future<void> _initializeGoogleSignIn() async {
    if (!_isGoogleSignInInitialized) {
      await _googleSignIn.initialize(
        serverClientId: '622769924606-fpb755o7jqvg1e5aej7j2jen6vp9ptst.apps.googleusercontent.com'
      );
    }
    _isGoogleSignInInitialized = true;
  }

  // Google Sign-In
  Future<UserCredential?> signInWithGoogleFirebase() async {
    try {
      _initializeGoogleSignIn();

      final GoogleSignInAccount? googleUser =
          await _googleSignIn.authenticate();

      final idToken = googleUser?.authentication.idToken;
      final authorizationClient = googleUser?.authorizationClient;

      GoogleSignInClientAuthorization? authorization = await authorizationClient
          ?.authorizationForScopes(['email', 'profile']);

      final accessToken = authorization?.accessToken;

      if (accessToken == null) {
        final authorization2 = await googleUser?.authorizationClient
            .authorizationForScopes(['email', 'profile']);

        if (authorization2?.accessToken == null) {
          throw FirebaseAuthException(
            code: 'ERROR_MISSING_GOOGLE_AUTH_TOKEN',
            message: 'Missing Google Auth Token',
          );
        }
        authorization = authorization2;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: authorization!.accessToken,
        idToken: idToken,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          await userDoc.set({
            'userId': user.uid,
            'email': user.email,
            'name': user.displayName,
            'photoUrl': user.photoURL,
            'provider': 'google',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          userEmail: user.email,
          userName: user.displayName,
        );
      }

      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('Google Sign-In failed: $e');
      }
      return null;
    }
  }

  // google sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      logout();
    } catch (e) {
      if (kDebugMode) {
        print('Google Sign-Out failed: $e');
      }
      // Handle sign-out error if necessary
    }   
  }

  // Check current Firebase Auth state
  Future<void> _checkAuthState() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      state = state.copyWith(
        isAuthenticated: true,
        userEmail: user.email,
        userName: user.displayName,
      );
    }

    // Listen to auth state changes
    _firebaseAuth.authStateChanges().listen((User? user) {
      if (user != null) {
        state = state.copyWith(
          isAuthenticated: true,
          userEmail: user.email,
          userName: user.displayName,
        );
      } else {
        state = const AuthState();
      }
    });
  }

  // LOGIN FUNCTIONALITY
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Sign in with Firebase Auth
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email.trim(), password: password);

      final user = userCredential.user;
      if (user != null) {
        // Save login session for offline tracking
        await _saveLoginSession(user.email!, user.displayName);

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          userEmail: user.email,
          userName: user.displayName,
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

      state = state.copyWith(isLoading: false, error: errorMessage);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<void> _saveLoginSession(String email, String? name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      // Save current session
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', email);
      if (name != null) {
        await prefs.setString('userName', name);
      }
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
      state = state.copyWith(error: 'Gagal logout: ${e.toString()}');
    }
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userEmail');
    await prefs.remove('userName');
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

  // REGISTER FUNCTIONALITY
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Create user with Firebase Auth
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      final user = userCredential.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(name);

        // Send email verification
        if (!user.emailVerified) {
          await user.sendEmailVerification();
        }

        // Save registration session for local tracking
        await _saveRegistrationSession(name, email);

        state = state.copyWith(
          isLoading: false,
          isRegistered: true,
          isAuthenticated: true,
          userEmail: user.email,
          userName: name,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password terlalu lemah';
          break;
        case 'email-already-in-use':
          errorMessage = 'Email sudah terdaftar';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Registrasi tidak diizinkan';
          break;
        default:
          errorMessage = 'Registrasi gagal: ${e.message}';
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Terjadi kesalahan: ${e.toString()}',
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

  Future<void> resendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'too-many-requests':
          errorMessage = 'Terlalu banyak permintaan. Coba lagi nanti';
          break;
        default:
          errorMessage = 'Gagal mengirim email verifikasi: ${e.message}';
      }
      state = state.copyWith(error: errorMessage);
    }
  }

  // FORGOT PASSWORD FUNCTIONALITY
  Future<void> sendPasswordResetEmail({required String email}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Send password reset email
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());

      state = state.copyWith(
        isLoading: false,
        isPasswordResetEmailSent: true,
        passwordResetEmailSentTo: email.trim(),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Email tidak terdaftar dalam sistem';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid';
          break;
        case 'too-many-requests':
          errorMessage =
              'Terlalu banyak permintaan. Silakan coba lagi dalam beberapa menit';
          break;
        case 'user-disabled':
          errorMessage = 'Akun pengguna telah dinonaktifkan';
          break;
        default:
          errorMessage = 'Gagal mengirim email reset password: ${e.message}';
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<void> resendPasswordResetEmail() async {
    if (state.passwordResetEmailSentTo != null) {
      await sendPasswordResetEmail(email: state.passwordResetEmailSentTo!);
    }
  }

  // UTILITY METHODS
  void clearError() {
    state = state.copyWith(error: null);
  }

  void resetRegistration() {
    state = state.resetRegistration();
  }

  void resetPasswordReset() {
    state = state.resetPasswordReset();
  }

  void reset() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
