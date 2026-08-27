import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/patient_model.dart';
import '../../services/abha_verification_service.dart';
import '../../widgets/ayush_widgets.dart';
import 'patient_dashboard_screen.dart';

/// Step 2 of Patient Login: OTP Verification Screen.
///
/// Realistic production-grade authentication screen for ABDM / ABHA login.
/// Prompts patient for the 6-digit SMS verification code sent to their registered mobile.
/// Validates OTP via [AbhaVerificationService].
/// On success, navigates to [PatientDashboardScreen].
class PatientOtpScreen extends StatefulWidget {
  final PatientModel patient;

  const PatientOtpScreen({
    super.key,
    required this.patient,
  });

  @override
  State<PatientOtpScreen> createState() => _PatientOtpScreenState();
}

class _PatientOtpScreenState extends State<PatientOtpScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _service = AbhaVerificationService.instance;

  bool _isVerifying = false;
  String? _otpError;

  // ── Resend Timer ─────────────────────────────────────────────────────────────
  int _resendCountdown = 30; // 30-second countdown
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startResendCountdown() {
    _resendCountdown = 30;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _handleResendOtp() {
    _service.generateOtp(widget.patient);
    setState(() {
      _otpController.clear();
      _otpError = null;
    });
    _startResendCountdown();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'A new 6-digit verification code has been sent to your mobile number.',
        ),
        backgroundColor: AppColors.navyPrimary,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleVerifyOtp() async {
    setState(() => _otpError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isVerifying = true);
    // Realistic authentication delay
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final PatientModel? verified =
        _service.verifyOtp(_otpController.text.trim());

    if (verified == null) {
      setState(() {
        _isVerifying = false;
        _otpError =
            'Invalid OTP code. Please check the 6-digit code sent to your registered mobile number.';
      });
      return;
    }

    setState(() => _isVerifying = false);
    _countdownTimer?.cancel();

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PatientDashboardScreen(patient: verified),
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
          onPressed: () {
            _service.clearSession();
            Navigator.of(context).pop();
          },
        ),
        title: const AyushHeaderLogo(iconSize: 20.0, fontSize: 16.0),
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
                    // Header Shield / Lock Emblem
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 76.0,
                            height: 76.0,
                            decoration: const BoxDecoration(
                                color: AppColors.greenLight,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.mark_email_read_rounded,
                                color: AppColors.greenSuccess, size: 38.0),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: const BoxDecoration(
                                color: AppColors.greenSuccess,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.check_rounded,
                                color: Colors.white, size: 14.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Screen Title
                    const Text(
                      'OTP Verification',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.navyPrimary,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2),
                    ),
                    const SizedBox(height: 6.0),
                    const Text(
                      'Step 2 of 2 — Identity Verification',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13.5),
                    ),
                    const SizedBox(height: 8.0),

                    // Step Indicator
                    _buildStepIndicator(),
                    const SizedBox(height: 24.0),

                    // SMS Notification Card
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: AppColors.surfaceBorder),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 10.0,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: AppColors.greenLight,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: const Icon(Icons.phonelink_ring_rounded,
                                    color: AppColors.greenSuccess, size: 22.0),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.patient.name,
                                      style: const TextStyle(
                                          color: AppColors.navyPrimary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14.0),
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text(
                                      'ABHA: ${widget.patient.abhaId}',
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(color: AppColors.divider, height: 1),
                          ),
                          Text(
                            'A 6-digit verification code has been sent to your registered mobile number ${widget.patient.maskedMobile}.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // OTP Error Banner
                    if (_otpError != null) ...[
                      _buildErrorBanner(_otpError!),
                      const SizedBox(height: 16.0),
                    ],

                    // OTP Input Section Label
                    const Text(
                      'Enter Verification Code',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.0,
                          color: AppColors.navyPrimary),
                    ),
                    const SizedBox(height: 10.0),

                    // 6-Digit OTP Box Grid Input
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 26.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 10.0,
                          color: AppColors.navyPrimary),
                      onChanged: (_) {
                        if (_otpError != null) {
                          setState(() => _otpError = null);
                        }
                      },
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '• • • • • •',
                        hintStyle: const TextStyle(
                            letterSpacing: 8.0,
                            color: AppColors.textMuted,
                            fontSize: 24.0),
                        prefixIcon: const Icon(Icons.pin_rounded,
                            color: AppColors.greenSuccess),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0),
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
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                              color: AppColors.greenSuccess, width: 1.5),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter the 6-digit OTP code.';
                        }
                        if (val.trim().length != 6 ||
                            !RegExp(r'^\d{6}$').hasMatch(val.trim())) {
                          return 'OTP must be exactly 6 digits.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),

                    // Verify OTP Button
                    SizedBox(
                      height: 52.0,
                      child: ElevatedButton.icon(
                        onPressed: _isVerifying ? null : _handleVerifyOtp,
                        icon: _isVerifying
                            ? const SizedBox(
                                width: 18.0,
                                height: 18.0,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.0, color: Colors.white))
                            : const Icon(Icons.lock_open_rounded, size: 20.0),
                        label: Text(
                          _isVerifying ? 'Authenticating...' : 'Verify OTP',
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
                    const SizedBox(height: 18.0),

                    // Resend OTP Option with Countdown
                    Center(
                      child: _resendCountdown > 0
                          ? Text(
                              'Resend code in ${_resendCountdown}s',
                              style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w500),
                            )
                          : TextButton.icon(
                              onPressed: _handleResendOtp,
                              icon: const Icon(Icons.refresh_rounded,
                                  size: 16.0, color: AppColors.greenSuccess),
                              label: const Text(
                                'Resend OTP',
                                style: TextStyle(
                                    color: AppColors.greenSuccess,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.0),
                              ),
                            ),
                    ),
                    const SizedBox(height: 32.0),

                    // Official Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.shield_rounded,
                            size: 15.0, color: AppColors.greenSuccess),
                        SizedBox(width: 6.0),
                        Flexible(
                          child: Text(
                            'Ministry of Ayush • ABDM Digital Authentication Service',
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

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _stepDot(label: '✓', label2: 'ABHA ID', done: true, active: false),
        Expanded(
            child: Container(height: 2.0, color: AppColors.greenSuccess)),
        _stepDot(label: '2', label2: 'OTP', done: false, active: true),
        Expanded(
            child: Container(height: 2.0, color: AppColors.surfaceBorder)),
        _stepDot(
            label: '✓', label2: 'Dashboard', done: false, active: false),
      ],
    );
  }

  Widget _stepDot(
      {required String label,
      required String label2,
      required bool done,
      required bool active}) {
    return Column(
      children: [
        Container(
          width: 28.0,
          height: 28.0,
          decoration: BoxDecoration(
            color: done || active
                ? AppColors.greenSuccess
                : AppColors.surfaceBorder,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: done || active ? Colors.white : AppColors.textMuted,
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 4.0),
        Text(label2,
            style: TextStyle(
                fontSize: 9.5,
                color: done || active
                    ? AppColors.greenSuccess
                    : AppColors.textMuted,
                fontWeight: done || active
                    ? FontWeight.bold
                    : FontWeight.normal)),
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
}
