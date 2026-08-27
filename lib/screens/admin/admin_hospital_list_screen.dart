import 'package:flutter/material.dart';
import '../../models/hospital_model.dart';
import '../../widgets/admin_sidebar.dart';
import 'admin_dashboard_screen.dart';

/// Admin Hospital List Screen supporting multi-field search, status filtering, and persistent sidebar layout.
class AdminHospitalListScreen extends StatelessWidget {
  final VerificationStatus? initialStatus;

  const AdminHospitalListScreen({
    super.key,
    this.initialStatus,
  });

  @override
  Widget build(BuildContext context) {
    AdminSection section = AdminSection.directory;
    if (initialStatus == VerificationStatus.pending) {
      section = AdminSection.pending;
    } else if (initialStatus == VerificationStatus.verified) {
      section = AdminSection.verified;
    } else if (initialStatus == VerificationStatus.rejected) {
      section = AdminSection.rejected;
    }

    return AdminDashboardScreen(initialSection: section);
  }
}
