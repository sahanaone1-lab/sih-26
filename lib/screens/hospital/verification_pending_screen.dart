import 'package:flutter/material.dart';
import '../../app/theme.dart';

/// VerificationPendingScreen for MediKiosk.
/// 
/// Displayed after a hospital submits their registration details.
/// Provides a clear reference ID, verification status timeline, 
/// and registration details summary.
class VerificationPendingScreen extends StatelessWidget {
  final String hospitalName;
  final String hospitalType;
  final String adminEmail;

  const VerificationPendingScreen({
    super.key,
    required this.hospitalName,
    required this.hospitalType,
    required this.adminEmail,
  });

  @override
  Widget build(BuildContext context) {
    const referenceId = 'MK-2026-89412';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.local_hospital_rounded,
              color: AppColors.saffronPrimary,
              size: 24.0,
            ),
            SizedBox(width: 8.0),
            Text(
              'MediKiosk',
              style: TextStyle(
                color: AppColors.navyPrimary,
                fontSize: 20.0,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
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
                  // Verification Pending Icon Emblem
                  Center(
                    child: Container(
                      width: 96.0,
                      height: 96.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.saffronLight,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.pending_actions_rounded,
                          size: 52.0,
                          color: AppColors.saffronPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Headline & Status Text
                  const Text(
                    'Registration Submitted',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.navyPrimary,
                      fontSize: 26.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Verification Pending',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.saffronDark,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  const Text(
                    'Your hospital onboarding application for MediKiosk has been submitted successfully and is currently under official verification.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.0,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28.0),

                  // Reference Tracking Card
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'REGISTRATION REFERENCE ID',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SelectableText(
                              referenceId,
                              style: const TextStyle(
                                color: AppColors.navyPrimary,
                                fontSize: 22.0,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 18.0, color: AppColors.navyPrimary),
                              tooltip: 'Copy Reference ID',
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Reference ID copied to clipboard.'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28.0),

                  // Registration Details Summary Card
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: AppColors.surfaceBorder),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 16.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hospital Registration Summary',
                          style: TextStyle(
                            color: AppColors.navyPrimary,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14.0),
                        const Divider(color: AppColors.surfaceBorder, height: 1.0),
                        const SizedBox(height: 14.0),

                        _buildSummaryRow(
                          icon: Icons.local_hospital_outlined,
                          label: 'Hospital Name',
                          value: hospitalName,
                        ),
                        const SizedBox(height: 12.0),
                        _buildSummaryRow(
                          icon: Icons.domain_rounded,
                          label: 'Hospital Type',
                          value: hospitalType,
                        ),
                        const SizedBox(height: 12.0),
                        _buildSummaryRow(
                          icon: Icons.email_outlined,
                          label: 'Administrator Email',
                          value: adminEmail.isEmpty ? 'admin@hospital.org' : adminEmail,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28.0),

                  // Verification Timeline Steps
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Verification Timeline',
                          style: TextStyle(
                            color: AppColors.navyPrimary,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        _buildTimelineStep(
                          stepNumber: '1',
                          title: 'Hospital Registration Submitted',
                          subtitle: 'Details & documents received',
                          isCompleted: true,
                          isInProgress: false,
                        ),
                        const SizedBox(height: 14.0),
                        _buildTimelineStep(
                          stepNumber: '2',
                          title: 'Regulatory & HFR Verification',
                          subtitle: 'Document verification in progress (Estimated 24-48 hrs)',
                          isCompleted: false,
                          isInProgress: true,
                        ),
                        const SizedBox(height: 14.0),
                        _buildTimelineStep(
                          stepNumber: '3',
                          title: 'MediKiosk Portal Credentials Issued',
                          subtitle: 'Login access will be dispatched to administrator email',
                          isCompleted: false,
                          isInProgress: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32.0),

                  // Refresh / Check Status Button
                  SizedBox(
                    height: 52.0,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Status checked: Registration verification is in progress.'),
                            backgroundColor: AppColors.navyPrimary,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navyPrimary,
                        foregroundColor: AppColors.background,
                        elevation: 1.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        'Check Verification Status',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14.0),

                  // Public Health Support Note
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.verified_rounded,
                        size: 16.0,
                        color: AppColors.greenSuccess,
                      ),
                      SizedBox(width: 6.0),
                      Flexible(
                        child: Text(
                          'Official MediKiosk Public Health Onboarding Portal',
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

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18.0, color: AppColors.textSecondary),
        const SizedBox(width: 10.0),
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
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String stepNumber,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isInProgress,
  }) {
    Color iconBgColor = AppColors.surfaceBorder;
    Color iconColor = AppColors.textMuted;

    if (isCompleted) {
      iconBgColor = AppColors.greenLight;
      iconColor = AppColors.greenSuccess;
    } else if (isInProgress) {
      iconBgColor = AppColors.saffronLight;
      iconColor = AppColors.saffronPrimary;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32.0,
          height: 32.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconBgColor,
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check_rounded, size: 18.0, color: iconColor)
                : Text(
                    stepNumber,
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.0,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 14.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.navyPrimary,
                  fontWeight: isInProgress || isCompleted ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
