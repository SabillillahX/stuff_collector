import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../providers/login_provider.dart';
import '../controllers/login_controller.dart';
import 'register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _isDisposed = false;
  
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final loginController = ref.watch(loginControllerProvider.notifier);

    // Listen to login state changes with proper disposal check
    ref.listen<LoginState>(loginProvider, (previous, next) {
      if (_isDisposed || !mounted) return;
      
      if (next.isAuthenticated) {
        // Use WidgetsBinding to ensure operations happen after current frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed && mounted) {
            try {
              loginController.clearFields();
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
              SnackBar(
                content: Text(next.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    });

    return GestureDetector(
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
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Header section - flexible
                    _buildHeaderSection(context),
                    
                    // Spacer
                    const SizedBox(height: 20),
                    
                    // Login Form Card - takes available space
                    _buildLoginCard(context, loginState, loginController),
                    
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
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // SVG Illustration - bigger size
        Container(
          height: context.isMobile ? 180.0 : context.isTablet ? 200.0 : 220.0,
          width: context.isMobile ? 180.0 : context.isTablet ? 200.0 : 220.0,
          child: SvgPicture.asset(
            'assets/images/sign_in.svg',
            fit: BoxFit.contain,
            placeholderBuilder: (context) => Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.image, size: 60, color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Welcome Text
        Text(
          'Selamat Datang Kembali!',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveConstants.getResponsiveFontSize(context, 22.0),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF011936),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Masuk ke Akun Anda untuk melanjutkan',
          style: GoogleFonts.inter(
            fontSize: ResponsiveConstants.getResponsiveFontSize(context, 12.0),
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context, LoginState loginState, LoginController loginController) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: context.isMobile ? double.infinity : context.isTablet ? 400.0 : 450.0,
      ),
      child: Card(
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(context.isMobile ? 16.0 : 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: loginController.emailController,
                hint: 'Masukkan email anda',
                label: 'Email',
                validator: loginController.validateEmail,
                autoClear: true, // Auto clear after successful login
              ),
              SizedBox(height: context.isMobile ? 12 : 16),
              
              CustomTextField(
                controller: loginController.passwordController,
                hint: 'Masukkan kata sandi anda',
                label: 'Kata Sandi',
                isPassword: true,
                validator: loginController.validatePassword,
                autoClear: true, // Auto clear after successful login
              ),
              SizedBox(height: context.isMobile ? 16 : 20),
              
              CustomButton(
                label: loginState.isLoading ? 'Masuk...' : 'Masuk',
                onPressed: loginState.isLoading ? null : () => _handleLogin(loginController),
                isLoading: loginState.isLoading,
              ),
              
              const SizedBox(height: 8),
              
              TextButton(
                onPressed: () {
                  // Navigate to forgot password
                },
                child: Text(
                  'Lupa Kata Sandi?',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF011936),
                    fontWeight: FontWeight.w500,
                    fontSize: ResponsiveConstants.getResponsiveFontSize(context, 12.0),
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
    final loginController = ref.watch(loginControllerProvider.notifier);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Tidak punya akun? ",
          style: GoogleFonts.inter(
            color: Colors.grey[600],
            fontSize: ResponsiveConstants.getResponsiveFontSize(context, 14.0),
          ),
        ),
        TextButton(
          onPressed: () {
            // Clear fields before navigating
            try {
              loginController.clearFields();
            } catch (e) {
              // Ignore if disposed
            }
            
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RegisterPage()),
            );
          },
          child: Text(
            'Daftar disini',
            style: GoogleFonts.inter(
              color: const Color(0xFF011936),
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveConstants.getResponsiveFontSize(context, 14.0),
            ),
          ),
        ),
      ],
    );
  }

  void _handleLogin(LoginController loginController) {
    if (_isDisposed || !mounted) return;
    
    // Clear any previous errors safely
    try {
      ref.read(loginProvider.notifier).clearError();
    } catch (e) {
      return;
    }
    
    // Validate form first
    final emailError = loginController.validateEmail();
    final passwordError = loginController.validatePassword();
    
    if (emailError != null || passwordError != null) {
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon lengkapi semua field dengan benar')),
        );
      }
      return;
    }

    // Proceed with login safely
    try {
      if (!_isDisposed && mounted) {
        ref.read(loginProvider.notifier).login(
          email: loginController.emailController.text,
          password: loginController.passwordController.text,
        );
      }
    } catch (e) {
      // Ignore if ref is disposed
    }
  }
}
