import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/doctor_model.dart';

/// Structured Patient Profile Screen — Doctor's view of a patient who
/// approved data-sharing via the QR flow.
///
/// Displays highly structured clinical data sections:
/// 1. Session Banner with live countdown timer
/// 2. Patient Overview
/// 3. AI Medical Summary
/// 4. Medical History
/// 5. Shared Records
class PatientProfileScreen extends StatefulWidget {
  final DoctorModel doctor;
  final String patientId;
  final String rawToken;
  final String patientName;
  final String abhaId;

  const PatientProfileScreen({
    super.key,
    required this.doctor,
    required this.patientId,
    required this.rawToken,
    required this.patientName,
    required this.abhaId,
  });

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  bool _isLoading = true;
  late Timer _timer;
  int _remainingSeconds = 90 * 60; // 90 minutes

  @override
  void initState() {
    super.initState();
    _loadData();
    _startSessionTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _loadData() async {
    // Simulate network fetch
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _isLoading = false);
  }

  void _startSessionTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Access revoked.'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    });
  }

  String get _formattedTime {
    final h = _remainingSeconds ~/ 3600;
    final m = (_remainingSeconds % 3600) ~/ 60;
    final s = _remainingSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Patient Medical Record',
          style: TextStyle(color: AppColors.navyPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.navyPrimary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Secure Session Banner ─────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.navyPrimary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.security, color: Colors.white, size: 26),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SECURE SESSION ACTIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Shared with Dr. ${widget.doctor.name}',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _remainingSeconds < 600
                                ? Colors.redAccent.withOpacity(0.25)
                                : Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _remainingSeconds < 600
                                  ? Colors.redAccent
                                  : Colors.white38,
                            ),
                          ),
                          child: Text(
                            _formattedTime,
                            style: TextStyle(
                              color: _remainingSeconds < 600
                                  ? Colors.redAccent
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Patient Overview ──────────────────────────────────────
                  _SectionCard(
                    title: 'Patient Overview',
                    icon: Icons.person,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.saffronLight,
                          child: Text(
                            widget.patientName.isNotEmpty ? widget.patientName[0] : '?',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.saffronDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.patientName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.navyPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ABHA ID: ${widget.abhaId}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: const [
                                  _Tag(label: '36 Yrs'),
                                  SizedBox(width: 8),
                                  _Tag(label: 'Male'),
                                  SizedBox(width: 8),
                                  _Tag(label: 'O+'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── AI Medical Summary ────────────────────────────────────
                  _SectionCard(
                    title: 'AI Medical Summary',
                    icon: Icons.auto_awesome,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _DataRow(label: 'Chief Concern', value: 'Chronic lower back pain radiating to left leg'),
                        _DataRow(label: 'Current Symptoms', value: 'Sharp pain, numbness in toes, stiffness in the morning'),
                        _DataRow(label: 'Duration', value: 'Past 3 weeks, worsening gradually'),
                        _DataRow(label: 'Relevant Context', value: 'Pain increases after sitting for >1 hour. Relief when lying flat.'),
                        _DataRow(
                          label: 'Important Observations',
                          value: 'No loss of bowel/bladder control. Patient has a desk job.',
                          isAlert: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Medical History ───────────────────────────────────────
                  _SectionCard(
                    title: 'Medical History',
                    icon: Icons.history,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _DataRow(label: 'Previous Conditions', value: 'Hypertension (diagnosed 2019)'),
                        _DataRow(label: 'Surgeries', value: 'Appendectomy (2010)'),
                        _DataRow(label: 'Hospitalizations', value: 'None recent'),
                        _DataRow(label: 'Allergies', value: 'Penicillin (Hives)', isAlert: true),
                        _DataRow(label: 'Current Medications', value: 'Amlodipine 5mg daily'),
                        _DataRow(label: 'Relevant Family History', value: 'Father — Type 2 Diabetes'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Shared Records ───────────────────────────────────────
                  _SectionCard(
                    title: 'Shared Records',
                    icon: Icons.folder_shared,
                    child: Column(
                      children: [
                        _DocumentItem(
                          title: 'Lumbar Spine MRI Report.pdf',
                          date: 'Aug 10, 2026',
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening document...')),
                          ),
                        ),
                        const Divider(height: 20),
                        _DocumentItem(
                          title: 'Recent Blood Work.pdf',
                          date: 'Jul 22, 2026',
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening document...')),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Sharing Session Info ─────────────────────────────────
                  _SectionCard(
                    title: 'Sharing Session',
                    icon: Icons.timer,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DataRow(label: 'Shared by Patient', value: widget.patientName),
                        _DataRow(label: 'Doctor', value: 'Dr. ${widget.doctor.name}'),
                        _DataRow(label: 'Hospital', value: 'AYUSH Multi-Specialty Hospital'),
                        _DataRow(label: 'Session Duration', value: '90 minutes'),
                        _DataRow(label: 'Remaining Time', value: _formattedTime),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Upload action
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Prescription uploaded securely (Mock)'),
                          backgroundColor: AppColors.greenSuccess,
                        ),
                      );
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Prescription / Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navyPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

// ── Reusable Sub-Widgets ──────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Icon(icon, color: AppColors.saffronPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isAlert;

  const _DataRow({required this.label, required this.value, this.isAlert = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isAlert ? Colors.red.shade800 : AppColors.textPrimary,
              fontWeight: isAlert ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.navyPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DocumentItem extends StatelessWidget {
  final String title;
  final String date;
  final VoidCallback onTap;

  const _DocumentItem({required this.title, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.picture_as_pdf, color: Colors.blue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(date, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_red_eye, color: AppColors.navyPrimary, size: 20),
          onPressed: onTap,
        ),
      ],
    );
  }
}
