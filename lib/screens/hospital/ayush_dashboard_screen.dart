import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/hospital_model.dart';
import '../../widgets/ayush_widgets.dart';
import '../auth/login_screen.dart';
import 'hospital_profile_screen.dart';
import 'hospital_kiosk_screen.dart';
import 'add_doctor_screen.dart';

/// AYUSH Hospital Dashboard Screen.
/// 
/// Main operational hub shown after successful verification. Features hospital header with
/// verified badge, key operational stats, AYUSH clinical history & MediKiosk intake tools,
/// patient records, notification drawer, and hospital profile navigation.
class AyushDashboardScreen extends StatefulWidget {
  final AyushHospital hospital;

  const AyushDashboardScreen({
    super.key,
    required this.hospital,
  });

  @override
  State<AyushDashboardScreen> createState() => _AyushDashboardScreenState();
}

class _AyushDashboardScreenState extends State<AyushDashboardScreen> {
  int _unreadNotifications = 3;

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of the AYUSH Hospital Portal?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.saffronPrimary,
              foregroundColor: AppColors.background,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showNotificationPanel() {
    setState(() {
      _unreadNotifications = 0;
    });
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Hospital Notifications',
                  style: TextStyle(
                    color: AppColors.navyPrimary,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.notifications_active_rounded, color: AppColors.saffronPrimary),
              ],
            ),
            const SizedBox(height: 16.0),
            const Divider(color: AppColors.surfaceBorder),
            _buildNotificationItem(
              'New Patient Check-in',
              'Patient Ramesh Kumar (ABHA: 14-8912-3401) completed AI intake for OPD 3.',
              '10 mins ago',
              Icons.person_add_rounded,
            ),
            _buildNotificationItem(
              'ABDM Consent Approved',
              'FHIR Health record linkage established for 14 patient consultation summaries.',
              '45 mins ago',
              Icons.cloud_done_rounded,
            ),
            _buildNotificationItem(
              'AYUSH Accreditation Verified',
              'Official regulatory clearance certificate updated for 2026-2027.',
              '2 hours ago',
              Icons.verified_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String body, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppColors.saffronLight,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(icon, color: AppColors.saffronDark, size: 20.0),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navyPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10.0,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        title: const AyushHeaderLogo(iconSize: 20.0, fontSize: 16.0),
        actions: [
          // Notifications Bell Icon
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.navyPrimary),
                tooltip: 'Notifications',
                onPressed: _showNotificationPanel,
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: const BoxDecoration(
                      color: AppColors.saffronPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_unreadNotifications',
                      style: const TextStyle(
                        color: AppColors.background,
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Hospital Profile Action Button
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: AppColors.navyPrimary),
            tooltip: 'Hospital Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HospitalProfileScreen(hospital: widget.hospital),
                ),
              );
            },
          ),
          // Logout Action Button
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.saffronDark),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.navyPrimary, AppColors.navyDark],
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmall = constraints.maxWidth < 480;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'WELCOME BACK',
                                    style: TextStyle(
                                      color: AppColors.saffronPrimary,
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    widget.hospital.hospitalName,
                                    style: TextStyle(
                                      color: AppColors.background,
                                      fontSize: isSmall ? 18.0 : 22.0,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            // Hospital verification badge: Verified
                            StatusBadge(status: widget.hospital.verificationStatus),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        const Divider(color: Colors.white24, height: 1.0),
                        const SizedBox(height: 14.0),
                        Row(
                          children: [
                            const Icon(Icons.verified_user_outlined, size: 16.0, color: AppColors.greenSuccess),
                            const SizedBox(width: 6.0),
                            Expanded(
                              child: Text(
                                'AYUSH ID: ${widget.hospital.ayushId} • Reg No: ${widget.hospital.regNumber}',
                                style: const TextStyle(
                                  color: AppColors.surfaceBorder,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24.0),

              // Key Dashboard Metrics (Total Patients, Today's Appointments, Medical Records, Reports)
              const Text(
                'Operational Metrics',
                style: TextStyle(
                  color: AppColors.navyPrimary,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14.0),

              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final crossAxisCount = width > 700 ? 4 : (width > 440 ? 2 : 1);
                  final childAspectRatio = width > 700 ? 1.3 : (width > 440 ? 1.4 : 2.4);

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14.0,
                    mainAxisSpacing: 14.0,
                    childAspectRatio: childAspectRatio,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      StatCard(
                        title: 'Total Patients',
                        value: '1,420',
                        icon: Icons.people_alt_rounded,
                        iconColor: AppColors.navyPrimary,
                        iconBgColor: AppColors.surface,
                        subtitle: '+12% this wk',
                      ),
                      StatCard(
                        title: "Today's Appointments",
                        value: '84',
                        icon: Icons.calendar_today_rounded,
                        iconColor: AppColors.saffronDark,
                        iconBgColor: AppColors.saffronLight,
                        subtitle: 'Active OPD',
                      ),
                      StatCard(
                        title: 'Medical Records',
                        value: '3,290',
                        icon: Icons.folder_shared_rounded,
                        iconColor: AppColors.greenSuccess,
                        iconBgColor: AppColors.greenLight,
                        subtitle: 'ABDM Synced',
                      ),
                      StatCard(
                        title: 'Reports Generated',
                        value: '512',
                        icon: Icons.analytics_rounded,
                        iconColor: AppColors.navyLight,
                        iconBgColor: AppColors.surface,
                        subtitle: 'Physician Ready',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28.0),

              // AYUSH Clinical Features & Quick Actions
              const Text(
                'AYUSH Clinical Portal Tools',
                style: TextStyle(
                  color: AppColors.navyPrimary,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14.0),

              DashboardActionCard(
                title: 'Launch Hospital Kiosk',
                description: 'Open the patient-facing kiosk interface for check-ins and ABDM verifications.',
                icon: Icons.monitor,
                iconColor: AppColors.navyPrimary,
                iconBgColor: AppColors.surface,
                badgeText: 'LIVE KIOSK',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => HospitalKioskScreen(hospitalId: widget.hospital.id),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12.0),

              DashboardActionCard(
                title: 'Register New Doctor',
                description: 'Add a new physician or medical staff member to the hospital portal.',
                icon: Icons.person_add_alt_1_rounded,
                iconColor: AppColors.saffronDark,
                iconBgColor: AppColors.saffronLight,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddDoctorScreen(hospital: widget.hospital),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12.0),

              DashboardActionCard(
                title: 'Dashavidha & Ashtavidha Pariksha Records',
                description: 'Structured Ayurvedic intake parameter assessment (Prakriti, Vikriti, Agni, Koshtha, Ahara-Vihara).',
                icon: Icons.spa_rounded,
                iconColor: AppColors.greenSuccess,
                iconBgColor: AppColors.greenLight,
                badgeText: 'AYUSH SPECIAL',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dashavidha Pariksha EMR module loaded.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12.0),

              DashboardActionCard(
                title: 'Medical Records & OCR Scanner',
                description: 'View digitized prescriptions, handwritten lab reports, and chronological patient timelines.',
                icon: Icons.document_scanner_rounded,
                iconColor: AppColors.navyPrimary,
                iconBgColor: AppColors.surface,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Medical Records & OCR Scan module opened.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12.0),

              DashboardActionCard(
                title: 'Analytics & Clinical Reports',
                description: 'Export OPD throughput metrics, red-flag alert logs, and ABDM FHIR interoperability summaries.',
                icon: Icons.assessment_rounded,
                iconColor: AppColors.navyLight,
                iconBgColor: AppColors.surface,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Hospital Analytics & Reports exported.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12.0),

              DashboardActionCard(
                title: 'Hospital Profile & Settings',
                description: 'View facility accreditation, regulatory AYUSH IDs, contact info, and permitted editable fields.',
                icon: Icons.account_balance_rounded,
                iconColor: AppColors.textPrimary,
                iconBgColor: AppColors.surface,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => HospitalProfileScreen(hospital: widget.hospital),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}
