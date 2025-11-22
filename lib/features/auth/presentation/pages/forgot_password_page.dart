import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../providers/auth_provider.dart';
import '../controllers/auth_controller.dart';
import 'login_page.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
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

    // Listen to state changes for showing messages
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (_isDisposed || !mounted) return;
      
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF011936)),
            onPressed: () {
              if (!_isDisposed && mounted) {
                ref.read(authProvider.notifier).resetPasswordReset();
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            'Reset Password',
            style: GoogleFonts.poppins(
              color: const Color(0xFF011936),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: ResponsiveConstants.getResponsivePadding(context),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom - 
                          kToolbarHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Check if email is sent or show form
                    if (authState.isPasswordResetEmailSent)
                      _buildSuccessSection(context, authState)
                    else
                      _buildFormSection(context, authState, authController),
                    
                    const Spacer(),
                    _buildBackToLoginButton(context),
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

  Widget _buildFormSection(BuildContext context, AuthState state, AuthController authController) {
    return Column(
      children: [
        // SVG Illustration
        Container(
          height: context.isMobile ? 160.0 : context.isTablet ? 180.0 : 200.0,
          width: context.isMobile ? 160.0 : context.isTablet ? 180.0 : 200.0,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Icon(
              Icons.lock_reset,
              size: 80,
              color: Color(0xFF011936),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Title and Description
        Text(
          'Lupa Password?',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveConstants.getResponsiveFontSize(context, 24.0),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF011936),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Jangan khawatir! Masukkan email Anda dan kami akan mengirimkan link untuk reset password',
            style: GoogleFonts.inter(
              fontSize: ResponsiveConstants.getResponsiveFontSize(context, 14.0),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Email Input Card
        Container(
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
              padding: EdgeInsets.all(context.isMobile ? 20.0 : 24.0),
              child: Column(
                children: [
                  CustomTextField(
                    controller: authController.forgotPasswordEmailController,
                    hint: 'Masukkan email anda',
                    label: 'Email',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  CustomButton(
                    label: state.isLoading ? 'Mengirim...' : 'Kirim Link Reset',
                    onPressed: state.isLoading ? null : () => _handleSendResetEmail(authController),
                    isLoading: state.isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessSection(BuildContext context, AuthState state) {
    return Column(
      children: [
        // Success Icon
        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read,
            size: 60,
            color: Colors.green,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Success Title
        Text(
          'Email Terkirim!',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveConstants.getResponsiveFontSize(context, 24.0),
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Success Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: ResponsiveConstants.getResponsiveFontSize(context, 14.0),
                color: Colors.grey[600],
              ),
              children: [
                const TextSpan(text: 'Link reset password telah dikirim ke '),
                TextSpan(
                  text: state.passwordResetEmailSentTo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF011936),
                  ),
                ),
                const TextSpan(text: '. Silakan cek email Anda dan ikuti petunjuk yang diberikan.'),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Instructions
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Langkah Selanjutnya:',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInstructionItem('1. Buka email Anda'),
              _buildInstructionItem('2. Klik link reset password'),
              _buildInstructionItem('3. Masukkan password baru'),
              _buildInstructionItem('4. Login dengan password baru'),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Resend Button
        TextButton.icon(
          onPressed: state.isLoading ? null : _handleResendEmail,
          icon: state.isLoading 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.refresh),
          label: Text(
            state.isLoading ? 'Mengirim ulang...' : 'Kirim ulang email',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildBackToLoginButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Ingat password Anda? ',
          style: GoogleFonts.inter(
            color: Colors.grey[600],
            fontSize: ResponsiveConstants.getResponsiveFontSize(context, 14.0),
          ),
        ),
        TextButton(
          onPressed: () {
            if (!_isDisposed && mounted) {
              ref.read(authProvider.notifier).resetPasswordReset();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            }
          },
          child: Text(
            'Kembali ke Login',
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

  void _handleSendResetEmail(AuthController authController) {
    if (_isDisposed || !mounted) return;
    
    final email = authController.forgotPasswordEmailController.text.trim();
    
    // Validate email
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon masukkan email Anda')),
      );
      return;
    }
    
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format email tidak valid')),
      );
      return;
    }
    
    // Clear previous errors and send reset email
    ref.read(authProvider.notifier).clearError();
    ref.read(authProvider.notifier).sendPasswordResetEmail(email: email);
  }

  void _handleResendEmail() {
    if (_isDisposed || !mounted) return;
    
    ref.read(authProvider.notifier).resendPasswordResetEmail();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email reset password telah dikirim ulang'),
        backgroundColor: Colors.green,
      ),
    );
  }
}