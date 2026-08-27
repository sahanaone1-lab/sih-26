import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/patient_model.dart';
import '../../widgets/ayush_widgets.dart';
import 'clinical_history_summary_screen.dart';
import 'medical_history_timeline_screen.dart';
import 'scan_medical_documents_screen.dart';
import 'voice_to_text_history_screen.dart';

/// Patient Dashboard Screen — shown after successful ABHA + OTP verification.
///
/// Focuses exclusively on the AI-powered clinical intake workflow:
/// 1. Talk (AI Health Conversation)
/// 2. Voice/Text (Voice-to-Text Clinical History)
/// 3. Scan (OCR Medical Documents)
/// 4. Timeline (Medical History Timeline)
/// 5. Summary (AI Clinical History Summary)
class PatientDashboardScreen extends StatelessWidget {
  final PatientModel patient;

  const PatientDashboardScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 1,
        shadowColor: AppColors.cardShadow,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.navyPrimary, size: 20.0),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const AyushHeaderLogo(iconSize: 20.0, fontSize: 16.0),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.saffronDark),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Patient Identity Card ─────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.greenSuccess, Color(0xFF035C30)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
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
                    // Patient greeting row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: const Icon(Icons.person_rounded,
                              color: Colors.white, size: 28.0),
                        ),
                        const SizedBox(width: 14.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WELCOME, ${patient.firstName.toUpperCase()}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                patient.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        // Verified badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified_rounded,
                                  color: Colors.white, size: 14.0),
                              SizedBox(width: 4.0),
                              Text('ABDM Verified',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18.0),
                    const Divider(color: Colors.white24, height: 1.0),
                    const SizedBox(height: 16.0),

                    // Patient detail rows (2-column grid)
                    Wrap(
                      spacing: 24.0,
                      runSpacing: 12.0,
                      children: [
                        _patientDetailChip(
                            Icons.badge_rounded, 'ABHA ID', patient.abhaId),
                        _patientDetailChip(Icons.cake_rounded, 'Date of Birth',
                            patient.dateOfBirth),
                        _patientDetailChip(Icons.person_outline_rounded,
                            'Gender', patient.gender),
                        _patientDetailChip(Icons.bloodtype_rounded,
                            'Blood Group', patient.bloodGroup),
                        _patientDetailChip(Icons.phone_rounded, 'Mobile',
                            patient.maskedMobile),
                        _patientDetailChip(Icons.place_rounded, 'Location',
                            '${patient.district}, ${patient.state}'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22.0),

              // ── Clinical Intake Journey Progress / Status Bar ─────────────
              _buildIntakeProgressBar(context),
              const SizedBox(height: 24.0),

              // ── AI Clinical Intake Feature Cards ──────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'AI Clinical Intake',
                    style: TextStyle(
                      color: AppColors.navyPrimary,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '5 Steps',
                    style: TextStyle(
                      color: AppColors.greenSuccess,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14.0),

              // 1. AI Health Conversation
              DashboardActionCard(
                title: '1. AI Health Conversation',
                description:
                    'Interact with the AI assistant naturally via Voice or Text to capture your clinical history.',
                icon: Icons.smart_toy_rounded,
                iconColor: AppColors.greenSuccess,
                iconBgColor: AppColors.greenLight,
                badgeText: 'CONVERSATION',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          VoiceToTextHistoryScreen(patient: patient),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12.0),

              // 2. Voice-to-Text Clinical History
              DashboardActionCard(
                title: '2. Voice-to-Text Clinical History',
                description:
                    'Describe your health problem by speaking in your preferred language with editable transcription.',
                icon: Icons.mic_rounded,
                iconColor: AppColors.saffronDark,
                iconBgColor: AppColors.saffronLight,
                badgeText: 'VOICE INTAKE',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          VoiceToTextHistoryScreen(patient: patient),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12.0),

              // 3. Scan Medical Documents
              DashboardActionCard(
                title: '3. Scan Medical Documents',
                description:
                    'Scan or upload previous prescriptions, lab reports, and discharge summaries for OCR extraction.',
                icon: Icons.document_scanner_rounded,
                iconColor: const Color(0xFF1E3A8A),
                iconBgColor: const Color(0xFFEFF6FF),
                badgeText: 'AI OCR SCAN',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ScanMedicalDocumentsScreen(patient: patient),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12.0),

              // 4. Medical History Timeline
              DashboardActionCard(
                title: '4. Medical History Timeline',
                description:
                    'View organized chronological medical history from AI chats, voice notes, and scanned documents.',
                icon: Icons.timeline_rounded,
                iconColor: const Color(0xFF7C3AED),
                iconBgColor: const Color(0xFFF5F3FF),
                badgeText: 'TIMELINE',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          MedicalHistoryTimelineScreen(patient: patient),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12.0),

              // 5. AI Clinical History Summary
              DashboardActionCard(
                title: '5. AI Clinical History Summary',
                description:
                    'Preview your structured 9-section clinical summary before your AYUSH consultation.',
                icon: Icons.assignment_rounded,
                iconColor: AppColors.navyPrimary,
                iconBgColor: AppColors.surfaceBorder,
                badgeText: 'SUMMARY REPORT',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ClinicalHistorySummaryScreen(patient: patient),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24.0),

              // ── ABDM Compliance Banner ────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                      color: AppColors.greenSuccess.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.shield_rounded,
                        color: AppColors.greenSuccess, size: 24.0),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ABDM & FHIR Compliant Intake',
                            style: TextStyle(
                                color: AppColors.greenSuccess,
                                fontWeight: FontWeight.w800,
                                fontSize: 13.0),
                          ),
                          SizedBox(height: 2.0),
                          Text(
                            'Your clinical intake data is structured into FHIR clinical resources and shared securely with your doctor.',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11.5,
                                height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  // ── Intake Progress / Status Bar ─────────────────────────────────────────────

  Widget _buildIntakeProgressBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Clinical Intake Journey',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navyPrimary,
                ),
              ),
              Text(
                'Pre-Consultation',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.saffronDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _progressStep(
                  context,
                  stepNumber: '1',
                  label: 'Talk',
                  isActive: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          VoiceToTextHistoryScreen(patient: patient),
                    ),
                  ),
                ),
                _progressArrow(),
                _progressStep(
                  context,
                  stepNumber: '2',
                  label: 'Voice/Text',
                  isActive: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          VoiceToTextHistoryScreen(patient: patient),
                    ),
                  ),
                ),
                _progressArrow(),
                _progressStep(
                  context,
                  stepNumber: '3',
                  label: 'Scan',
                  isActive: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ScanMedicalDocumentsScreen(patient: patient),
                    ),
                  ),
                ),
                _progressArrow(),
                _progressStep(
                  context,
                  stepNumber: '4',
                  label: 'Timeline',
                  isActive: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          MedicalHistoryTimelineScreen(patient: patient),
                    ),
                  ),
                ),
                _progressArrow(),
                _progressStep(
                  context,
                  stepNumber: '5',
                  label: 'Summary',
                  isActive: true,
                  isLast: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ClinicalHistorySummaryScreen(patient: patient),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressStep(
    BuildContext context, {
    required String stepNumber,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22.0,
              height: 22.0,
              decoration: BoxDecoration(
                color: isLast
                    ? AppColors.saffronPrimary
                    : AppColors.greenSuccess,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  stepNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isLast ? AppColors.saffronDark : AppColors.navyPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressArrow() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.0),
      child: Icon(Icons.arrow_forward_ios_rounded,
          size: 10.0, color: AppColors.textMuted),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _patientDetailChip(IconData icon, String label, String value) {
    return SizedBox(
      width: 160.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13.0, color: Colors.white54),
              const SizedBox(width: 4.0),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3)),
            ],
          ),
          const SizedBox(height: 3.0),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text(
            'Are you sure you want to log out of the Patient Portal?'),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenSuccess,
                foregroundColor: Colors.white),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
