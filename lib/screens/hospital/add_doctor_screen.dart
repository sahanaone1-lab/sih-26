import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../widgets/ayush_widgets.dart';
import '../../services/doctor_service.dart';
import '../../models/hospital_model.dart';

class AddDoctorScreen extends StatefulWidget {
  final AyushHospital hospital;

  const AddDoctorScreen({super.key, required this.hospital});

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specializationController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _registrationNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerDoctor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final payload = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'phone': _phoneController.text,
        'specialization': _specializationController.text,
        'registration_number': _registrationNumberController.text,
        'hospital_id': widget.hospital.id,
      };

      await DoctorService().registerDoctor(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doctor registered successfully!'),
            backgroundColor: AppColors.greenSuccess,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: AppColors.saffronDark,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
        iconTheme: const IconThemeData(color: AppColors.navyPrimary),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Add New Doctor',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.navyPrimary,
                        fontSize: 24.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      'Register a new doctor for your hospital',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 32.0),

                    // Name Fields
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: 'First Name *',
                              filled: true,
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                            ),
                            validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: 'Last Name *',
                              filled: true,
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                            ),
                            validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // Email and Phone
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address *',
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                      ),
                      validator: (val) => (val == null || !val.contains('@')) ? 'Invalid Email' : null,
                    ),
                    const SizedBox(height: 16.0),

                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Specialization and Reg Number
                    TextFormField(
                      controller: _specializationController,
                      decoration: InputDecoration(
                        labelText: 'Specialization *',
                        prefixIcon: const Icon(Icons.local_hospital_outlined),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                      ),
                      validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16.0),

                    TextFormField(
                      controller: _registrationNumberController,
                      decoration: InputDecoration(
                        labelText: 'Medical Registration Number *',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                      ),
                      validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16.0),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password *',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                      ),
                      validator: (val) => (val == null || val.length < 6) ? 'Must be at least 6 characters' : null,
                    ),
                    const SizedBox(height: 32.0),

                    // Submit Button
                    SizedBox(
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _registerDoctor,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.saffronPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Register Doctor',
                                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                              ),
                      ),
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
