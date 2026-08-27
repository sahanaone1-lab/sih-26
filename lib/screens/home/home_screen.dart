import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../widgets/ayush_widgets.dart';
import '../admin/admin_login_screen.dart';
import '../auth/login_screen.dart';
import '../hospital/hospital_registration_screen.dart';
import '../patient/patient_intake_screen.dart';

/// Platform Homepage for MediKiosk.
/// Provides unified role-based access for Patients, Doctors & Hospitals, and Admins.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, isDesktop),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Hero Section
            _buildHeroSection(context, isDesktop),

            // Statistics Ribbon
            _buildMetricsRibbon(context, isDesktop),

            const SizedBox(height: 32.0),

            // Role Selection Section (Patient, Doctor/Hospital, Admin)
            _buildRoleSelectionSection(context, isDesktop),

            const SizedBox(height: 48.0),

            // AYUSH Systems Section
            _buildAyushSystemsSection(context, isDesktop),

            const SizedBox(height: 60.0),

            // Security & Initiative Footer
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDesktop) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleSpacing: isDesktop ? 32.0 : 16.0,
      title: const AyushHeaderLogo(
        titlePrefix: 'MEDIKIOSK ',
        titleSuffix: 'AYUSH PLATFORM',
      ),
      actions: [
        // Quick Portal Access Dropdown / Button
        Padding(
          padding: EdgeInsets.only(right: isDesktop ? 32.0 : 12.0),
          child: ElevatedButton.icon(
            onPressed: () => _showPortalSelectorModal(context),
            icon: const Icon(Icons.login_rounded, size: 16.0),
            label: const Text('Sign In / Portals', style: TextStyle(fontSize: 12.0)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.saffronPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64.0 : 20.0, vertical: isDesktop ? 56.0 : 36.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              // Tricolor National Health Indicator Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(color: AppColors.saffronPrimary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 8.0, height: 8.0, decoration: const BoxDecoration(color: AppColors.saffronPrimary, shape: BoxShape.circle)),
                    const SizedBox(width: 4.0),
                    Container(width: 8.0, height: 8.0, decoration: const BoxDecoration(color: AppColors.surfaceBorder, shape: BoxShape.circle)),
                    const SizedBox(width: 4.0),
                    Container(width: 8.0, height: 8.0, decoration: const BoxDecoration(color: AppColors.greenSuccess, shape: BoxShape.circle)),
                    const SizedBox(width: 10.0),
                    const Text(
                      'SMART INDIA HACKATHON 2026 • MINISTRY OF AYUSH',
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.navyPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // Main Headline
              Text(
                'Smart Public Health & AYUSH Hospital Ecosystem',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 36.0 : 24.0,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navyPrimary,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 16.0),

              // Subtitle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Text(
                  'Unified digital infrastructure connecting Patients, Doctors, Registered AYUSH Facilities, and Regulatory Verification Authorities across India.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isDesktop ? 15.0 : 13.0,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsRibbon(BuildContext context, bool isDesktop) {
    final metrics = [
      {'val': '75,000+', 'label': 'Kiosk Patient Check-ins'},
      {'val': '1,200+', 'label': 'Verified AYUSH Hospitals'},
      {'val': '6 Systems', 'label': 'Ayurveda, Yoga, Unani, Siddha...'},
      {'val': '100% NABH', 'label': 'Regulatory Compliant'},
    ];

    return Container(
      width: double.infinity,
      color: AppColors.navyPrimary,
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: isDesktop
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: metrics.map((m) => _buildMetricItem(m['val']!, m['label']!)).toList(),
                )
              : Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 24.0,
                  runSpacing: 16.0,
                  children: metrics.map((m) => _buildMetricItem(m['val']!, m['label']!)).toList(),
                ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(String val, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          val,
          style: const TextStyle(color: AppColors.saffronPrimary, fontSize: 20.0, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 2.0),
        Text(
          label,
          style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11.0, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildRoleSelectionSection(BuildContext context, bool isDesktop) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Your Portal',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navyPrimary,
                ),
              ),
              const SizedBox(height: 6.0),
              const Text(
                'Select your role to access tailored OPD tools, healthcare consoles, or verification dashboards.',
                style: TextStyle(fontSize: 13.0, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24.0),

              // 3 Role Cards (Patient, Doctor/Hospital, Admin)
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildPatientRoleCard(context)),
                        const SizedBox(width: 20.0),
                        Expanded(child: _buildHospitalRoleCard(context)),
                        const SizedBox(width: 20.0),
                        Expanded(child: _buildAdminRoleCard(context)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildPatientRoleCard(context),
                        const SizedBox(height: 16.0),
                        _buildHospitalRoleCard(context),
                        const SizedBox(height: 16.0),
                        _buildAdminRoleCard(context),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientRoleCard(BuildContext context) {
    return _buildPortalCard(
      context: context,
      badgeText: 'PATIENT ACCESS',
      badgeColor: AppColors.greenSuccess,
      badgeBgColor: AppColors.greenLight,
      icon: Icons.people_alt_rounded,
      iconColor: AppColors.greenSuccess,
      title: 'Patient Portal',
      description: 'Securely access the Patient Portal using your ABHA ID. View your health records, appointments, and more.',
      primaryButtonText: 'Patient Login',
      primaryButtonIcon: Icons.badge_rounded,
      primaryButtonColor: AppColors.greenSuccess,
      onPrimaryTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const PatientIntakeScreen()),
        );
      },
    );
  }

  Widget _buildHospitalRoleCard(BuildContext context) {
    return _buildPortalCard(
      context: context,
      badgeText: 'HOSPITAL / DOCTOR',
      badgeColor: AppColors.saffronDark,
      badgeBgColor: AppColors.saffronLight,
      icon: Icons.local_hospital_rounded,
      iconColor: AppColors.saffronPrimary,
      title: 'Doctor & Hospital Portal',
      description: 'Hospital onboarding, accreditation tracker, doctor OPD consultation console, and facility management.',
      primaryButtonText: 'Hospital Login',
      primaryButtonIcon: Icons.login_rounded,
      primaryButtonColor: AppColors.saffronPrimary,
      onPrimaryTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },
      secondaryButtonText: 'Register New Facility',
      onSecondaryTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const HospitalRegistrationScreen()),
        );
      },
    );
  }

  Widget _buildAdminRoleCard(BuildContext context) {
    return _buildPortalCard(
      context: context,
      badgeText: 'REGULATORY / ADMIN',
      badgeColor: const Color(0xFF3B82F6),
      badgeBgColor: const Color(0xFFEFF6FF),
      icon: Icons.admin_panel_settings_rounded,
      iconColor: const Color(0xFF2563EB),
      title: 'Admin Verification Portal',
      description: 'Official Ministry console for hospital verification, HFR/NABH ID checks, and audit history logging.',
      primaryButtonText: 'Admin Login 🔒',
      primaryButtonIcon: Icons.lock_open_rounded,
      primaryButtonColor: AppColors.navyPrimary,
      onPrimaryTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
        );
      },
    );
  }

  Widget _buildPortalCard({
    required BuildContext context,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBgColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String primaryButtonText,
    required IconData primaryButtonIcon,
    required Color primaryButtonColor,
    required VoidCallback onPrimaryTap,
    String? secondaryButtonText,
    VoidCallback? onSecondaryTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16.0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: Icon(icon, color: iconColor, size: 28.0),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(color: badgeColor, fontSize: 10.0, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w800,
              color: AppColors.navyPrimary,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPrimaryTap,
              icon: Icon(primaryButtonIcon, size: 16.0),
              label: Text(primaryButtonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryButtonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ),
          if (secondaryButtonText != null) ...[
            const SizedBox(height: 8.0),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onSecondaryTap,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: Text(secondaryButtonText, style: const TextStyle(fontSize: 12.0)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAyushSystemsSection(BuildContext context, bool isDesktop) {
    final systems = [
      {'name': 'Ayurveda', 'desc': 'Holistic healing & herbal science', 'icon': Icons.spa_rounded},
      {'name': 'Yoga & Naturopathy', 'desc': 'Mind-body balance & natural therapy', 'icon': Icons.self_improvement_rounded},
      {'name': 'Unani', 'desc': 'Greco-Arabic evidence clinical care', 'icon': Icons.local_florist_rounded},
      {'name': 'Siddha', 'desc': 'Ancient Tamil traditional therapeutics', 'icon': Icons.healing_rounded},
      {'name': 'Sowa-Rigpa', 'desc': 'Traditional Himalayan medicine', 'icon': Icons.terrain_rounded},
      {'name': 'Homoeopathy', 'desc': 'Individualized holistic remedy', 'icon': Icons.science_rounded},
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Supported AYUSH Medical Disciplines',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navyPrimary,
                ),
              ),
              const SizedBox(height: 6.0),
              const Text(
                'Comprehensive support for the 6 national streams recognized by the Ministry of Ayush.',
                style: TextStyle(fontSize: 13.0, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20.0),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 550 ? 2 : 1);
                  return GridView.count(
                    crossAxisCount: crossCount,
                    crossAxisSpacing: 14.0,
                    mainAxisSpacing: 14.0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: crossCount == 1 ? 3.0 : 2.0,
                    children: systems.map((sys) {
                      return Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: AppColors.saffronLight,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Icon(sys['icon'] as IconData, color: AppColors.saffronDark, size: 22.0),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    sys['name'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14.0,
                                      color: AppColors.navyPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    sys['desc'] as String,
                                    style: const TextStyle(
                                      fontSize: 11.0,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
      decoration: const BoxDecoration(
        color: AppColors.navyDark,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.shield_rounded, color: AppColors.greenSuccess, size: 16.0),
              SizedBox(width: 8.0),
              Text(
                'Ayushman Bharat Digital Mission (ABDM) & HFR Compatible',
                style: TextStyle(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          const Text(
            'MediKiosk • Smart AYUSH Health & Hospital Management Platform',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.0),
          ),
          const SizedBox(height: 4.0),
          const Text(
            'Smart India Hackathon (SIH 2026) Initiative',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 10.0),
          ),
        ],
      ),
    );
  }

  void _showPortalSelectorModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select Portal to Access', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16.0),
                ListTile(
                  leading: const Icon(Icons.people_alt_rounded, color: AppColors.greenSuccess),
                  title: const Text('Patient Portal'),
                  subtitle: const Text('Login with ABHA ID'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PatientIntakeScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.local_hospital_rounded, color: AppColors.saffronDark),
                  title: const Text('Hospital & Doctor Login'),
                  subtitle: const Text('Facility portal & consultation dashboard'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.navyPrimary),
                  title: const Text('Admin Verification Portal 🔒'),
                  subtitle: const Text('Regulatory officer credentials login'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdminLoginScreen()));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
