import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../hospital/hospital_registration_screen.dart';

/// SplashScreen widget for MediKiosk.
/// 
/// Designed for Smart India Hackathon (SIH) in an Indian public-health context.
/// Features a responsive layout, modern healthcare aesthetics, animated elements,
/// accessible high-contrast colors (Saffron, Navy, Green, and White),
/// and automatic navigation to the HospitalRegistrationScreen after a 2.5-second delay.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
    _scheduleNavigation();
  }

  /// Schedules navigation to the HospitalRegistrationScreen after a 2.5-second delay.
  void _scheduleNavigation() {
    _navigationTimer = Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HospitalRegistrationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Top Public Health Header Badge
                            const _HeaderBadge(),

                            SizedBox(height: screenHeight * 0.04),

                            // Central Brand Branding Section
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                _MedicalLogo(),
                                SizedBox(height: 32.0),
                                _AppBranding(),
                                SizedBox(height: 16.0),
                                _TricolorAccentBar(),
                              ],
                            ),

                            SizedBox(height: screenHeight * 0.04),

                            // Bottom Loader and Security Verification Footer
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                _LoadingSection(),
                                SizedBox(height: 28.0),
                                _SecurityFooter(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Header badge representing public health initiative context.
class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.verified_rounded,
            size: 16.0,
            color: AppColors.greenSuccess,
          ),
          SizedBox(width: 8.0),
          Flexible(
            child: Text(
              'PUBLIC HEALTH INITIATIVE • SIH 2026',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Emblem for MediKiosk.
class _MedicalLogo extends StatelessWidget {
  const _MedicalLogo();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer subtle glow ring
        Container(
          width: 140.0,
          height: 140.0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.saffronLight,
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 24.0,
                offset: Offset(0, 8),
              ),
            ],
          ),
        ),
        // Middle decorative saffron accent border
        Container(
          width: 120.0,
          height: 120.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.background,
            border: Border.all(
              color: AppColors.saffronPrimary,
              width: 3.0,
            ),
          ),
        ),
        // Inner core icon background
        Container(
          width: 96.0,
          height: 96.0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.navyPrimary,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: const [
              Icon(
                Icons.local_hospital_rounded,
                size: 48.0,
                color: AppColors.background,
              ),
              Positioned(
                bottom: 18,
                right: 18,
                child: CircleAvatar(
                  radius: 8.0,
                  backgroundColor: AppColors.background,
                  child: Icon(
                    Icons.add_rounded,
                    size: 14.0,
                    color: AppColors.greenSuccess,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Main application title and tagline widgets.
class _AppBranding extends StatelessWidget {
  const _AppBranding();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text(
          'MediKiosk',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.navyPrimary,
            fontSize: 32.0,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            height: 1.2,
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          'Hospital Management & Public Health Kiosk',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

/// Subtle tricolor accent indicator line representing Indian public health visual identity.
class _TricolorAccentBar extends StatelessWidget {
  const _TricolorAccentBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.0,
      height: 4.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.saffronPrimary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(2.0),
                  bottomLeft: Radius.circular(2.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.surfaceBorder,
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.greenSuccess,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(2.0),
                  bottomRight: Radius.circular(2.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Customized subtle loading section.
class _LoadingSection extends StatelessWidget {
  const _LoadingSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 36.0,
          height: 36.0,
          child: CircularProgressIndicator(
            strokeWidth: 3.2,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.saffronPrimary),
            backgroundColor: AppColors.navyLight.withValues(alpha: 0.12),
          ),
        ),
        const SizedBox(height: 16.0),
        const Text(
          'Initializing MediKiosk Hospital Portal...',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

/// Footer showing platform security and version information.
class _SecurityFooter extends StatelessWidget {
  const _SecurityFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.lock_outline_rounded,
              size: 14.0,
              color: AppColors.greenSuccess,
            ),
            SizedBox(width: 6.0),
            Flexible(
              child: Text(
                'Encrypted & Secure Public Health Interface',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        const Text(
          'v1.0.0',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 10.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
