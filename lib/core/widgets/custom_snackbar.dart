import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/responsive_constants.dart';

class CustomToast {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OverlayState? overlayState = Overlay.of(context);
      if (overlayState == null) return;

      OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) => FadeToast(
          title: title,
          message: message,
          icon: icon ?? Icons.info,
          backgroundColor: backgroundColor ?? Colors.redAccent.withOpacity(0.9),
          textColor: textColor ?? Colors.white,
        ),
      );

      overlayState.insert(overlayEntry);

      Future.delayed(const Duration(seconds: 3), () {
        overlayEntry.remove();
      });
    });
  }

  // ...existing helper methods...
}

class FadeToast extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;

  const FadeToast({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  _FadeToastState createState() => _FadeToastState();
}

class _FadeToastState extends State<FadeToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(milliseconds: 2500), () {
      _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: context.isMobile ? 16 : 50,
      right: context.isMobile ? 16 : 50,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(context.isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(context.isMobile ? 16 : 20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  color: widget.textColor,
                  size: context.isMobile ? 20 : 24,
                ),
                SizedBox(width: context.isMobile ? 8 : 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.inter(
                          color: widget.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveConstants.getResponsiveFontSize(context, 14.0),
                        ),
                      ),
                      Text(
                        widget.message,
                        style: GoogleFonts.inter(
                          color: widget.textColor,
                          fontSize: ResponsiveConstants.getResponsiveFontSize(context, 12.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ...existing provider code...
