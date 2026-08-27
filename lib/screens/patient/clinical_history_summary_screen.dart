import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/clinical_intake_model.dart';
import '../../models/patient_model.dart';
import '../../services/clinical_intake_service.dart';

/// Screen 5: AI Clinical History Summary
///
/// Generates and renders a comprehensive 9-section structured clinical summary:
/// 1. Chief Complaint
/// 2. History of Present Illness (HPI)
/// 3. Past Medical History
/// 4. Past Surgical History
/// 5. Current Medications
/// 6. Allergies
/// 7. Family History
/// 8. Personal History (Diet, Sleep, AYUSH Prakriti)
/// 9. Previous Investigations
///
/// Serves as the patient-side preview before submitting information for AYUSH consultation.
class ClinicalHistorySummaryScreen extends StatefulWidget {
  final PatientModel patient;

  const ClinicalHistorySummaryScreen({super.key, required this.patient});

  @override
  State<ClinicalHistorySummaryScreen> createState() =>
      _ClinicalHistorySummaryScreenState();
}

class _ClinicalHistorySummaryScreenState
    extends State<ClinicalHistorySummaryScreen> {
  final _service = ClinicalIntakeService.instance;
  late ClinicalHistorySummary _summary;

  @override
  void initState() {
    super.initState();
    _summary = _service.generateClinicalSummary(widget.patient);
  }

  void _handleSubmitForConsultation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.verified_rounded,
                color: AppColors.greenSuccess, size: 24.0),
            SizedBox(width: 8.0),
            Expanded(
              child: Text(
                'Submit Clinical Intake?',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navyPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your structured clinical history summary and OCR-digitized documents will be made securely available to the attending AYUSH Doctor at consultation time under your ABHA consent (${widget.patient.abhaId}).',
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12.0),
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_rounded,
                      size: 14.0, color: AppColors.greenSuccess),
                  SizedBox(width: 6.0),
                  Expanded(
                    child: Text(
                      'FHIR & ABDM Compliant Data Exchange',
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greenSuccess,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Review Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Clinical Intake successfully submitted! Ready for AYUSH Doctor Consultation.',
                  ),
                  backgroundColor: AppColors.greenSuccess,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greenSuccess,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm & Send'),
          ),
        ],
      ),
    );
  }

  void _exportSummary() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exported FHIR Intake Bundle (JSON & PDF Summary generated).'),
        backgroundColor: AppColors.navyPrimary,
        duration: Duration(seconds: 2),
      ),
    );
  }

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
        title: const Text(
          'AI Clinical History Summary',
          style: TextStyle(
            color: AppColors.navyPrimary,
            fontSize: 16.0,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Export FHIR/PDF Summary',
            icon: const Icon(Icons.file_download_outlined,
                color: AppColors.navyPrimary),
            onPressed: _exportSummary,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.navyPrimary, Color(0xFF041E42)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18.0),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 14.0,
                      offset: Offset(0, 4),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: AppColors.saffronPrimary,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: const Text(
                            'AI PRE-CONSULTATION SUMMARY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        Text(
                          'ABHA: ${widget.patient.abhaId}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      widget.patient.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '${widget.patient.age} yrs • ${widget.patient.gender} • Blood Group: ${widget.patient.bloodGroup}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),

              // AI Clinical Impression
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                      color: AppColors.greenSuccess.withValues(alpha: 0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        color: AppColors.greenSuccess, size: 22.0),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Clinical Impression',
                            style: TextStyle(
                              color: AppColors.greenSuccess,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            _summary.aiClinicalImpression,
                            style: const TextStyle(
                              color: AppColors.navyPrimary,
                              fontSize: 12.0,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),

              // ── 9 Structured Clinical Sections ────────────────────────────

              // 1. Chief Complaint
              _buildSectionCard(
                sectionNumber: '1',
                title: 'Chief Complaint',
                icon: Icons.priority_high_rounded,
                iconColor: const Color(0xFFDC2626),
                child: Text(
                  _summary.chiefComplaint,
                  style: const TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navyPrimary,
                    height: 1.4,
                  ),
                ),
              ),

              // 2. History of Present Illness (HPI)
              _buildSectionCard(
                sectionNumber: '2',
                title: 'History of Present Illness (HPI)',
                icon: Icons.history_edu_rounded,
                iconColor: AppColors.saffronDark,
                child: Text(
                  _summary.historyOfPresentIllness,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),

              // 3. Past Medical History
              _buildSectionCard(
                sectionNumber: '3',
                title: 'Past Medical History',
                icon: Icons.medical_services_rounded,
                iconColor: AppColors.navyLight,
                child: _buildBulletList(_summary.pastMedicalHistory),
              ),

              // 4. Past Surgical History
              _buildSectionCard(
                sectionNumber: '4',
                title: 'Past Surgical History',
                icon: Icons.healing_rounded,
                iconColor: const Color(0xFF7C3AED),
                child: _buildBulletList(_summary.pastSurgicalHistory),
              ),

              // 5. Medications
              _buildSectionCard(
                sectionNumber: '5',
                title: 'Current Medications',
                icon: Icons.medication_rounded,
                iconColor: AppColors.saffronDark,
                child: _buildBulletList(_summary.currentMedications),
              ),

              // 6. Allergies
              _buildSectionCard(
                sectionNumber: '6',
                title: 'Allergies & Adverse Reactions',
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFDC2626),
                child: _buildBulletList(_summary.allergies),
              ),

              // 7. Family History
              _buildSectionCard(
                sectionNumber: '7',
                title: 'Family History',
                icon: Icons.family_restroom_rounded,
                iconColor: const Color(0xFF0284C7),
                child: _buildBulletList(_summary.familyHistory),
              ),

              // 8. Personal History & AYUSH Prakriti
              _buildSectionCard(
                sectionNumber: '8',
                title: 'Personal History & AYUSH Lifestyle',
                icon: Icons.spa_rounded,
                iconColor: AppColors.greenSuccess,
                child: Column(
                  children: _summary.personalHistory.entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 130.0,
                            child: Text(
                              '${e.key}:',
                              style: const TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navyPrimary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              e.value,
                              style: const TextStyle(
                                fontSize: 12.0,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              // 9. Previous Investigations
              _buildSectionCard(
                sectionNumber: '9',
                title: 'Previous Investigations & Labs',
                icon: Icons.biotech_rounded,
                iconColor: const Color(0xFF0284C7),
                child: _buildBulletList(_summary.previousInvestigations),
              ),

              const SizedBox(height: 20.0),

              // Bottom Submit Button
              ElevatedButton.icon(
                onPressed: _handleSubmitForConsultation,
                icon: const Icon(Icons.send_rounded, size: 18.0),
                label: const Text('Submit Intake for Doctor Consultation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenSuccess,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String sectionNumber,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22.0,
                height: 22.0,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    sectionNumber,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Icon(icon, size: 16.0, color: iconColor),
              const SizedBox(width: 6.0),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navyPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          const Divider(height: 1.0, color: AppColors.divider),
          const SizedBox(height: 10.0),
          child,
        ],
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    if (items.isEmpty) {
      return const Text(
        'None recorded or not applicable.',
        style: TextStyle(
            fontSize: 12.0,
            fontStyle: FontStyle.italic,
            color: AppColors.textMuted),
      );
    }
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6.0),
                width: 5.0,
                height: 5.0,
                decoration: const BoxDecoration(
                  color: AppColors.greenSuccess,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
