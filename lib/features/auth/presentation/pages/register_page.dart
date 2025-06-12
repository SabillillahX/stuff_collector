import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../controllers/register_controller.dart';
import '../providers/register_provider.dart';
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
    final registerState = ref.watch(registerProvider);
    final registerController = ref.watch(registerControllerProvider.notifier);

    // Listen to register state changes
    ref.listen<RegisterState>(registerProvider, (previous, next) {
      if (_isDisposed || !mounted) return;
      
      if (next.isRegistered) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed && mounted) {
            try {
              registerController.clearFields();
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

    return WillPopScope(
      onWillPop: () async{
        // Handle back navigation
        if (_isDisposed || !mounted) return true;
        
        final registerController = ref.watch(registerControllerProvider.notifier);
        
        // Clear fields before navigating
        try {
          registerController.clearFields();
        } catch (e) {
          // Ignore if disposed
        }
        
        // Clear any previous errors
        try {
          ref.read(registerProvider.notifier).clearError();
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
                  minHeight: MediaQuery.of(context).size.height - 
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
                      _buildRegisterCard(context, registerState, registerController),
                      
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
          height: context.isMobile ? 140.0 : context.isTablet ? 160.0 : 180.0,
          width: context.isMobile ? 140.0 : context.isTablet ? 160.0 : 180.0,
          child: SvgPicture.asset(
            'assets/images/sign_up.svg',
            fit: BoxFit.contain,
            placeholderBuilder: (context) => Container(
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

  Widget _buildRegisterCard(BuildContext context, RegisterState registerState, RegisterController registerController) {
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
                controller: registerController.nameController,
                hint: 'Masukkan nama lengkap',
                label: 'Nama Lengkap',
                validator: registerController.validateName,
                autoClear: true,
              ),
              SizedBox(height: context.isMobile ? 12 : 16),
              
              CustomTextField(
                controller: registerController.emailController,
                hint: 'Masukkan email anda',
                label: 'Email',
                validator: registerController.validateEmail,
                autoClear: true,
              ),
              SizedBox(height: context.isMobile ? 12 : 16),
              
              CustomTextField(
                controller: registerController.passwordController,
                hint: 'Masukkan kata sandi',
                label: 'Kata Sandi',
                isPassword: true,
                validator: registerController.validatePassword,
                autoClear: true,
              ),
              SizedBox(height: context.isMobile ? 12 : 16),
              
              CustomTextField(
                controller: registerController.confirmPasswordController,
                hint: 'Konfirmasi kata sandi',
                label: 'Konfirmasi Kata Sandi',
                isPassword: true,
                validator: registerController.validateConfirmPassword,
                autoClear: true,
              ),
              SizedBox(height: context.isMobile ? 16 : 20),
              
              CustomButton(
                label: registerState.isLoading ? 'Mendaftar...' : 'Daftar',
                onPressed: registerState.isLoading ? null : () => _handleRegister(registerController),
                isLoading: registerState.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final registerController = ref.watch(registerControllerProvider.notifier);
    
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
              registerController.clearFields();
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
              fontSize: ResponsiveConstants.getResponsiveFontSize(context, 14.0),
            ),
          ),
        ),
      ],
    );
  }

  void _handleRegister(RegisterController registerController) {
    if (_isDisposed || !mounted) return;
    
    // Clear any previous errors
    try {
      ref.read(registerProvider.notifier).clearError();
    } catch (e) {
      return;
    }
    
    // Validate form using controller
    if (!registerController.validateAllFields()) {
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon lengkapi semua field dengan benar')),
        );
      }
      return;
    }

    // Proceed with registration using controller data
    try {
      if (!_isDisposed && mounted) {
        final formData = registerController.getFormData();
        ref.read(registerProvider.notifier).register(
          name: formData['name']!,
          email: formData['email']!,
          password: formData['password']!,
        );
      }
    } catch (e) {
      // Ignore if ref is disposed
    }
  }
}
