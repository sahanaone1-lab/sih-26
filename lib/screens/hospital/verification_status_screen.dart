import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/hospital_model.dart';
import '../../widgets/ayush_widgets.dart';
import 'ayush_dashboard_screen.dart';
import 'hospital_registration_screen.dart';

/// VerificationStatusScreen for AYUSH Hospital Portal.
///
/// Shows hospital verification status (Pending / Verified / Rejected),
/// application details, submitted date, and status message.
/// Restricts access to the main dashboard while pending/rejected.
class VerificationStatusScreen extends StatefulWidget {
  final AyushHospital hospital;

  const VerificationStatusScreen({super.key, required this.hospital});

  @override
  State<VerificationStatusScreen> createState() =>
      _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends State<VerificationStatusScreen> {
  late VerificationStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.hospital.verificationStatus;
  }

  @override
  Widget build(BuildContext context) {
    final isVerified = _currentStatus == VerificationStatus.verified;
    final isRejected = _currentStatus == VerificationStatus.rejected;

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
            constraints: const BoxConstraints(maxWidth: 620),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Header Emblem
                  Center(
                    child: Container(
                      width: 96.0,
                      height: 96.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentStatus.backgroundColor,
                      ),
                      child: Center(
                        child: Icon(
                          _currentStatus.icon,
                          size: 52.0,
                          color: _currentStatus.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Hospital Name & Status Badge
                  Text(
                    widget.hospital.hospitalName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.navyPrimary,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10.0),

                  Center(child: StatusBadge(status: _currentStatus)),
                  const SizedBox(height: 24.0),

                  // Application Details Card
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
                          'Verification Application Details',
                          style: TextStyle(
                            color: AppColors.navyPrimary,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 14.0),
                        const Divider(
                          color: AppColors.surfaceBorder,
                          height: 1.0,
                        ),
                        const SizedBox(height: 14.0),
                        _buildDetailRow(
                          Icons.confirmation_number_outlined,
                          'Application ID',
                          widget.hospital.applicationId,
                        ),
                        const SizedBox(height: 12.0),
                        _buildDetailRow(
                          Icons.verified_outlined,
                          'AYUSH / FIR ID',
                          widget.hospital.ayushId,
                        ),
                        const SizedBox(height: 12.0),
                        _buildDetailRow(
                          Icons.badge_outlined,
                          'Registration No.',
                          widget.hospital.regNumber,
                        ),
                        const SizedBox(height: 12.0),
                        _buildDetailRow(
                          Icons.calendar_today_outlined,
                          'Submitted Date',
                          widget.hospital.submittedDate,
                        ),
                        const SizedBox(height: 12.0),
                        _buildDetailRow(
                          Icons.domain_rounded,
                          'Facility Type',
                          widget.hospital.hospitalType,
                        ),
                        const SizedBox(height: 12.0),
                        _buildDetailRow(
                          Icons.person_outline_rounded,
                          'Authorized Person',
                          widget.hospital.authorizedPersonName,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Verification Status Message Banner
                  Container(
                    padding: const EdgeInsets.all(18.0),
                    decoration: BoxDecoration(
                      color: _currentStatus.backgroundColor,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: _currentStatus.color.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _currentStatus.icon,
                              color: _currentStatus.color,
                              size: 22.0,
                            ),
                            const SizedBox(width: 10.0),
                            Flexible(
                              child: Text(
                                _getStatusHeadline(),
                                style: TextStyle(
                                  color: _currentStatus.color,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          _getStatusMessage(),
                          style: const TextStyle(
                            color: AppColors.navyPrimary,
                            fontSize: 13.0,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28.0),

                  // Action Buttons & Access Restriction Logic
                  if (isVerified) ...[
                    // VERIFIED: Can proceed to Main Dashboard
                    SizedBox(
                      height: 54.0,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AyushDashboardScreen(
                                hospital: widget.hospital,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.dashboard_rounded, size: 22.0),
                        label: const Text(
                          'Go to AYUSH Hospital Dashboard',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greenSuccess,
                          foregroundColor: AppColors.background,
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // PENDING or REJECTED: Main Dashboard access is restricted!
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.lock_rounded,
                            color: AppColors.textSecondary,
                            size: 20.0,
                          ),
                          SizedBox(width: 12.0),
                          Expanded(
                            child: Text(
                              'Hospital Dashboard access is locked while verification is pending.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Re-checked status: Verification process is active with AYUSH regulatory authority.',
                                  ),
                                  backgroundColor: AppColors.navyPrimary,
                                ),
                              );
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 18.0),
                            label: const Text('Refresh Status'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.navyPrimary,
                              side: const BorderSide(
                                color: AppColors.navyPrimary,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                        ),
                        if (isRejected) ...[
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const HospitalRegistrationScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.edit_note_rounded,
                                size: 18.0,
                              ),
                              label: const Text('Re-register'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.saffronPrimary,
                                foregroundColor: AppColors.background,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  const SizedBox(height: 20.0),

                  // Back to Login link
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Return to Portal Home',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusHeadline() {
    switch (_currentStatus) {
      case VerificationStatus.pending:
        return 'Verification Pending';
      case VerificationStatus.under_review:
        return 'Application Under Review';
      case VerificationStatus.verified:
        return 'Account Verified & Active';
      case VerificationStatus.rejected:
        return 'Registration Requires Revision';
    }
  }

  String _getStatusMessage() {
    switch (_currentStatus) {
      case VerificationStatus.pending:
        return 'Your hospital details and uploaded AYUSH certificates have been received. State regulatory verification typically takes 24–48 hours. Once verified, full dashboard access will be unlocked.';
      case VerificationStatus.under_review:
        return 'A verification officer is currently reviewing your uploaded AYUSH certificates and accreditation credentials. You will be notified once a decision is made.';
      case VerificationStatus.verified:
        return 'Congratulations! Your AYUSH hospital accreditation and credentials have been verified by the regulatory authority. You can now access your MediKiosk intake dashboard.';
      case VerificationStatus.rejected:
        return 'The submitted hospital registration certificate or AYUSH ID could not be validated against official registries. Please re-check your details and re-submit.';
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
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
