import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../controllers/auth_controller.dart';
import '../providers/auth_provider.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import 'login_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authController = ref.watch(authControllerProvider.notifier);

    // Listen to register state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (_isDisposed || !mounted) return;

      if (next.isRegistered) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed && mounted) {
            try {
              authController.clearRegisterFields();

              // Show success message with email verification info
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Registrasi berhasil! Email verifikasi telah dikirim ke ${next.userEmail}',
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 4),
                ),
              );

              // Navigate to dashboard
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
              );
            } catch (e) {
              // Ignore if disposed
            }
          }
        });
      }

      if (next.error != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
            );
          }
        });
      }
    });

    return WillPopScope(
      onWillPop: () async {
        // Handle back navigation
        if (_isDisposed || !mounted) return true;

        final authController = ref.watch(
          authControllerProvider.notifier,
        );

        // Clear fields before navigating
        try {
          authController.clearRegisterFields();
        } catch (e) {
          // Ignore if disposed
        }

        // Clear any previous errors
        try {
          ref.read(authProvider.notifier).clearError();
        } catch (e) {
          return true; // Allow back navigation if error occurs
        }

        // Navigate to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        return false; // Prevent default back navigation
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: ResponsiveConstants.getResponsivePadding(context),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Header section
                      _buildHeaderSection(context),

                      const SizedBox(height: 20),

                      // Register Form Card
                      _buildRegisterCard(
                        context,
                        authState,
                        authController,
                      ),

                      // Footer - at bottom
                      const Spacer(),
                      _buildFooter(context),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // SVG Illustration
        Container(
          height:
              context.isMobile
                  ? 140.0
                  : context.isTablet
                  ? 160.0
                  : 180.0,
          width:
              context.isMobile
                  ? 140.0
                  : context.isTablet
                  ? 160.0
                  : 180.0,
          child: SvgPicture.asset(
            'assets/images/sign_up.svg',
            fit: BoxFit.contain,
            placeholderBuilder:
                (context) => Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.person_add, size: 50, color: Colors.grey),
                  ),
                ),
          ),
        ),
        const SizedBox(height: 16),

        // Welcome Text
        Text(
          'Buat Akun Baru',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveConstants.getResponsiveFontSize(context, 22.0),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF011936),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Daftar untuk mulai mengelola barang Anda',
          style: GoogleFonts.inter(
            fontSize: ResponsiveConstants.getResponsiveFontSize(context, 12.0),
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterCard(
    BuildContext context,
    AuthState authState,
    AuthController authController,
  ) {
    return Container(
      constraints: BoxConstraints(
        maxWidth:
            context.isMobile
                ? double.infinity
                : context.isTablet
                ? 400.0
                : 450.0,
      ),
      child: Card(
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(context.isMobile ? 16.0 : 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: authController.nameController,
                hint: 'Masukkan nama lengkap',
                label: 'Nama Lengkap',
                validator: authController.validateName,
                autoClear: true,
              ),
              SizedBox(height: context.isMobile ? 12 : 16),

              CustomTextField(
                controller: authController.registerEmailController,
                hint: 'Masukkan email anda',
                label: 'Email',
                validator: authController.validateRegisterEmail,
                autoClear: true,
              ),
              SizedBox(height: context.isMobile ? 12 : 16),

              CustomTextField(
                controller: authController.registerPasswordController,
                hint: 'Masukkan kata sandi',
                label: 'Kata Sandi',
                isPassword: true,
                validator: authController.validateRegisterPassword,
                autoClear: true,
              ),
              const SizedBox(height: 8),
              _buildPasswordStrengthIndicator(authController),
              SizedBox(height: context.isMobile ? 12 : 16),

              CustomTextField(
                controller: authController.confirmPasswordController,
                hint: 'Konfirmasi kata sandi',
                label: 'Konfirmasi Kata Sandi',
                isPassword: true,
                validator: authController.validateConfirmPassword,
                autoClear: true,
              ),
              SizedBox(height: context.isMobile ? 16 : 20),

              CustomButton(
                label: authState.isLoading ? 'Mendaftar...' : 'Daftar',
                onPressed:
                    authState.isLoading
                        ? null
                        : () => _handleRegister(authController),
                isLoading: authState.isLoading,
              ),

              const SizedBox(height: 16),

              // Divider with "or"
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'atau',
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 16),

              // Google Sign-In Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: authState.isLoading ? null : _handleGoogleSignIn,
                  icon: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://developers.google.com/identity/images/g-logo.png',
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  label: Text(
                    authState.isLoading
                        ? 'Masuk dengan Google...'
                        : 'Masuk dengan Google',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF011936),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final authController = ref.watch(authControllerProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Sudah punya akun? ",
          style: GoogleFonts.inter(
            color: Colors.grey[600],
            fontSize: ResponsiveConstants.getResponsiveFontSize(context, 14.0),
          ),
        ),
        TextButton(
          onPressed: () {
            // Clear fields before navigating
            try {
              authController.clearRegisterFields();
            } catch (e) {
              // Ignore if disposed
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: Text(
            'Masuk',
            style: GoogleFonts.inter(
              color: const Color(0xFF011936),
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveConstants.getResponsiveFontSize(
                context,
                14.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator(
    AuthController authController,
  ) {
    return ListenableBuilder(
      listenable: authController.registerPasswordController,
      builder: (context, child) {
        final password = authController.registerPasswordController.text;
        final strength = _calculatePasswordStrength(password);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Kekuatan Password: ',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  _getStrengthText(strength),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _getStrengthColor(strength),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: strength,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStrengthColor(strength),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Password harus mengandung: huruf kapital, huruf kecil, dan angka',
              style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        );
      },
    );
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0.0;

    // Length check
    if (password.length >= 6) strength += 0.25;
    if (password.length >= 8) strength += 0.25;

    // Character variety checks
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.25;

    return strength > 1.0 ? 1.0 : strength;
  }

  String _getStrengthText(double strength) {
    if (strength <= 0.25) return 'Lemah';
    if (strength <= 0.5) return 'Sedang';
    if (strength <= 0.75) return 'Kuat';
    return 'Sangat Kuat';
  }

  Color _getStrengthColor(double strength) {
    if (strength <= 0.25) return Colors.red;
    if (strength <= 0.5) return Colors.orange;
    if (strength <= 0.75) return Colors.blue;
    return Colors.green;
  }

  void _handleRegister(AuthController authController) {
    if (_isDisposed || !mounted) return;

    // Clear any previous errors
    try {
      ref.read(authProvider.notifier).clearError();
    } catch (e) {
      return;
    }

    // Validate form using controller
    if (!authController.validateAllRegisterFields()) {
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon lengkapi semua field dengan benar'),
          ),
        );
      }
      return;
    }

    // Proceed with registration using controller data
    try {
      if (!_isDisposed && mounted) {
        final formData = authController.getRegisterFormData();
        ref
            .read(authProvider.notifier)
            .register(
              name: formData['name']!,
              email: formData['email']!,
              password: formData['password']!,
            );
      }
    } catch (e) {
      // Ignore if ref is disposed
    }
  }

    void _handleGoogleSignIn() async {
    if (_isDisposed || !mounted) return;

    try {
      ref.read(authProvider.notifier).clearError();
      
      final result = await ref.read(authProvider.notifier).signInWithGoogleFirebase();
      
      if (result != null && mounted && !_isDisposed) {
        final authController = ref.read(authControllerProvider.notifier);
        authController.clearRegisterFields();
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      }
      
    } catch (e) {
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In gagal: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
