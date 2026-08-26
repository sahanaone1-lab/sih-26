import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/hospital_model.dart';
import '../../widgets/ayush_widgets.dart';

/// Hospital Profile Screen for AYUSH Hospital Portal.
/// 
/// Displays hospital information, regulatory AYUSH IDs, accreditation certificates,
/// address, contact details, authorized representative, and verification status badge.
/// Allows editing ONLY for permitted fields (contact details, address, representative info),
/// while strictly locking regulatory IDs and verification status.
class HospitalProfileScreen extends StatefulWidget {
  final AyushHospital hospital;

  const HospitalProfileScreen({
    super.key,
    required this.hospital,
  });

  @override
  State<HospitalProfileScreen> createState() => _HospitalProfileScreenState();
}

class _HospitalProfileScreenState extends State<HospitalProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  // Controllers for permitted editable fields
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _authNameController;
  late TextEditingController _authDesignationController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.hospital.officialEmail);
    _phoneController = TextEditingController(text: widget.hospital.phoneNumber);
    _addressController = TextEditingController(text: widget.hospital.address);
    _authNameController = TextEditingController(text: widget.hospital.authorizedPersonName);
    _authDesignationController = TextEditingController(text: widget.hospital.authorizedPersonDesignation);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _authNameController.dispose();
    _authDesignationController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        widget.hospital.officialEmail = _emailController.text.trim();
        widget.hospital.phoneNumber = _phoneController.text.trim();
        widget.hospital.authorizedPersonName = _authNameController.text.trim();
        widget.hospital.authorizedPersonDesignation = _authDesignationController.text.trim();
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permitted profile fields updated successfully.'),
          backgroundColor: AppColors.greenSuccess,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navyPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Hospital Profile',
          style: TextStyle(
            color: AppColors.navyPrimary,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!_isEditing)
            TextButton.icon(
              onPressed: _toggleEdit,
              icon: const Icon(Icons.edit_rounded, size: 16.0, color: AppColors.saffronDark),
              label: const Text(
                'Edit Allowed Fields',
                style: TextStyle(color: AppColors.saffronDark, fontWeight: FontWeight.bold),
              ),
            )
          else
            TextButton.icon(
              onPressed: _toggleEdit,
              icon: const Icon(Icons.close_rounded, size: 16.0, color: AppColors.textSecondary),
              label: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Overview Card
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: AppColors.surfaceBorder),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 12.0,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56.0,
                                height: 56.0,
                                decoration: BoxDecoration(
                                  color: AppColors.saffronLight,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.saffronPrimary, width: 2.0),
                                ),
                                child: const Icon(
                                  Icons.account_balance_rounded,
                                  color: AppColors.saffronDark,
                                  size: 28.0,
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.hospital.hospitalName,
                                      style: const TextStyle(
                                        color: AppColors.navyPrimary,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      widget.hospital.hospitalType,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          const Divider(color: AppColors.surfaceBorder),
                          const SizedBox(height: 12.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Verification Status',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              StatusBadge(status: widget.hospital.verificationStatus),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // SECTION 1: Locked Regulatory & Registration Details
                    _buildSectionHeader('Locked Regulatory Details', Icons.lock_outline_rounded, isLockedSection: true),
                    const SizedBox(height: 12.0),

                    Container(
                      padding: const EdgeInsets.all(18.0),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        children: [
                          _buildLockedField('Hospital Name', widget.hospital.hospitalName, Icons.business_rounded),
                          const SizedBox(height: 12.0),
                          _buildLockedField('Registration Number', widget.hospital.regNumber, Icons.badge_outlined),
                          const SizedBox(height: 12.0),
                          _buildLockedField('AYUSH / FIR ID', widget.hospital.ayushId, Icons.verified_user_outlined),
                          const SizedBox(height: 12.0),
                          _buildLockedField('State', widget.hospital.state, Icons.map_outlined),
                          const SizedBox(height: 12.0),
                          _buildLockedField('District', widget.hospital.district, Icons.location_city_rounded),
                          const SizedBox(height: 12.0),
                          _buildLockedField('Submitted Date', widget.hospital.submittedDate, Icons.calendar_today_outlined),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // SECTION 2: Permitted Editable Contact & Address Information
                    _buildSectionHeader(
                      _isEditing ? 'Editing Permitted Fields' : 'Contact & Address Information',
                      Icons.edit_note_rounded,
                      isLockedSection: false,
                    ),
                    const SizedBox(height: 12.0),

                    Container(
                      padding: const EdgeInsets.all(18.0),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: _isEditing ? AppColors.saffronPrimary : AppColors.surfaceBorder,
                          width: _isEditing ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isEditing) ...[
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _inputDecoration('Official Email (Permitted)', Icons.email_outlined),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Email is required';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14.0),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: _inputDecoration('Phone Number (Permitted)', Icons.phone_outlined),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Phone is required';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14.0),
                            TextFormField(
                              controller: _addressController,
                              decoration: _inputDecoration('Address (Permitted)', Icons.place_outlined),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Address is required';
                                return null;
                              },
                            ),
                          ] else ...[
                            _buildInfoRow('Official Email', _emailController.text, Icons.email_outlined, canEdit: true),
                            const SizedBox(height: 12.0),
                            _buildInfoRow('Phone Number', _phoneController.text, Icons.phone_outlined, canEdit: true),
                            const SizedBox(height: 12.0),
                            _buildInfoRow('Full Address', _addressController.text, Icons.place_outlined, canEdit: true),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // SECTION 3: Authorized Representative Details
                    _buildSectionHeader('Authorized Representative Details', Icons.admin_panel_settings_outlined, isLockedSection: false),
                    const SizedBox(height: 12.0),

                    Container(
                      padding: const EdgeInsets.all(18.0),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: _isEditing ? AppColors.saffronPrimary : AppColors.surfaceBorder,
                          width: _isEditing ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          if (_isEditing) ...[
                            TextFormField(
                              controller: _authNameController,
                              decoration: _inputDecoration('Authorized Person Name (Permitted)', Icons.person_outline_rounded),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Name is required';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14.0),
                            TextFormField(
                              controller: _authDesignationController,
                              decoration: _inputDecoration('Designation (Permitted)', Icons.work_outline_rounded),
                            ),
                          ] else ...[
                            _buildInfoRow('Representative Name', _authNameController.text, Icons.person_outline_rounded, canEdit: true),
                            const SizedBox(height: 12.0),
                            _buildInfoRow('Designation', _authDesignationController.text, Icons.work_outline_rounded, canEdit: true),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32.0),

                    // Save Button when Editing
                    if (_isEditing)
                      SizedBox(
                        height: 52.0,
                        child: ElevatedButton.icon(
                          onPressed: _saveChanges,
                          icon: const Icon(Icons.save_rounded, size: 20.0),
                          label: const Text(
                            'Save Permitted Changes',
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.saffronPrimary,
                            foregroundColor: AppColors.background,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {required bool isLockedSection}) {
    return Row(
      children: [
        Icon(icon, size: 18.0, color: isLockedSection ? AppColors.textMuted : AppColors.navyPrimary),
        const SizedBox(width: 8.0),
        Text(
          title,
          style: TextStyle(
            color: isLockedSection ? AppColors.textSecondary : AppColors.navyPrimary,
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isLockedSection) ...[
          const SizedBox(width: 8.0),
          Tooltip(
            message: 'Regulatory IDs & Accreditation fields are locked and require official clearance to amend.',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.lock_rounded, size: 10.0, color: AppColors.textMuted),
                  SizedBox(width: 4.0),
                  Text(
                    'Locked',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 10.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLockedField(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16.0, color: AppColors.textMuted),
        const SizedBox(width: 10.0),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.navyPrimary,
              fontSize: 13.0,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Icon(Icons.lock_outline_rounded, size: 14.0, color: AppColors.textMuted),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {required bool canEdit}) {
    return Row(
      children: [
        Icon(icon, size: 16.0, color: canEdit ? AppColors.saffronDark : AppColors.textSecondary),
        const SizedBox(width: 10.0),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.navyPrimary,
              fontSize: 13.0,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (canEdit)
          const Icon(Icons.edit_outlined, size: 14.0, color: AppColors.saffronDark),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData prefixIcon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(prefixIcon, color: AppColors.saffronDark, size: 20.0),
      filled: true,
      fillColor: AppColors.saffronLight.withValues(alpha: 0.3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: AppColors.saffronPrimary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: AppColors.saffronPrimary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: AppColors.navyPrimary, width: 1.5),
      ),
    );
  }
}
