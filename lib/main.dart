import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/domain/services/firebase_options.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/onboarding/presentation/providers/onboarding_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: '.env');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final onboardingState = ref.watch(onboardingProvider);

    return MaterialApp(
      title: 'Stuff Collector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.inter().fontFamily,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
      ),
      home: _getInitialPage(onboardingState, authState),
    );
  }

  Widget _getInitialPage(
    OnboardingState onboardingState,
    AuthState authState,
  ) {
    // Show loading while checking states
    if (onboardingState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If onboarding not completed, show onboarding
    if (!onboardingState.isCompleted) {
      return const OnboardingPage();
    }

    // If onboarding completed, check login status
    if (authState.isAuthenticated) {
      return const DashboardPage();
    }

    // Default to login page
    return const LoginPage();
  }
}
