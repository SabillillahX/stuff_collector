import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../providers/onboarding_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      image: 'assets/images/onboarding_1.svg',
      title: 'Kelola Barang dengan Mudah',
      description: 'Simpan dan atur semua barang Anda dalam satu aplikasi yang mudah digunakan',
    ),
    OnboardingData(
      image: 'assets/images/onboarding_2.svg',
      title: 'Kategorisasi Otomatis',
      description: 'Organisir barang berdasarkan kategori untuk memudahkan pencarian dan pengelolaan',
    ),
    OnboardingData(
      image: 'assets/images/onboarding_3.svg',
      title: 'Laporan dan Analisis',
      description: 'Dapatkan insight tentang inventori Anda dengan grafik dan statistik yang informatif',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            _buildSkipButton(),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_onboardingData[index]);
                },
              ),
            ),
            
            // Page indicator and navigation
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _skipOnboarding,
            child: Text(
              'Lewati',
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return Padding(
      padding: ResponsiveConstants.getResponsivePadding(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SVG Image
          Container(
            height: context.isMobile ? 250.0 : context.isTablet ? 300.0 : 350.0,
            width: context.isMobile ? 250.0 : context.isTablet ? 300.0 : 350.0,
            child: SvgPicture.asset(
              data.image,
              fit: BoxFit.contain,
              placeholderBuilder: (context) => Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.inventory,
                  size: 80,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          
          // Title
          Text(
            data.title,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveConstants.getResponsiveFontSize(context, 24.0),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF011936),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            data.description,
            style: GoogleFonts.inter(
              fontSize: ResponsiveConstants.getResponsiveFontSize(context, 14.0),
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingData.length,
              (index) => _buildPageIndicator(index),
            ),
          ),
          const SizedBox(height: 32),
          
          // Navigation buttons
          Row(
            children: [
              if (_currentPage > 0) ...[
                Expanded(
                  child: TextButton(
                    onPressed: _previousPage,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Text(
                      'Kembali',
                      style: GoogleFonts.inter(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                flex: _currentPage > 0 ? 1 : 2,
                child: CustomButton(
                  label: _currentPage == _onboardingData.length - 1 ? 'Mulai' : 'Lanjut',
                  onPressed: _currentPage == _onboardingData.length - 1
                      ? _finishOnboarding
                      : _nextPage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    bool isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF011936) : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    ref.read(onboardingProvider.notifier).completeOnboarding();
    _navigateToLogin();
  }

  void _finishOnboarding() {
    ref.read(onboardingProvider.notifier).completeOnboarding();
    _navigateToLogin();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}

class OnboardingData {
  final String image;
  final String title;
  final String description;

  OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}
