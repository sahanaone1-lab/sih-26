import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/admin_hospital_model.dart';
import '../models/hospital_model.dart';
import 'ayush_widgets.dart';

/// Reusable Admin Stat Card with custom accents and click-to-filter callback
class AdminStatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final bool isSelected;
  final VoidCallback? onTap;

  const AdminStatCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? backgroundColor.withValues(alpha: 0.8) : AppColors.background,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected ? color : AppColors.surfaceBorder,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? color.withValues(alpha: 0.15) : AppColors.cardShadow,
              blurRadius: 10.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Icon(icon, color: color, size: 22.0),
                ),
                Text(
                  count.toString(),
                  style: TextStyle(
                    color: color,
                    fontSize: 26.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.navyPrimary,
                fontSize: 13.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status Filter Pill Bar
class HospitalStatusFilterBar extends StatelessWidget {
  final VerificationStatus? selectedStatus;
  final ValueChanged<VerificationStatus?> onStatusSelected;

  const HospitalStatusFilterBar({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All Hospitals', null),
          const SizedBox(width: 8.0),
          _buildFilterChip('Pending', VerificationStatus.pending),
          const SizedBox(width: 8.0),
          _buildFilterChip('Under Review', VerificationStatus.under_review),
          const SizedBox(width: 8.0),
          _buildFilterChip('Verified', VerificationStatus.verified),
          const SizedBox(width: 8.0),
          _buildFilterChip('Rejected', VerificationStatus.rejected),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VerificationStatus? status) {
    final isSelected = selectedStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onStatusSelected(status),
      selectedColor: AppColors.saffronPrimary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.background : AppColors.navyPrimary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12.0,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.saffronPrimary : AppColors.surfaceBorder,
      ),
    );
  }
}

/// Desktop Data Table for Hospitals
class HospitalDataTable extends StatelessWidget {
  final List<AdminHospitalDetail> hospitals;
  final ValueChanged<AdminHospitalDetail> onHospitalTap;

  const HospitalDataTable({
    super.key,
    required this.hospitals,
    required this.onHospitalTap,
  });

  @override
  Widget build(BuildContext context) {
    if (hospitals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.search_off_rounded, size: 48.0, color: AppColors.textMuted),
            SizedBox(height: 12.0),
            Text(
              'No hospitals found matching criteria',
              style: TextStyle(color: AppColors.navyPrimary, fontSize: 16.0, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4.0),
            Text(
              'Try changing your status filter or search keywords.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.0),
            ),
          ],
        ),
      );
    }

    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.surface),
            horizontalMargin: 20.0,
            columnSpacing: 24.0,
            columns: const [
              DataColumn(label: Text('Facility Name', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Application ID', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('System / Type', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('State / District', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Submitted', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: hospitals.map((hospital) {
              return DataRow(
                cells: [
                  DataCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hospital.facilityName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.navyPrimary,
                          ),
                        ),
                        if (hospital.hfrId != null)
                          Text(
                            'HFR: ${hospital.hfrId}',
                            style: const TextStyle(fontSize: 11.0, color: AppColors.textMuted),
                          ),
                      ],
                    ),
                  ),
                  DataCell(Text(hospital.applicationId, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text('${hospital.ayushSystem} • ${hospital.facilityType}')),
                  DataCell(Text('${hospital.district}, ${hospital.state}')),
                  DataCell(StatusBadge(status: hospital.verificationStatus)),
                  DataCell(Text(hospital.createdAt)),
                  DataCell(
                    ElevatedButton(
                      onPressed: () => onHospitalTap(hospital),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hospital.verificationStatus == VerificationStatus.pending
                            ? AppColors.saffronPrimary
                            : AppColors.navyPrimary,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      child: Text(
                        hospital.verificationStatus == VerificationStatus.pending ? 'Review' : 'View Details',
                        style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// Mobile Card representation of a hospital
class HospitalMobileCard extends StatelessWidget {
  final AdminHospitalDetail hospital;
  final VoidCallback onTap;

  const HospitalMobileCard({
    super.key,
    required this.hospital,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      hospital.facilityName,
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navyPrimary,
                      ),
                    ),
                  ),
                  StatusBadge(status: hospital.verificationStatus),
                ],
              ),
              const SizedBox(height: 6.0),
              Text(
                '${hospital.applicationId} • ${hospital.ayushSystem}',
                style: const TextStyle(fontSize: 12.0, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4.0),
              Text(
                '${hospital.district}, ${hospital.state}',
                style: const TextStyle(fontSize: 12.0, color: AppColors.textMuted),
              ),
              const Divider(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Submitted: ${hospital.createdAt}',
                      style: const TextStyle(fontSize: 11.0, color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hospital.verificationStatus == VerificationStatus.pending ? 'Review' : 'View',
                        style: const TextStyle(
                          color: AppColors.saffronDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.0,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12.0, color: AppColors.saffronDark),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rejection Modal Dialog with mandatory reason input
class RejectReasonDialog extends StatefulWidget {
  final String hospitalName;

  const RejectReasonDialog({
    super.key,
    required this.hospitalName,
  });

  @override
  State<RejectReasonDialog> createState() => _RejectReasonDialogState();
}

class _RejectReasonDialogState extends State<RejectReasonDialog> {
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      title: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
          SizedBox(width: 8.0),
          Text('Reject Hospital Application'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please specify the reason for rejecting ${widget.hospitalName}. This reason will be recorded in the verification audit trail.',
              style: const TextStyle(fontSize: 13.0, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter rejection reason (e.g. Invalid license, document mismatch)...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                filled: true,
                fillColor: AppColors.surface,
              ),
              validator: (val) {
                if (val == null || val.trim().length < 5) {
                  return 'Please provide a valid reason (min 5 characters).';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop(_reasonController.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: AppColors.background,
          ),
          child: const Text('Reject Registration'),
        ),
      ],
    );
  }
}

/// Vertical Verification History Timeline Widget
class VerificationTimelineWidget extends StatelessWidget {
  final List<VerificationHistoryItem> history;

  const VerificationTimelineWidget({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Text('No verification history recorded yet.');
    }

    return Column(
      children: List.generate(history.length, (index) {
        final item = history[index];
        final isLast = index == history.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 14.0,
                  height: 14.0,
                  decoration: BoxDecoration(
                    color: _getActionColor(item.action),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2.0,
                    height: 50.0,
                    color: AppColors.surfaceBorder,
                  ),
              ],
            ),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatActionTitle(item.action),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.0,
                          color: AppColors.navyPrimary,
                        ),
                      ),
                      Text(
                        item.createdAt,
                        style: const TextStyle(fontSize: 11.0, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  if (item.notes != null) ...[
                    const SizedBox(height: 2.0),
                    Text(
                      item.notes!,
                      style: const TextStyle(fontSize: 12.0, color: AppColors.textSecondary),
                    ),
                  ],
                  if (item.rejectionReason != null) ...[
                    const SizedBox(height: 2.0),
                    Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        'Reason: ${item.rejectionReason!}',
                        style: const TextStyle(fontSize: 11.0, color: Color(0xFFDC2626), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Color _getActionColor(String action) {
    switch (action.toLowerCase()) {
      case 'hospital_approved':
        return AppColors.greenSuccess;
      case 'hospital_rejected':
        return const Color(0xFFDC2626);
      case 'moved_to_under_review':
        return AppColors.navyLight;
      case 'registration_submitted':
      default:
        return AppColors.saffronPrimary;
    }
  }

  String _formatActionTitle(String action) {
    switch (action.toLowerCase()) {
      case 'hospital_approved':
        return 'Registration Approved (Verified)';
      case 'hospital_rejected':
        return 'Registration Rejected';
      case 'moved_to_under_review':
        return 'Moved to Under Review';
      case 'registration_submitted':
        return 'Registration Submitted';
      default:
        return action;
    }
  }
}
