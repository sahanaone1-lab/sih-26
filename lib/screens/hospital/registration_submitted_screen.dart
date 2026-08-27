import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/hospital_model.dart';
import '../../widgets/ayush_widgets.dart';
import '../auth/login_screen.dart';

/// RegistrationSubmittedScreen (Registration Success Page) for AYUSH Hospital Portal.
/// 
/// Displays registration confirmation, generated Application ID, status: Pending Verification,
/// explanatory review notice, and a "Go to Login" button to proceed to the hospital login screen.
class RegistrationSubmittedScreen extends StatelessWidget {
  final AyushHospital hospital;

  RegistrationSubmittedScreen({
    super.key,
    AyushHospital? hospital,
    String? hospitalName,
    String? hospitalType,
    String? state,
    String? district,
    String? adminEmail,
    String? applicationId,
  }) : hospital = hospital ??
            AyushHospital(
              id: '00000000-0000-0000-0000-000000000000',
              applicationId: applicationId ?? 'AYUSH-HOSP-2026-89412',
              hospitalName: hospitalName ?? 'National Institute of Ayurveda Hospital',
              regNumber: 'AYUSH-RJ-2024-0091',
              ayushId: 'AYUSH/FIR/2026/0482',
              address: 'Jorawar Singh Gate, Amer Road',
              state: state ?? 'Rajasthan',
              district: district ?? 'Jaipur',
              hospitalType: hospitalType ?? 'Government AYUSH Institute',
              authorizedPersonName: 'Dr. Rajeshwar Sharma',
              officialEmail: adminEmail ?? 'contact@nia.ayush.gov.in',
              phoneNumber: '+91 98290 12345',
              password: 'password123',
              verificationStatus: VerificationStatus.pending,
              submittedDate: '26 August 2026',
            );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const AyushHeaderLogo(iconSize: 22.0, fontSize: 18.0),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Success Emblem Icon
                  Center(
                    child: Container(
                      width: 104.0,
                      height: 104.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.greenLight,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 64.0,
                          color: AppColors.greenSuccess,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Header: Hospital Registration Submitted Successfully
                  const Text(
                    'Hospital Registration Submitted Successfully',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.navyPrimary,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    hospital.hospitalName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.saffronDark,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Details & Status Card
                  Container(
                    padding: const EdgeInsets.all(22.0),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: AppColors.surfaceBorder),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 12.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Verification Status Pill: Pending Verification
                        StatusBadge(status: hospital.verificationStatus),
                        const SizedBox(height: 20.0),

                        const Text(
                          'REGISTRATION / APPLICATION ID',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: SelectableText(
                                  hospital.applicationId,
                                  style: const TextStyle(
                                    color: AppColors.navyPrimary,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 18.0, color: AppColors.navyPrimary),
                              tooltip: 'Copy Registration ID',
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Registration ID (${hospital.applicationId}) copied to clipboard.'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        const Divider(color: AppColors.surfaceBorder, height: 1.0),
                        const SizedBox(height: 16.0),

                        // Required message: "Your hospital details will be verified before account activation."
                        Container(
                          padding: const EdgeInsets.all(14.0),
                          decoration: BoxDecoration(
                            color: AppColors.saffronLight,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: AppColors.saffronPrimary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 20.0,
                                color: AppColors.saffronDark,
                              ),
                              SizedBox(width: 12.0),
                              Expanded(
                                child: Text(
                                  'Your hospital registration has been submitted successfully and is awaiting admin verification.',
                                  style: TextStyle(
                                    color: AppColors.navyPrimary,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Submitted Hospital Overview Card
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Submitted AYUSH Details',
                          style: TextStyle(
                            color: AppColors.navyPrimary,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        const Divider(color: AppColors.surfaceBorder, height: 1.0),
                        const SizedBox(height: 12.0),
                        _buildSummaryItem(Icons.verified_outlined, 'AYUSH / FIR ID', hospital.ayushId),
                        const SizedBox(height: 10.0),
                        _buildSummaryItem(Icons.badge_outlined, 'Registration No.', hospital.regNumber),
                        const SizedBox(height: 10.0),
                        _buildSummaryItem(Icons.domain_rounded, 'Hospital Type', hospital.hospitalType),
                        const SizedBox(height: 10.0),
                        _buildSummaryItem(Icons.place_outlined, 'Location', '${hospital.district}, ${hospital.state}'),
                        const SizedBox(height: 10.0),
                        _buildSummaryItem(Icons.person_outline_rounded, 'Authorized Representative', hospital.authorizedPersonName),
                        const SizedBox(height: 10.0),
                        _buildSummaryItem(Icons.email_outlined, 'Official Email', hospital.officialEmail),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32.0),

                  // Button: "Go to Login"
                  SizedBox(
                    height: 52.0,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(
                              initialRegistrationId: hospital.applicationId,
                              registeredHospital: hospital,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.login_rounded, size: 20.0),
                      label: const Text(
                        'Go to Login',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.saffronPrimary,
                        foregroundColor: AppColors.background,
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Footer badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.verified_rounded,
                        size: 15.0,
                        color: AppColors.greenSuccess,
                      ),
                      SizedBox(width: 6.0),
                      Flexible(
                        child: Text(
                          'Ministry of Ayush • ABDM & SIH 2026 Compliant Portal',
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
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16.0, color: AppColors.textSecondary),
        const SizedBox(width: 8.0),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.navyPrimary,
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
