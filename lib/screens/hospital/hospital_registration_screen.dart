import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/hospital_model.dart';
import '../../services/admin_hospital_service.dart';
import '../../widgets/ayush_widgets.dart';
import '../admin/admin_dashboard_screen.dart';
import '../auth/login_screen.dart';
import 'registration_submitted_screen.dart';

/// AYUSH Hospital Registration Screen for MediKiosk platform.
///
/// Allows AYUSH health institutions to submit registration details, regulatory AYUSH IDs,
/// facility information, authorized official credentials, and verification certificates.
class HospitalRegistrationScreen extends StatefulWidget {
  const HospitalRegistrationScreen({super.key});

  @override
  State<HospitalRegistrationScreen> createState() =>
      _HospitalRegistrationScreenState();
}

class _HospitalRegistrationScreenState
    extends State<HospitalRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _hospitalNameController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _ayushIdController = TextEditingController();
  final _addressController = TextEditingController();
  final _districtController = TextEditingController();
  final _authorizedPersonController = TextEditingController();
  final _authorizedDesignationController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State values
  String? _selectedHospitalType = 'Government AYUSH Institute';
  String? _selectedState = 'Rajasthan';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // File upload state
  String? _regCertFileName;
  String? _authPersonIdFileName;
  bool _showDocUploadError = false;

  final List<String> _hospitalTypes = [
    'Government AYUSH Institute',
    'AYUSH Medical College Hospital',
    'Private AYUSH Hospital',
    'Trust / NGO AYUSH Center',
    'Specialized Ayurvedic Research Center',
    'Unani / Siddha / Homeopathy Hospital',
  ];

  final List<String> _indianStates = [
    'Andhra Pradesh',
    'Assam',
    'Bihar',
    'Delhi',
    'Gujarat',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'New Delhi',
    'Punjab',
    'Rajasthan',
    'Tamil Nadu',
    'Telangana',
    'Uttar Pradesh',
    'West Bengal',
  ];

  @override
  void dispose() {
    _hospitalNameController.dispose();
    _regNumberController.dispose();
    _ayushIdController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    _authorizedPersonController.dispose();
    _authorizedDesignationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    setState(() {
      _showDocUploadError =
          _regCertFileName == null || _authPersonIdFileName == null;
    });

    if ((_formKey.currentState?.validate() ?? false) && !_showDocUploadError) {
      final newHospital = AyushHospital(
        applicationId:
            'AYUSH-HOSP-${DateTime.now().year}-${(10000 + DateTime.now().millisecondsSinceEpoch % 90000)}',
        hospitalName: _hospitalNameController.text.trim(),
        regNumber: _regNumberController.text.trim(),
        ayushId: _ayushIdController.text.trim(),
        address: _addressController.text.trim(),
        state: _selectedState ?? 'Rajasthan',
        district: _districtController.text.trim(),
        hospitalType: _selectedHospitalType ?? 'Government AYUSH Institute',
        authorizedPersonName: _authorizedPersonController.text.trim(),
        authorizedPersonDesignation:
            _authorizedDesignationController.text.trim().isEmpty
            ? 'Authorized Representative'
            : _authorizedDesignationController.text.trim(),
        officialEmail: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
        regCertFileName: _regCertFileName,
        authorizedPersonIdFileName: _authPersonIdFileName,
        verificationStatus: VerificationStatus.pending,
        submittedDate: '${DateTime.now().day} August ${DateTime.now().year}',
      );

      // Save hospital registration data to shared AdminHospitalService (singleton source of truth)
      AdminHospitalService().registerHospital(newHospital);

      // Navigate to RegistrationSubmittedScreen (Pending Verification page) using replacement navigation
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              RegistrationSubmittedScreen(hospital: newHospital),
        ),
      );
    } else if (_showDocUploadError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please upload both the Hospital Registration Certificate and Authorized Person ID.',
          ),
          backgroundColor: AppColors.saffronDark,
        ),
      );
    }
  }

  /// Pre-fills demo details for fast evaluator testing
  void _fillMockData() {
    setState(() {
      _hospitalNameController.text = 'National Institute of Ayurveda Hospital';
      _regNumberController.text = 'AYUSH-RJ-2024-0091';
      _ayushIdController.text = 'AYUSH/FIR/2026/0482';
      _addressController.text = 'Jorawar Singh Gate, Amer Road';
      _districtController.text = 'Jaipur';
      _selectedState = 'Rajasthan';
      _selectedHospitalType = 'Government AYUSH Institute';
      _authorizedPersonController.text = 'Dr. Rajeshwar Sharma';
      _authorizedDesignationController.text = 'Chief Medical Superintendent';
      _emailController.text = 'contact@nia.ayush.gov.in';
      _phoneController.text = '9829012345';
      _passwordController.text = 'password123';
      _confirmPasswordController.text = 'password123';
      _regCertFileName = 'ayush_reg_certificate_2026.pdf';
      _authPersonIdFileName = 'authorized_person_id_card.pdf';
      _showDocUploadError = false;
    });
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
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: _fillMockData,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.saffronDark,
                backgroundColor: AppColors.saffronLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              icon: const Icon(Icons.auto_fix_high_rounded, size: 16.0),
              label: const Text(
                'Auto Fill',
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Form(
                key: _formKey,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 580;

                    Widget responsiveGrid(Widget left, Widget right) {
                      if (isMobile) {
                        return Column(
                          children: [left, const SizedBox(height: 16.0), right],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: left),
                          const SizedBox(width: 16.0),
                          Expanded(child: right),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Page Banner
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.navyPrimary,
                                AppColors.navyDark,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'AYUSH Hospital Portal Registration',
                                style: TextStyle(
                                  color: AppColors.background,
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6.0),
                              Text(
                                'Register your Ayurveda, Unani, Siddha, or Homeopathy facility to connect with MediKiosk AI Clinical Intake & ABDM ecosystem.',
                                style: TextStyle(
                                  color: AppColors.surfaceBorder,
                                  fontSize: 13.0,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28.0),

                        // Section 1: Hospital Facility Credentials
                        _buildSectionTitle(
                          '1. AYUSH Facility Details',
                          Icons.local_hospital_rounded,
                        ),
                        const SizedBox(height: 14.0),

                        TextFormField(
                          controller: _hospitalNameController,
                          decoration: _inputDecoration(
                            'Hospital Name *',
                            Icons.business_rounded,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the official hospital name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),

                        responsiveGrid(
                          TextFormField(
                            controller: _regNumberController,
                            decoration: _inputDecoration(
                              'Hospital Registration Number *',
                              Icons.badge_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Hospital Registration Number is required';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _ayushIdController,
                            decoration: _inputDecoration(
                              'AYUSH / FIR ID *',
                              Icons.verified_user_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'AYUSH / FIR ID is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        responsiveGrid(
                          DropdownButtonFormField<String>(
                            initialValue: _selectedHospitalType,
                            isExpanded: true,
                            decoration: _inputDecoration(
                              'Hospital Type *',
                              Icons.domain_rounded,
                            ),
                            items: _hospitalTypes
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(
                                      t,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedHospitalType = val),
                          ),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedState,
                            isExpanded: true,
                            decoration: _inputDecoration(
                              'State *',
                              Icons.map_outlined,
                            ),
                            items: _indianStates
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      s,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedState = val),
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        responsiveGrid(
                          TextFormField(
                            controller: _districtController,
                            decoration: _inputDecoration(
                              'District *',
                              Icons.location_city_rounded,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter the district';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _addressController,
                            decoration: _inputDecoration(
                              'Hospital Address *',
                              Icons.place_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter the complete hospital address';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 28.0),

                        // Section 2: Authorized Representative & Contact Info
                        _buildSectionTitle(
                          '2. Authorized Representative & Contact',
                          Icons.admin_panel_settings_outlined,
                        ),
                        const SizedBox(height: 14.0),

                        responsiveGrid(
                          TextFormField(
                            controller: _authorizedPersonController,
                            decoration: _inputDecoration(
                              'Authorized Person Name *',
                              Icons.person_outline_rounded,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter authorized person name';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _authorizedDesignationController,
                            decoration: _inputDecoration(
                              'Designation',
                              Icons.work_outline_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        responsiveGrid(
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              'Official Email *',
                              Icons.email_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Official Email is required';
                              }
                              final emailRegex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: _inputDecoration(
                              'Phone Number *',
                              Icons.phone_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Phone Number is required';
                              }
                              final phoneDigits = value.replaceAll(
                                RegExp(r'\D'),
                                '',
                              );
                              if (phoneDigits.length < 10) {
                                return 'Please enter a valid 10-digit phone number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 28.0),

                        // Section 3: Account Credentials
                        _buildSectionTitle(
                          '3. Security & Password',
                          Icons.lock_outline_rounded,
                        ),
                        const SizedBox(height: 14.0),

                        responsiveGrid(
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration:
                                _inputDecoration(
                                  'Password *',
                                  Icons.lock_outline,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration:
                                _inputDecoration(
                                  'Confirm Password *',
                                  Icons.lock_outline,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () => setState(
                                      () => _obscureConfirmPassword =
                                          !_obscureConfirmPassword,
                                    ),
                                  ),
                                ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 28.0),

                        // Section 4: Document Verification Uploads
                        _buildSectionTitle(
                          '4. Upload Verification Certificates',
                          Icons.file_present_rounded,
                        ),
                        const SizedBox(height: 14.0),

                        responsiveGrid(
                          UploadCard(
                            title: 'Hospital Registration Certificate *',
                            fileName: _regCertFileName,
                            subtitle: 'Upload Certificate (PDF/JPG)',
                            onTap: () {
                              setState(() {
                                _regCertFileName =
                                    'hospital_ayush_certificate.pdf';
                                _showDocUploadError = false;
                              });
                            },
                          ),
                          UploadCard(
                            title: 'Authorized Person ID *',
                            fileName: _authPersonIdFileName,
                            subtitle: 'Upload Govt ID / Aadhaar (PDF/JPG)',
                            onTap: () {
                              setState(() {
                                _authPersonIdFileName =
                                    'authorized_person_govt_id.pdf';
                                _showDocUploadError = false;
                              });
                            },
                          ),
                        ),
                        if (_showDocUploadError) ...[
                          const SizedBox(height: 8.0),
                          const Text(
                            '* Both documents are required for AYUSH verification clearance.',
                            style: TextStyle(
                              color: AppColors.saffronDark,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 36.0),

                        // Submit Button: Register Hospital
                        SizedBox(
                          height: 54.0,
                          child: ElevatedButton.icon(
                            onPressed: _submitForm,
                            icon: const Icon(
                              Icons.how_to_reg_rounded,
                              size: 22.0,
                            ),
                            label: const Text(
                              'Register Hospital',
                              style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.saffronPrimary,
                              foregroundColor: AppColors.background,
                              elevation: 2.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),

                        // Link to Login wrapped cleanly to prevent overflow
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'Already registered your hospital?',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13.0,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Go to Hospital Login',
                                style: TextStyle(
                                  color: AppColors.navyPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24.0),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.navyPrimary, size: 20.0),
        const SizedBox(width: 8.0),
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.navyPrimary,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData prefixIcon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary, size: 20.0),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 14.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: AppColors.surfaceBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: AppColors.surfaceBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: AppColors.navyPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
    );
  }
}
