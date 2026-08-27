import 'package:flutter/material.dart';
import '../../app/theme.dart';
import 'admin_dashboard_screen.dart';

/// Secure Admin Login Screen for AYUSH Verification Officers & System Administrators.
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillMockAdmin() {
    setState(() {
      _emailController.text = 'admin@ayush.gov.in';
      _passwordController.text = 'ayushAdmin2026';
      _errorMessage = null;
    });
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Authenticate admin credentials
    if ((email.toLowerCase() == 'admin@ayush.gov.in' ||
            email.toLowerCase() == 'admin@medikiosk.gov.in' ||
            email.toLowerCase() == 'officer@ayush.gov.in') &&
        (password == 'ayushAdmin2026' || password == 'password123' || password == 'admin123')) {
      setState(() => _isLoading = false);
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid admin credentials. Use official Ministry email and security key.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.navyPrimary, size: 20.0),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: _fillMockAdmin,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.saffronDark,
                backgroundColor: AppColors.saffronLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              ),
              icon: const Icon(Icons.auto_fix_high_rounded, size: 16.0),
              label: const Text(
                'Auto Fill Admin',
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                color: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: const BorderSide(color: AppColors.surfaceBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Central Shield Logo
                        Center(
                          child: Container(
                            width: 68.0,
                            height: 68.0,
                            decoration: BoxDecoration(
                              color: AppColors.saffronLight,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.saffronPrimary, width: 2.0),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings_rounded,
                              color: AppColors.saffronDark,
                              size: 36.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        // Title & Subtitle
                        const Text(
                          'AYUSH Admin Central',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.navyPrimary,
                            fontSize: 22.0,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        const Text(
                          'Authorized Personnel & Verification Authority Only',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.0,
                          ),
                        ),
                        const SizedBox(height: 20.0),

                        // Error Banner
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: const Color(0xFFEF4444)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20.0),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Color(0xFF991B1B), fontSize: 12.0, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16.0),
                        ],

                        // Admin Email Input
                        const Text(
                          'Official Admin Email / Employee ID',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.0,
                            color: AppColors.navyPrimary,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'admin@ayush.gov.in',
                            prefixIcon: Icon(Icons.email_outlined, color: AppColors.saffronPrimary, size: 20.0),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter official admin email.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18.0),

                        // Admin Password Input
                        const Text(
                          'Security Passkey / Password',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.0,
                            color: AppColors.navyPrimary,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: '••••••••••••',
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.saffronPrimary, size: 20.0),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppColors.textMuted,
                                size: 20.0,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter security passkey.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24.0),

                        // Login Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navyPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20.0,
                                  width: 20.0,
                                  child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.lock_open_rounded, size: 18.0),
                                    SizedBox(width: 8.0),
                                    Text('Access Admin Portal', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 16.0),

                        // Demo Credentials Tip
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Row(
                                children: [
                                  Icon(Icons.info_outline_rounded, size: 14.0, color: AppColors.saffronDark),
                                  SizedBox(width: 6.0),
                                  Text(
                                    'Evaluator Demo Credentials',
                                    style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold, color: AppColors.saffronDark),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                'Email: admin@ayush.gov.in\nPasskey: ayushAdmin2026',
                                style: TextStyle(
                                  fontSize: 11.0,
                                  color: AppColors.textSecondary,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
