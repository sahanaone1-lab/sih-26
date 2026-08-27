import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/hospital_model.dart';
import '../../services/admin_hospital_service.dart';
import '../../widgets/ayush_widgets.dart';
import '../admin/admin_dashboard_screen.dart';
import '../hospital/ayush_dashboard_screen.dart';
import '../hospital/hospital_registration_screen.dart';
import '../hospital/verification_status_screen.dart';
import '../hospital/hospital_kiosk_screen.dart';
import 'doctor_login_screen.dart';

/// Dedicated AYUSH Hospital Login Screen.
///
/// Allows registered hospitals to authenticate using their Registration ID / Email and Password.
/// Validates status: routes verified accounts to AyushDashboardScreen and pending accounts to VerificationStatusScreen.
class LoginScreen extends StatefulWidget {
  final String? initialRegistrationId;
  final AyushHospital? registeredHospital;

  const LoginScreen({
    super.key,
    this.initialRegistrationId,
    this.registeredHospital,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _identifierController;
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _identifierController = TextEditingController(
      text:
          widget.initialRegistrationId ??
          widget.registeredHospital?.applicationId ??
          '',
    );
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      final inputQuery = _identifierController.text.trim();
      final password = _passwordController.text;

      try {
        final hospital = await AdminHospitalService().loginHospital(inputQuery, password);
        
        if (!mounted) return;

        if (hospital.verificationStatus == VerificationStatus.verified) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AyushDashboardScreen(hospital: hospital),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VerificationStatusScreen(hospital: hospital),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const AyushHeaderLogo(iconSize: 22.0, fontSize: 18.0),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdminDashboardScreen(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.navyPrimary,
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.surfaceBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              icon: const Icon(
                Icons.admin_panel_settings_rounded,
                size: 16.0,
                color: AppColors.saffronDark,
              ),
              label: const Text(
                'Admin Portal',
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 28.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Heading Header Section
                    Center(
                      child: Container(
                        width: 72.0,
                        height: 72.0,
                        decoration: const BoxDecoration(
                          color: AppColors.saffronLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_hospital_rounded,
                          color: AppColors.saffronDark,
                          size: 38.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    const Text(
                      'AYUSH Hospital Login',
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
                      'Sign in to your hospital administration portal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 28.0),

                    // Hospital Registration ID / Email Input
                    TextFormField(
                      controller: _identifierController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Hospital Registration ID / Email',
                        hintText:
                            'Enter Registration ID (AYUSH-HOSP...) or Email',
                        prefixIcon: const Icon(
                          Icons.badge_outlined,
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: AppColors.surfaceBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: AppColors.surfaceBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: AppColors.navyPrimary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter Hospital Registration ID or Email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18.0),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter portal password',
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.textSecondary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: AppColors.surfaceBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: AppColors.surfaceBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: AppColors.navyPrimary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),

                    // Forgot Password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Password reset instructions sent to registered official email.',
                              ),
                              backgroundColor: AppColors.navyPrimary,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.saffronDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),

                    // Login Button (Navigates to Dashboard when verified)
                    SizedBox(
                      height: 52.0,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleLogin,
                        icon: _isLoading 
                            ? const SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.login_rounded, size: 20.0),
                        label: Text(
                          _isLoading ? 'Authenticating...' : 'Hospital Login',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.saffronPrimary,
                          foregroundColor: AppColors.background,
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Divider: NEW HOSPITAL REGISTRATION
                    Row(
                      children: const [
                        Expanded(
                          child: Divider(color: AppColors.surfaceBorder),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            'NEW HOSPITAL?',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: AppColors.surfaceBorder),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),

                    // Button: Register Hospital
                    SizedBox(
                      height: 50.0,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const HospitalRegistrationScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.app_registration_rounded,
                          size: 20.0,
                        ),
                        label: const Text(
                          'Register Hospital',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.navyPrimary,
                          side: const BorderSide(
                            color: AppColors.navyPrimary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Button: Doctor Login
                    SizedBox(
                      height: 50.0,
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const DoctorLoginScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.medical_services_rounded,
                          size: 20.0,
                          color: AppColors.saffronDark,
                        ),
                        label: const Text(
                          'Doctor Login',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyPrimary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36.0),

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.verified_user_rounded,
                          size: 15.0,
                          color: AppColors.greenSuccess,
                        ),
                        SizedBox(width: 6.0),
                        Flexible(
                          child: Text(
                            'Ministry of Ayush • ABDM & MediKiosk Compliant Platform',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w500,
                            ),
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
}
