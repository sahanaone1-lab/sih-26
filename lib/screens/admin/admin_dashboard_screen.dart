import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/admin_hospital_model.dart';
import '../../models/hospital_model.dart';
import '../../services/admin_hospital_service.dart';
import '../../widgets/admin_widgets.dart';
import 'admin_hospital_details_screen.dart';
import 'admin_hospital_list_screen.dart';

/// Admin Dashboard Screen for MediKiosk / AYUSH Verification Portal.
/// Responsive layout supporting Desktop (sidebar + wide grid), Tablet, and Mobile.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _service = AdminHospitalService();
  late Map<String, int> _stats;
  List<AdminHospitalDetail> _recentHospitals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _stats = _service.getStatistics();
    final hospitals = await _service.getHospitals();
    setState(() {
      _recentHospitals = hospitals.take(5).toList();
      _isLoading = false;
    });
  }

  void _navigateToDetails(AdminHospitalDetail hospital) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdminHospitalDetailsScreen(hospitalId: hospital.id),
      ),
    );
    _loadData();
  }

  void _navigateToList({VerificationStatus? status}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdminHospitalListScreen(initialStatus: status),
      ),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              title: const Text(
                'AYUSH Admin Portal',
                style: TextStyle(color: AppColors.navyPrimary, fontWeight: FontWeight.w800, fontSize: 18.0),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.navyPrimary),
                  onPressed: _loadData,
                ),
              ],
            ),
      drawer: isDesktop ? null : _buildMobileDrawer(),
      body: isDesktop
          ? Row(
              children: [
                _buildDesktopSidebar(),
                Expanded(child: _buildMainContent(isDesktop: true)),
              ],
            )
          : _buildMainContent(isDesktop: false),
    );
  }

  Widget _buildDesktopSidebar() {
    return Container(
      width: 260.0,
      decoration: const BoxDecoration(
        color: AppColors.navyPrimary,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: AppColors.saffronPrimary,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Icon(Icons.verified_user_rounded, color: AppColors.background, size: 24.0),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'MEDIKIOSK',
                        style: TextStyle(color: AppColors.background, fontWeight: FontWeight.w900, fontSize: 16.0, letterSpacing: 1.0),
                      ),
                      Text(
                        'Admin Central Portal',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF1E3A8A), height: 1.0),
          const SizedBox(height: 16.0),
          _buildSidebarItem(
            icon: Icons.dashboard_rounded,
            title: 'Overview Dashboard',
            isSelected: true,
            onTap: () {},
          ),
          _buildSidebarItem(
            icon: Icons.hourglass_top_rounded,
            title: 'Pending Reviews',
            badgeCount: _stats['pending'],
            badgeColor: AppColors.saffronPrimary,
            onTap: () => _navigateToList(status: VerificationStatus.pending),
          ),
          _buildSidebarItem(
            icon: Icons.local_hospital_rounded,
            title: 'Hospital Directory',
            onTap: () => _navigateToList(),
          ),
          _buildSidebarItem(
            icon: Icons.verified_rounded,
            title: 'Verified Facilities',
            onTap: () => _navigateToList(status: VerificationStatus.verified),
          ),
          _buildSidebarItem(
            icon: Icons.cancel_outlined,
            title: 'Rejected Applications',
            onTap: () => _navigateToList(status: VerificationStatus.rejected),
          ),
          const Divider(color: Color(0xFF1E3A8A), height: 24.0),
          _buildSidebarItem(
            icon: Icons.domain_rounded,
            title: 'Hospital Portal',
            onTap: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/register', (route) => false);
            },
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF040D1A),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.saffronLight,
                  child: Icon(Icons.person_rounded, color: AppColors.saffronDark),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Verification Officer',
                        style: TextStyle(color: AppColors.background, fontSize: 12.0, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Ministry of Ayush',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 10.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    bool isSelected = false,
    int? badgeCount,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Material(
        color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
        borderRadius: BorderRadius.circular(10.0),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          leading: Icon(icon, color: isSelected ? AppColors.saffronPrimary : AppColors.textMuted, size: 20.0),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? AppColors.background : const Color(0xFFCBD5E1),
              fontSize: 13.0,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          trailing: (badgeCount != null && badgeCount > 0)
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: badgeColor ?? AppColors.navyLight,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(color: AppColors.background, fontSize: 11.0, fontWeight: FontWeight.bold),
                  ),
                )
              : null,
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: AppColors.navyPrimary,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF040D1A)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.verified_user_rounded, color: AppColors.saffronPrimary, size: 36.0),
                SizedBox(height: 10.0),
                Text('MediKiosk Admin Portal', style: TextStyle(color: AppColors.background, fontSize: 16.0, fontWeight: FontWeight.bold)),
                Text('Ministry of Ayush', style: TextStyle(color: AppColors.textMuted, fontSize: 12.0)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded, color: AppColors.saffronPrimary),
            title: const Text('Dashboard', style: TextStyle(color: AppColors.background)),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            leading: const Icon(Icons.hourglass_top_rounded, color: AppColors.saffronDark),
            title: const Text('Pending Reviews', style: TextStyle(color: AppColors.background)),
            trailing: _stats['pending']! > 0
                ? CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.saffronPrimary,
                    child: Text(_stats['pending'].toString(), style: const TextStyle(color: Colors.white, fontSize: 11)),
                  )
                : null,
            onTap: () {
              Navigator.of(context).pop();
              _navigateToList(status: VerificationStatus.pending);
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_hospital_rounded, color: Color(0xFFCBD5E1)),
            title: const Text('All Hospitals', style: TextStyle(color: AppColors.background)),
            onTap: () {
              Navigator.of(context).pop();
              _navigateToList();
            },
          ),
          const Divider(color: Color(0xFF1E3A8A)),
          ListTile(
            leading: const Icon(Icons.domain_rounded, color: AppColors.saffronPrimary),
            title: const Text('Hospital Portal', style: TextStyle(color: AppColors.background)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamedAndRemoveUntil('/register', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent({required bool isDesktop}) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Verification Management Dashboard',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w900,
                          color: AppColors.navyPrimary,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'Review, verify, and monitor national AYUSH health institution registrations',
                        style: TextStyle(fontSize: 13.0, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton.icon(
                  onPressed: () => _navigateToList(status: VerificationStatus.pending),
                  icon: const Icon(Icons.rate_review_rounded, size: 18.0),
                  label: const Text('Review Pending Hospitals'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.saffronPrimary,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
          ],

          // 1. Statistics Cards Grid
          _buildStatsGrid(isDesktop),

          const SizedBox(height: 24.0),

          // 2. Pending Action Banner
          if (_stats['pending']! > 0) ...[
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.saffronLight,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: AppColors.saffronPrimary.withValues(alpha: 0.5)),
              ),
              child: isDesktop
                  ? Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: const BoxDecoration(
                            color: AppColors.saffronPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notification_important_rounded, color: AppColors.background, size: 24.0),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_stats['pending']} Hospital Registrations Require Action',
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.navyPrimary,
                                ),
                              ),
                              const SizedBox(height: 2.0),
                              const Text(
                                'New AYUSH facilities have submitted regulatory documentation awaiting admin verification.',
                                style: TextStyle(fontSize: 12.0, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        ElevatedButton(
                          onPressed: () => _navigateToList(status: VerificationStatus.pending),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.saffronDark,
                            foregroundColor: AppColors.background,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          child: const Text('Start Review'),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: const BoxDecoration(
                                color: AppColors.saffronPrimary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notification_important_rounded, color: AppColors.background, size: 18.0),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Text(
                                '${_stats['pending']} Registrations Need Review',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.navyPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          'New AYUSH facilities have submitted regulatory documentation awaiting admin verification.',
                          style: TextStyle(fontSize: 12.0, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _navigateToList(status: VerificationStatus.pending),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.saffronDark,
                              foregroundColor: AppColors.background,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ),
                            child: const Text('Start Review'),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 28.0),
          ],

          // 3. Recent Registrations Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Recent Hospital Registrations',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navyPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _navigateToList(),
                child: const Text('View All →'),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Render Table on Desktop, Cards on Mobile
          isDesktop
              ? HospitalDataTable(
                  hospitals: _recentHospitals,
                  onHospitalTap: _navigateToDetails,
                )
              : Column(
                  children: _recentHospitals
                      .map((h) => HospitalMobileCard(
                            hospital: h,
                            onTap: () => _navigateToDetails(h),
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(bool isDesktop) {
    final cards = [
      AdminStatCard(
        title: 'Total Hospitals',
        count: _stats['total'] ?? 0,
        icon: Icons.business_rounded,
        color: AppColors.navyPrimary,
        backgroundColor: AppColors.surface,
        onTap: () => _navigateToList(),
      ),
      AdminStatCard(
        title: 'Pending Review',
        count: _stats['pending'] ?? 0,
        icon: Icons.hourglass_top_rounded,
        color: AppColors.saffronPrimary,
        backgroundColor: AppColors.saffronLight,
        onTap: () => _navigateToList(status: VerificationStatus.pending),
      ),
      AdminStatCard(
        title: 'Under Review',
        count: _stats['under_review'] ?? 0,
        icon: Icons.policy_rounded,
        color: AppColors.navyLight,
        backgroundColor: const Color(0xFFEFF6FF),
        onTap: () => _navigateToList(status: VerificationStatus.under_review),
      ),
      AdminStatCard(
        title: 'Verified Active',
        count: _stats['verified'] ?? 0,
        icon: Icons.verified_user_rounded,
        color: AppColors.greenSuccess,
        backgroundColor: AppColors.greenLight,
        onTap: () => _navigateToList(status: VerificationStatus.verified),
      ),
      AdminStatCard(
        title: 'Rejected',
        count: _stats['rejected'] ?? 0,
        icon: Icons.cancel_outlined,
        color: const Color(0xFFDC2626),
        backgroundColor: const Color(0xFFFEF2F2),
        onTap: () => _navigateToList(status: VerificationStatus.rejected),
      ),
    ];

    if (isDesktop) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 1100 ? 5 : 3;
          return GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            shrinkWrap: true,
            childAspectRatio: 1.6,
            physics: const NeverScrollableScrollPhysics(),
            children: cards,
          );
        },
      );
    } else {
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        shrinkWrap: true,
        childAspectRatio: 1.4,
        physics: const NeverScrollableScrollPhysics(),
        children: cards,
      );
    }
  }
}
