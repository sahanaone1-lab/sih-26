import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/doctor_model.dart';
import 'patient_profile_screen.dart';

/// Doctor Dashboard — shown after doctor authentication via DoctorLoginScreen.
///
/// The doctor does NOT scan QR codes. Instead, they see patients who have
/// actively shared their information through the Hospital Kiosk QR flow.
class DoctorDashboardScreen extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorDashboardScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Doctor Dashboard', style: TextStyle(color: AppColors.navyPrimary)),
        backgroundColor: AppColors.background,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.saffronDark),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Doctor Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.navyPrimary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navyPrimary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. ${doctor.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialization,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.badge, color: Colors.white54, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'ID: ${doctor.doctorId}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Section title
              const Text(
                'Patient Sessions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Patients who scanned your QR and approved sharing',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Active Consultations card
              _buildActionCard(
                context,
                title: 'Active Consultations',
                description: 'View patients who shared their information with you via the Hospital Kiosk QR flow.',
                icon: Icons.people,
                color: AppColors.greenSuccess,
                onTap: () {
                  // Navigate to a mock patient who granted access
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PatientProfileScreen(
                      patientId: '14-8912-3401-7752',
                      rawToken: 'mock_token',
                      doctor: doctor,
                      patientName: 'Aarav Patel',
                      abhaId: '14-8912-3401-7752',
                    ),
                  ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navyPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}
