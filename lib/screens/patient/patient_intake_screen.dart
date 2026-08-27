import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/patient_model.dart';
import '../../services/abha_verification_service.dart';
import '../../widgets/ayush_widgets.dart';
import 'patient_otp_screen.dart';

/// Step 1 of Patient Login: ABHA ID Entry & Verification.
///
/// The patient enters their 14-digit ABHA Health ID.
/// On verify, the ID is checked against [AbhaVerificationService].
/// If found, an OTP is generated and the user moves to [PatientOtpScreen].
class PatientIntakeScreen extends StatefulWidget {
  const PatientIntakeScreen({super.key});

  @override
  State<PatientIntakeScreen> createState() => _PatientIntakeScreenState();
}

class _PatientIntakeScreenState extends State<PatientIntakeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _abhaController = TextEditingController();

  bool _isVerifying = false;
  String? _abhaError;

  final _service = AbhaVerificationService.instance;

  @override
  void dispose() {
    _abhaController.dispose();
    super.dispose();
  }

  /// Auto-fills the first demo patient's ABHA ID for evaluators.
  void _autoFill() {
    setState(() {
      _abhaController.text = AbhaVerificationService.demoPatients.first.abhaId;
      _abhaError = null;
    });
  }

  /// Validates ABHA format: 14 digits, optionally separated by dashes.
  String? _validateAbhaFormat(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your ABHA Health ID.';
    }
    final stripped = value.replaceAll('-', '').trim();
    if (stripped.length != 14 || !RegExp(r'^\d{14}$').hasMatch(stripped)) {
      return 'Enter a valid 14-digit ABHA ID (e.g. 14-8912-3401-7752).';
    }
    return null;
  }

  Future<void> _handleVerifyAbha() async {
    setState(() => _abhaError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isVerifying = true);
    // Simulate network latency for a realistic demo feel
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final abhaId = _abhaController.text.trim();
    final PatientModel? patient = _service.verifyAbhaId(abhaId);

    if (patient == null) {
      setState(() {
        _isVerifying = false;
        _abhaError = 'ABHA ID not found or invalid. Try one of the demo IDs.';
      });
      return;
    }

    // ABHA verified — initiate OTP and proceed to OTP screen
    _service.generateOtp(patient);
    setState(() => _isVerifying = false);

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PatientOtpScreen(
          patient: patient,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.navyPrimary, size: 20.0),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const AyushHeaderLogo(iconSize: 20.0, fontSize: 16.0),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: _autoFill,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.saffronDark,
                backgroundColor: AppColors.saffronLight,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              ),
              icon: const Icon(Icons.auto_fix_high_rounded, size: 16.0),
              label: const Text('Auto Fill',
                  style:
                      TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Icon
                    Center(
                      child: Container(
                        width: 76.0,
                        height: 76.0,
                        decoration: const BoxDecoration(
                          color: AppColors.greenLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.health_and_safety_rounded,
                          color: AppColors.greenSuccess,
                          size: 40.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Title & Step Indicator
                    const Text(
                      'Patient Portal Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.navyPrimary,
                        fontSize: 24.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    const Text(
                      'Step 1 of 2 — Enter your ABHA Health ID',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13.5),
                    ),
                    const SizedBox(height: 8.0),

                    // Step progress
                    _buildStepIndicator(currentStep: 1),
                    const SizedBox(height: 28.0),

                    // ABHA Error Banner
                    if (_abhaError != null) ...[
                      _buildErrorBanner(_abhaError!),
                      const SizedBox(height: 16.0),
                    ],

                    // ABHA ID field label
                    const Text(
                      'ABHA Health ID',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.0,
                        color: AppColors.navyPrimary,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _abhaController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) {
                        if (_abhaError != null) {
                          setState(() => _abhaError = null);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'e.g. 14-8912-3401-7752',
                        prefixIcon: const Icon(Icons.badge_rounded,
                            color: AppColors.greenSuccess),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                              color: Color(0xFFEF4444), width: 1.5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                              color: Color(0xFFEF4444), width: 1.5),
                        ),
                      ),
                      validator: _validateAbhaFormat,
                    ),
                    const SizedBox(height: 8.0),

                    // ABHA hint
                    Row(
                      children: const [
                        Icon(Icons.info_outline_rounded,
                            size: 13.0, color: AppColors.textMuted),
                        SizedBox(width: 5.0),
                        Flexible(
                          child: Text(
                            'Your 14-digit ABHA ID is issued by the Ayushman Bharat Digital Mission.',
                            style: TextStyle(
                                fontSize: 11.5, color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28.0),

                    // Verify ABHA ID Button
                    SizedBox(
                      height: 52.0,
                      child: ElevatedButton.icon(
                        onPressed: _isVerifying ? null : _handleVerifyAbha,
                        icon: _isVerifying
                            ? const SizedBox(
                                width: 18.0,
                                height: 18.0,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.0, color: Colors.white),
                              )
                            : const Icon(Icons.verified_rounded, size: 20.0),
                        label: Text(
                          _isVerifying
                              ? 'Verifying ABHA ID...'
                              : 'Verify ABHA ID',
                          style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greenSuccess,
                          foregroundColor: Colors.white,
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Demo Quick-Select IDs for evaluators
                    _buildDemoIdPanel(),
                    const SizedBox(height: 32.0),

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.verified_user_rounded,
                            size: 15.0, color: AppColors.greenSuccess),
                        SizedBox(width: 6.0),
                        Flexible(
                          child: Text(
                            'Ministry of Ayush • ABDM Demo Verification System',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11.0,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helper Widgets ──────────────────────────────────────────────────────────

  Widget _buildStepIndicator({required int currentStep}) {
    return Row(
      children: [
        _stepDot(label: '1', label2: 'ABHA ID', active: currentStep == 1),
        Expanded(
          child: Container(
            height: 2.0,
            color: currentStep >= 2
                ? AppColors.greenSuccess
                : AppColors.surfaceBorder,
          ),
        ),
        _stepDot(label: '2', label2: 'OTP', active: currentStep == 2),
        Expanded(
          child: Container(
            height: 2.0,
            color: currentStep >= 3
                ? AppColors.greenSuccess
                : AppColors.surfaceBorder,
          ),
        ),
        _stepDot(label: '✓', label2: 'Dashboard', active: currentStep == 3),
      ],
    );
  }

  Widget _stepDot(
      {required String label,
      required String label2,
      required bool active}) {
    return Column(
      children: [
        Container(
          width: 28.0,
          height: 28.0,
          decoration: BoxDecoration(
            color: active ? AppColors.greenSuccess : AppColors.surfaceBorder,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: active ? Colors.white : AppColors.textMuted,
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 4.0),
        Text(label2,
            style: TextStyle(
                fontSize: 9.5,
                color:
                    active ? AppColors.greenSuccess : AppColors.textMuted,
                fontWeight:
                    active ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFFEF4444)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFDC2626), size: 20.0),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: Color(0xFF991B1B),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoIdPanel() {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.dataset_rounded,
                  size: 15.0, color: AppColors.saffronDark),
              SizedBox(width: 6.0),
              Text(
                'DEMO — Available ABHA IDs',
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.saffronDark),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          ...AbhaVerificationService.demoPatients.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8.0),
                  onTap: () {
                    setState(() {
                      _abhaController.text = p.abhaId;
                      _abhaError = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 7.0),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline_rounded,
                            size: 14.0, color: AppColors.greenSuccess),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            '${p.name}  •  ${p.abhaId}',
                            style: const TextStyle(
                                fontSize: 12.0,
                                color: AppColors.navyPrimary,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            size: 16.0, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
