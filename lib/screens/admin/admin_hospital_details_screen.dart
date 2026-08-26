import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/admin_hospital_model.dart';
import '../../models/hospital_model.dart';
import '../../services/admin_hospital_service.dart';
import '../../widgets/admin_widgets.dart';
import '../../widgets/ayush_widgets.dart';

/// Screen displaying complete AYUSH Hospital Application details, documents, and admin verification actions.
class AdminHospitalDetailsScreen extends StatefulWidget {
  final String hospitalId;

  const AdminHospitalDetailsScreen({
    super.key,
    required this.hospitalId,
  });

  @override
  State<AdminHospitalDetailsScreen> createState() => _AdminHospitalDetailsScreenState();
}

class _AdminHospitalDetailsScreenState extends State<AdminHospitalDetailsScreen> {
  final _service = AdminHospitalService();
  AdminHospitalDetail? _hospital;
  bool _isLoading = true;
  bool _isActionProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadHospitalDetails();
  }

  Future<void> _loadHospitalDetails() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getHospitalDetails(widget.hospitalId);
      setState(() {
        _hospital = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load details: $e')),
        );
      }
    }
  }

  Future<void> _handleStartReview() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: const Text('Start Verification Review'),
        content: const Text(
          'Are you sure you want to start reviewing this hospital registration? The status will be updated to "Under Review".',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navyPrimary,
              foregroundColor: AppColors.background,
            ),
            child: const Text('Start Review'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isActionProcessing = true);
    try {
      final updated = await _service.startReview(_hospital!.id);
      setState(() {
        _hospital = updated;
        _isActionProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hospital status updated to Under Review.'),
            backgroundColor: AppColors.navyLight,
          ),
        );
      }
    } catch (e) {
      setState(() => _isActionProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleApprove() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: Row(
          children: const [
            Icon(Icons.verified_user_rounded, color: AppColors.greenSuccess),
            SizedBox(width: 8.0),
            Text('Approve Hospital'),
          ],
        ),
        content: const Text(
          'Are you sure you want to approve this hospital? Approved hospitals will receive "Verified" status and full access to MediKiosk operational tools.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greenSuccess,
              foregroundColor: AppColors.background,
            ),
            child: const Text('Confirm Approval'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isActionProcessing = true);
    try {
      final updated = await _service.approveHospital(
        _hospital!.id,
        notes: 'Approved by National AYUSH Verification Authority',
      );
      setState(() {
        _hospital = updated;
        _isActionProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hospital registration approved successfully!'),
            backgroundColor: AppColors.greenSuccess,
          ),
        );
      }
    } catch (e) {
      setState(() => _isActionProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleReject() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => RejectReasonDialog(hospitalName: _hospital!.facilityName),
    );

    if (reason == null || reason.trim().isEmpty) return;

    setState(() => _isActionProcessing = true);
    try {
      final updated = await _service.rejectHospital(_hospital!.id, reason.trim());
      setState(() {
        _hospital = updated;
        _isActionProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hospital registration rejected and reason logged.'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
    } catch (e) {
      setState(() => _isActionProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hospital == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Hospital not found')),
      );
    }

    final h = _hospital!;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.navyPrimary, size: 20.0),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          h.applicationId,
          style: const TextStyle(color: AppColors.navyPrimary, fontWeight: FontWeight.w800, fontSize: 18.0),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: StatusBadge(status: h.verificationStatus),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(h),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title Banner
                _buildHeaderBanner(h),
                const SizedBox(height: 20.0),

                // If rejected, show prominent rejection notice
                if (h.verificationStatus == VerificationStatus.rejected && h.rejectionReason != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626)),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Registration Rejected',
                                style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFDC2626), fontSize: 14.0),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                h.rejectionReason!,
                                style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                ],

                // SECTION 1: Facility Details
                _buildSectionCard(
                  title: '1. Facility Details',
                  icon: Icons.local_hospital_rounded,
                  children: [
                    _buildDetailRow('Facility Name', h.facilityName, isPrimary: true),
                    _buildDetailRow('Facility Type', h.facilityType),
                    _buildDetailRow('AYUSH System', h.ayushSystem),
                    _buildDetailRow('State / District', '${h.district}, ${h.state}'),
                    _buildDetailRow('Address', h.address),
                    _buildDetailRow('PIN Code', h.pinCode ?? 'Not Provided'),
                    _buildDetailRow('Official Email', h.officialEmail),
                    _buildDetailRow('Official Phone', h.officialPhone),
                  ],
                ),
                const SizedBox(height: 20.0),

                // SECTION 2: Regulatory Details
                _buildSectionCard(
                  title: '2. Regulatory & Accreditation IDs',
                  icon: Icons.verified_rounded,
                  children: [
                    _buildDetailRow('Registration Number', h.registrationNumber, isPrimary: true),
                    _buildDetailRow('AYUSH ID', h.ayushId ?? 'Not Provided'),
                    _buildDetailRow(
                      'HFR ID (Health Facility Registry)',
                      h.hfrId ?? 'Not Provided (Optional)',
                      isTag: h.hfrId != null,
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),

                // SECTION 3: Authorized Officials
                _buildSectionCard(
                  title: '3. Authorized Representative(s)',
                  icon: Icons.person_rounded,
                  children: h.authorizedOfficials.map((official) {
                    return Container(
                      padding: const EdgeInsets.all(12.0),
                      margin: const EdgeInsets.only(bottom: 8.0),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                official.fullName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: AppColors.navyPrimary),
                              ),
                              if (official.isPrimary)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                  decoration: BoxDecoration(
                                    color: AppColors.saffronLight,
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  child: const Text('Primary Official', style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold, color: AppColors.saffronDark)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4.0),
                          Text('Designation: ${official.designation}', style: const TextStyle(fontSize: 12.0, color: AppColors.textSecondary)),
                          Text('Email: ${official.officialEmail} | Phone: ${official.officialPhone}', style: const TextStyle(fontSize: 12.0, color: AppColors.textMuted)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20.0),

                // SECTION 4: Uploaded Documents
                _buildSectionCard(
                  title: '4. Uploaded Verification Documents',
                  icon: Icons.folder_open_rounded,
                  children: [
                    if (h.documents.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: const Text('No documents uploaded or stored in Supabase storage.'),
                      )
                    else
                      ...h.documents.map((doc) {
                        return Container(
                          padding: const EdgeInsets.all(14.0),
                          margin: const EdgeInsets.only(bottom: 10.0),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFDC2626), size: 28.0),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(doc.originalFilename, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
                                    Text('Type: ${doc.documentType} • Uploaded: ${doc.uploadedAt}', style: const TextStyle(fontSize: 11.0, color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Opening ${doc.originalFilename} preview...')),
                                  );
                                },
                                icon: const Icon(Icons.visibility_outlined, size: 14.0),
                                label: const Text('View', style: TextStyle(fontSize: 12.0)),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
                const SizedBox(height: 20.0),

                // SECTION 5: Verification History Timeline
                _buildSectionCard(
                  title: '5. Verification Audit Trail',
                  icon: Icons.history_rounded,
                  children: [
                    VerificationTimelineWidget(history: h.verificationHistory),
                  ],
                ),
                const SizedBox(height: 40.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner(AdminHospitalDetail h) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: AppColors.saffronLight,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const Icon(Icons.spa_rounded, color: AppColors.saffronDark, size: 32.0),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h.facilityName,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyPrimary,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '${h.ayushSystem} • ${h.facilityType} • Submitted on ${h.createdAt}',
                  style: const TextStyle(fontSize: 12.0, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20.0, color: AppColors.saffronDark),
              const SizedBox(width: 8.0),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navyPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 24.0),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPrimary = false, bool isTag = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180.0,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.0,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: isTag
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: isPrimary ? FontWeight.w800 : FontWeight.w600,
                      color: isPrimary ? AppColors.navyPrimary : AppColors.textPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget? _buildBottomActionBar(AdminHospitalDetail h) {
    if (_isActionProcessing) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        color: AppColors.background,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (h.verificationStatus == VerificationStatus.pending) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: _handleStartReview,
            icon: const Icon(Icons.policy_rounded),
            label: const Text('Start Verification Review'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navyPrimary,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
          ),
        ),
      );
    }

    if (h.verificationStatus == VerificationStatus.under_review) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _handleReject,
                  icon: const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626)),
                  label: const Text('Reject Application', style: TextStyle(color: Color(0xFFDC2626))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFDC2626)),
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _handleApprove,
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('Approve Hospital'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenSuccess,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (h.verificationStatus == VerificationStatus.verified) {
      return Container(
        padding: const EdgeInsets.all(14.0),
        color: AppColors.greenLight,
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.verified_user_rounded, color: AppColors.greenSuccess, size: 20.0),
              SizedBox(width: 8.0),
              Text(
                'Hospital Registration Verified & Active',
                style: TextStyle(color: AppColors.greenSuccess, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    if (h.verificationStatus == VerificationStatus.rejected) {
      return Container(
        padding: const EdgeInsets.all(14.0),
        color: const Color(0xFFFEF2F2),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 20.0),
              SizedBox(width: 8.0),
              Text(
                'Hospital Registration Rejected',
                style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return null;
  }
}
