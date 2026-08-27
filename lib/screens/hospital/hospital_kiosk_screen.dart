import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../app/theme.dart';
import '../../models/doctor_model.dart';
import '../auth/doctor_login_screen.dart';
import '../../services/doctor_service.dart';
import '../../services/consultation_service.dart';
import '../../config/api_config.dart';

/// Hospital Kiosk Portal Screen.
///
/// This is the public-facing hospital display that patients interact with
/// when they arrive at the hospital. It shows the specialist directory and
/// generates QR codes for doctors that patients scan with their app.
///
/// KEY RULE: Only this screen generates QR codes. The patient app NEVER
/// generates QR codes — the patient only scans them.
class HospitalKioskScreen extends StatefulWidget {
  final String hospitalId;

  const HospitalKioskScreen({super.key, required this.hospitalId});

  @override
  State<HospitalKioskScreen> createState() => _HospitalKioskScreenState();
}

class _HospitalKioskScreenState extends State<HospitalKioskScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  List<DoctorModel> _specialists = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final doctors = await DoctorService().getDoctorsByHospital(widget.hospitalId);
      setState(() {
        _specialists = doctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Generates a dynamic fallback code: [hospital 2 chars][doctor 2 chars][3 random digits]
  String _generateFallbackCode(DoctorModel doctor) {
    final hospitalPrefix = 'AY'; // Abbreviation for AYUSH
    final doctorPrefix = doctor.name
        .replaceAll(' ', '')
        .substring(0, 2)
        .toUpperCase();
    final random = Random();
    final sessionNum = (random.nextInt(900) + 100).toString(); // 3-digit
    return '$hospitalPrefix$doctorPrefix$sessionNum';
  }

  void _showDoctorQrDialog(DoctorModel doctor) {
    final consultationService = ConsultationService();
    final sessionFuture = consultationService.startSession(doctor.hospitalId, doctor.id);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.navyPrimary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      'Connect with Patient',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Doctor name & hospital
                  Text(
                    'Dr. ${doctor.name}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navyPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.specialization,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'AYUSH Multi-Specialty Hospital',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.saffronDark,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // QR Code and Details from Future
                  FutureBuilder<Map<String, dynamic>>(
                    future: sessionFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.navyPrimary),
                          ),
                        );
                      }
                      
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Failed to start session: \${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      final session = snapshot.data!;
                      final token = session['qr_token'];
                      final fallbackCode = session['fallback_code'] ?? _generateFallbackCode(doctor);
                      final uploadUrl = '${ApiConfig.patientUploadWebPortal}?token=$token';

                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.surfaceBorder, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: QrImageView(
                              data: uploadUrl,
                              version: QrVersions.auto,
                              size: 220.0,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: AppColors.navyPrimary,
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.circle,
                                color: AppColors.navyPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Fallback Code
                          const Text(
                            'Fallback Code:',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.saffronLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.saffronPrimary.withOpacity(0.4)),
                            ),
                            child: Text(
                              fallbackCode,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.saffronDark,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'If the camera is unavailable, go to the upload portal\nand enter this code.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Session expiry indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.greenLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.greenSuccess.withOpacity(0.3)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.timer, color: AppColors.greenSuccess, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Session expires in: 90:00',
                                  style: TextStyle(
                                    color: AppColors.greenSuccess,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.navyPrimary,
                        side: const BorderSide(color: AppColors.surfaceBorder),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<DoctorModel> get _filteredSpecialists {
    if (_searchQuery.isEmpty) return _specialists;
    final q = _searchQuery.toLowerCase();
    return _specialists.where((d) {
      return d.name.toLowerCase().contains(q) ||
          d.specialization.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.local_hospital, color: AppColors.saffronPrimary, size: 22),
            SizedBox(width: 8),
            Text(
              'AYUSH HOSPITAL PORTAL',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          // Doctor Login Button — clearly separated, top-right
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const DoctorLoginScreen(),
                ));
              },
              icon: const Icon(Icons.login, color: AppColors.navyPrimary, size: 18),
              label: const Text(
                'Login as Doctor',
                style: TextStyle(
                  color: AppColors.navyPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.surfaceBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Dark Hero Section ──────────────────────────────────────────
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Hospital info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AYUSH HOSPITAL — PATIENT SERVICES',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Welcome to your digital health companion',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF10B981)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.check_circle, color: Color(0xFF10B981), size: 14),
                                  SizedBox(width: 6),
                                  Text(
                                    'Verified',
                                    style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'AYUSH ID · Reg No: 123456789',
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      // Right: Action buttons
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildHeroButton('BOOK\nAPPOINTMENT', Icons.calendar_today, const Color(0xFFF97316)),
                          _buildHeroButton('VIEW MEDICAL\nRECORDS', Icons.folder_open, const Color(0xFF3B82F6)),
                          _buildHeroButton('CONTACT\nSUPPORT', Icons.phone, const Color(0xFF14B8A6)),
                          _buildHeroButton('PAY\nONLINE', Icons.credit_card, const Color(0xFF64748B)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Search Bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search doctors by name or specialization...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.surfaceBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.surfaceBorder),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Specialists Section ───────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'OUR SPECIALISTS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Select a doctor to generate a connection QR code',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 16),

            // Doctor Cards — Grid layout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (_isLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator(color: AppColors.saffronPrimary)),
                    );
                  }
                  if (_errorMessage != null) {
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red)),
                      ),
                    );
                  }

                  final cardWidth = (constraints.maxWidth - 16) / 2;
                  final doctors = _filteredSpecialists;
                  if (doctors.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text('No doctors match your search.', style: TextStyle(color: AppColors.textMuted)),
                      ),
                    );
                  }
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: doctors.map((doctor) {
                      return SizedBox(
                        width: cardWidth,
                        child: _buildDoctorCard(doctor),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor) {
    return InkWell(
      onTap: () => _showDoctorQrDialog(doctor),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.surface,
              child: Icon(
                Icons.person,
                size: 32,
                color: AppColors.navyPrimary.withOpacity(0.4),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${doctor.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.navyPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doctor.specialization,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroButton(String title, IconData icon, Color color) {
    return Container(
      width: 120,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
