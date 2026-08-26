import 'dart:math';
import 'package:flutter/material.dart';
import '../../app/theme.dart';

/// Interactive Patient Kiosk Intake & OPD Token Generation Screen.
class PatientIntakeScreen extends StatefulWidget {
  const PatientIntakeScreen({super.key});

  @override
  State<PatientIntakeScreen> createState() => _PatientIntakeScreenState();
}

class _PatientIntakeScreenState extends State<PatientIntakeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _symptomsController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedSpecialty = 'Ayurveda General OPD';
  Map<String, dynamic>? _generatedToken;

  final List<String> _specialties = [
    'Ayurveda General OPD',
    'Panchakarma Speciality Clinic',
    'Yoga & Lifestyle Therapy',
    'Unani Medicine OPD',
    'Siddha Wellness & Therapy',
    'Homoeopathy Consultation',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  void _fillSamplePatient() {
    setState(() {
      _nameController.text = 'Aarav Patel';
      _ageController.text = '38';
      _phoneController.text = '9876543210';
      _selectedGender = 'Male';
      _selectedSpecialty = 'Ayurveda General OPD';
      _symptomsController.text = 'Chronic digestive issues, fatigue, and mild joint stiffness';
    });
  }

  void _generateToken() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final tokenNum = 10 + Random().nextInt(80);
    final roomNum = 1 + Random().nextInt(6);
    final waitMinutes = (tokenNum % 7 + 2) * 5;

    setState(() {
      _generatedToken = {
        'tokenNumber': 'AY-$tokenNum',
        'patientName': _nameController.text.trim(),
        'specialty': _selectedSpecialty,
        'room': 'OPD Room $roomNum',
        'estimatedWait': '$waitMinutes mins',
        'generatedAt': 'Today, ${TimeOfDay.now().format(context)}',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: isDark ? AppColors.darkTextPrimary : AppColors.navyPrimary, size: 20.0),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Patient Kiosk Intake',
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.navyPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18.0,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: _fillSamplePatient,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.saffronDark,
                backgroundColor: isDark ? AppColors.darkSaffronLight : AppColors.saffronLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              ),
              icon: const Icon(Icons.auto_fix_high_rounded, size: 16.0),
              label: const Text('Auto Fill', style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: _generatedToken != null ? _buildTokenSlip(isDark) : _buildIntakeForm(isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntakeForm(bool isDark) {
    return Card(
      color: isDark ? AppColors.darkSurface : AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: isDark ? AppColors.darkSurfaceBorder : AppColors.surfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: AppColors.greenLight,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: const Icon(Icons.touch_app_rounded, color: AppColors.greenSuccess, size: 24.0),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Self-Service OPD Check-in',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.navyPrimary,
                          ),
                        ),
                        Text(
                          'Enter patient details to generate your queue token',
                          style: TextStyle(fontSize: 12.0, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32.0),

              // Full Name
              Text('Patient Full Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0, color: isDark ? AppColors.darkTextPrimary : AppColors.navyPrimary)),
              const SizedBox(height: 6.0),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'e.g. Aarav Patel', prefixIcon: Icon(Icons.person_outline_rounded)),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter patient name' : null,
              ),
              const SizedBox(height: 16.0),

              // Age & Gender Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Age (Years)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0, color: isDark ? AppColors.darkTextPrimary : AppColors.navyPrimary)),
                        const SizedBox(height: 6.0),
                        TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'e.g. 38', prefixIcon: Icon(Icons.cake_outlined)),
                          validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gender', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0, color: isDark ? AppColors.darkTextPrimary : AppColors.navyPrimary)),
                        const SizedBox(height: 6.0),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedGender,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0)),
                          items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (val) => setState(() => _selectedGender = val!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Mobile Number
              Text('Mobile Number (for SMS token updates)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0, color: isDark ? AppColors.darkTextPrimary : AppColors.navyPrimary)),
              const SizedBox(height: 6.0),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: '9876543210', prefixIcon: Icon(Icons.phone_outlined)),
                validator: (val) => (val == null || val.trim().length < 10) ? 'Enter valid 10-digit number' : null,
              ),
              const SizedBox(height: 16.0),

              // Specialty Department
              Text('AYUSH Speciality Department', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0, color: isDark ? AppColors.darkTextPrimary : AppColors.navyPrimary)),
              const SizedBox(height: 6.0),
              DropdownButtonFormField<String>(
                initialValue: _selectedSpecialty,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.spa_outlined, color: AppColors.saffronPrimary)),
                items: _specialties.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13.0)))).toList(),
                onChanged: (val) => setState(() => _selectedSpecialty = val!),
              ),
              const SizedBox(height: 16.0),

              // Primary Symptoms
              Text('Primary Health Symptoms / Concerns', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0, color: isDark ? AppColors.darkTextPrimary : AppColors.navyPrimary)),
              const SizedBox(height: 6.0),
              TextFormField(
                controller: _symptomsController,
                maxLines: 2,
                decoration: const InputDecoration(hintText: 'Briefly describe reason for consultation...'),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Please describe symptoms' : null,
              ),
              const SizedBox(height: 24.0),

              // Generate Token Button
              ElevatedButton.icon(
                onPressed: _generateToken,
                icon: const Icon(Icons.confirmation_number_rounded),
                label: const Text('Generate OPD Queue Token', style: TextStyle(fontSize: 15.0)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.saffronPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTokenSlip(bool isDark) {
    final t = _generatedToken!;
    return Card(
      color: isDark ? AppColors.darkSurface : AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: const BorderSide(color: AppColors.greenSuccess, width: 2.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: const BoxDecoration(
                color: AppColors.greenLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.greenSuccess, size: 48.0),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'OPD Check-in Successful!',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w900, color: AppColors.greenSuccess),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Your registration token has been dispatched to queue display.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.0, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            ),
            const Divider(height: 32.0),

            // Token Number Highlight Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSaffronLight : AppColors.saffronLight,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: AppColors.saffronPrimary.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  const Text(
                    'TOKEN NUMBER',
                    style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.saffronDark),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    t['tokenNumber'],
                    style: const TextStyle(fontSize: 44.0, fontWeight: FontWeight.w900, color: AppColors.saffronDark),
                  ),
                  Text(
                    'Est. Wait: ${t['estimatedWait']}',
                    style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkTextPrimary : AppColors.navyPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),

            _buildSlipRow('Patient Name', t['patientName'], isDark),
            _buildSlipRow('Department', t['specialty'], isDark),
            _buildSlipRow('Assigned Room', t['room'], isDark, isHighlight: true),
            _buildSlipRow('Time Generated', t['generatedAt'], isDark),

            const Divider(height: 32.0),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _generatedToken = null),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Next Patient'),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Printing OPD token slip to receipt printer...')),
                      );
                    },
                    icon: const Icon(Icons.print_rounded),
                    label: const Text('Print Slip'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlipRow(String label, String value, bool isDark, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13.0, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w700,
              color: isHighlight ? AppColors.greenSuccess : (isDark ? AppColors.darkTextPrimary : AppColors.navyPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
