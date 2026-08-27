import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/admin_hospital_model.dart';
import '../../models/hospital_model.dart';
import '../../services/admin_hospital_service.dart';
import '../../widgets/admin_sidebar.dart';
import '../../widgets/admin_widgets.dart';
import 'admin_hospital_details_screen.dart';

/// Master Admin Dashboard Screen for MediKiosk / AYUSH Verification Portal.
///
/// Features a single persistent left sidebar across all 5 main sections:
///   1. Overview Dashboard
///   2. Pending Reviews
///   3. Hospital Directory
///   4. Verified Facilities
///   5. Rejected Applications
class AdminDashboardScreen extends StatefulWidget {
  final AdminSection initialSection;

  const AdminDashboardScreen({
    super.key,
    this.initialSection = AdminSection.overview,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _service = AdminHospitalService();
  final _searchController = TextEditingController();

  late AdminSection _currentSection;
  late Map<String, int> _stats;
  List<AdminHospitalDetail> _recentHospitals = [];
  List<AdminHospitalDetail> _filteredHospitals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentSection = widget.initialSection;
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _stats = _service.getStatistics();
    final allHospitals = await _service.getHospitals();

    // Determine status filter based on current section
    final statusFilter = _getStatusForSection(_currentSection);

    final filtered = await _service.getHospitals(
      status: statusFilter,
      search: _searchController.text,
    );

    setState(() {
      _recentHospitals = allHospitals.take(5).toList();
      _filteredHospitals = filtered;
      _isLoading = false;
    });
  }

  VerificationStatus? _getStatusForSection(AdminSection section) {
    switch (section) {
      case AdminSection.pending:
        return VerificationStatus.pending;
      case AdminSection.verified:
        return VerificationStatus.verified;
      case AdminSection.rejected:
        return VerificationStatus.rejected;
      case AdminSection.directory:
      case AdminSection.overview:
        return null;
    }
  }

  void _onSectionSelected(AdminSection section) {
    setState(() {
      _currentSection = section;
      _searchController.clear();
    });
    _loadData();
  }

  void _onStatusFilterChanged(VerificationStatus? status) {
    setState(() {
      if (status == null) {
        _currentSection = AdminSection.directory;
      } else if (status == VerificationStatus.pending) {
        _currentSection = AdminSection.pending;
      } else if (status == VerificationStatus.verified) {
        _currentSection = AdminSection.verified;
      } else if (status == VerificationStatus.rejected) {
        _currentSection = AdminSection.rejected;
      } else if (status == VerificationStatus.under_review) {
        _currentSection = AdminSection.directory;
      }
    });
    _loadData();
  }

  void _navigateToDetails(AdminHospitalDetail hospital) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdminHospitalDetailsScreen(hospitalId: hospital.id),
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
              title: Text(
                _getSectionTitle(_currentSection),
                style: const TextStyle(
                  color: AppColors.navyPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18.0,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.navyPrimary),
                  onPressed: _loadData,
                ),
              ],
            ),
      drawer: isDesktop
          ? null
          : AdminMobileDrawer(
              currentSection: _currentSection,
              onSectionSelected: _onSectionSelected,
              pendingCount: _stats['pending'],
            ),
      body: isDesktop
          ? Row(
              children: [
                // Persistent Left Sidebar
                AdminSidebar(
                  currentSection: _currentSection,
                  onSectionSelected: _onSectionSelected,
                  pendingCount: _stats['pending'],
                ),
                // Main Content Area
                Expanded(
                  child: _buildMainContent(isDesktop: true),
                ),
              ],
            )
          : _buildMainContent(isDesktop: false),
    );
  }

  String _getSectionTitle(AdminSection section) {
    switch (section) {
      case AdminSection.overview:
        return 'AYUSH Admin Portal';
      case AdminSection.pending:
        return 'Pending Reviews';
      case AdminSection.directory:
        return 'Hospital Directory & Reviews';
      case AdminSection.verified:
        return 'Verified Facilities';
      case AdminSection.rejected:
        return 'Rejected Applications';
    }
  }

  Widget _buildMainContent({required bool isDesktop}) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentSection == AdminSection.overview) {
      return _buildOverviewSection(isDesktop: isDesktop);
    } else {
      return _buildDirectorySection(isDesktop: isDesktop);
    }
  }

  // ── 1. OVERVIEW DASHBOARD CONTENT ──────────────────────────────────────────

  Widget _buildOverviewSection({required bool isDesktop}) {
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
                  onPressed: () => _onSectionSelected(AdminSection.pending),
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

          // Statistics Cards Grid
          _buildStatsGrid(isDesktop),

          const SizedBox(height: 24.0),

          // Pending Action Banner
          if ((_stats['pending'] ?? 0) > 0) ...[
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
                          child: const Icon(Icons.notification_important_rounded,
                              color: AppColors.background, size: 24.0),
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
                          onPressed: () => _onSectionSelected(AdminSection.pending),
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
                              child: const Icon(Icons.notification_important_rounded,
                                  color: AppColors.background, size: 18.0),
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
                            onPressed: () => _onSectionSelected(AdminSection.pending),
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

          // Recent Registrations Header
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
                onPressed: () => _onSectionSelected(AdminSection.directory),
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
        isSelected: _currentSection == AdminSection.directory,
        onTap: () => _onSectionSelected(AdminSection.directory),
      ),
      AdminStatCard(
        title: 'Pending Review',
        count: _stats['pending'] ?? 0,
        icon: Icons.hourglass_top_rounded,
        color: AppColors.saffronPrimary,
        backgroundColor: AppColors.saffronLight,
        isSelected: _currentSection == AdminSection.pending,
        onTap: () => _onSectionSelected(AdminSection.pending),
      ),
      AdminStatCard(
        title: 'Under Review',
        count: _stats['under_review'] ?? 0,
        icon: Icons.policy_rounded,
        color: AppColors.navyLight,
        backgroundColor: const Color(0xFFEFF6FF),
        onTap: () => _onSectionSelected(AdminSection.directory),
      ),
      AdminStatCard(
        title: 'Verified Active',
        count: _stats['verified'] ?? 0,
        icon: Icons.verified_user_rounded,
        color: AppColors.greenSuccess,
        backgroundColor: AppColors.greenLight,
        isSelected: _currentSection == AdminSection.verified,
        onTap: () => _onSectionSelected(AdminSection.verified),
      ),
      AdminStatCard(
        title: 'Rejected',
        count: _stats['rejected'] ?? 0,
        icon: Icons.cancel_outlined,
        color: const Color(0xFFDC2626),
        backgroundColor: const Color(0xFFFEF2F2),
        isSelected: _currentSection == AdminSection.rejected,
        onTap: () => _onSectionSelected(AdminSection.rejected),
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

  // ── 2. DIRECTORY & FILTERED SECTION CONTENT ─────────────────────────────────

  Widget _buildDirectorySection({required bool isDesktop}) {
    final statusFilter = _getStatusForSection(_currentSection);

    return Column(
      children: [
        // Directory Header Bar (for Desktop)
        if (isDesktop)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            color: AppColors.background,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getSectionTitle(_currentSection),
                      style: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navyPrimary,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    const Text(
                      'Browse and manage registered AYUSH healthcare facilities across India',
                      style: TextStyle(fontSize: 13.0, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.navyPrimary),
                  onPressed: _loadData,
                  tooltip: 'Refresh List',
                ),
              ],
            ),
          ),

        // Filter & Search Controls Header
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 24.0 : 20.0,
            vertical: 16.0,
          ),
          color: AppColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input Field
              TextField(
                controller: _searchController,
                onChanged: (val) {
                  if (val.isEmpty) _loadData();
                },
                onSubmitted: (_) => _loadData(),
                decoration: InputDecoration(
                  hintText:
                      'Search by hospital name, application ID, registration no, HFR ID, state...',
                  hintStyle:
                      const TextStyle(fontSize: 13.0, color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.saffronPrimary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18.0),
                          onPressed: () {
                            _searchController.clear();
                            _loadData();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: AppColors.surfaceBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: AppColors.surfaceBorder),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),

              // Status Filter Pill Chips
              HospitalStatusFilterBar(
                selectedStatus: statusFilter,
                onStatusSelected: _onStatusFilterChanged,
              ),
            ],
          ),
        ),

        const Divider(height: 1.0, color: AppColors.surfaceBorder),

        // Main Hospital Table / List
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${_filteredHospitals.length} Registrations',
                      style: const TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                isDesktop
                    ? HospitalDataTable(
                        hospitals: _filteredHospitals,
                        onHospitalTap: _navigateToDetails,
                      )
                    : Column(
                        children: _filteredHospitals
                            .map((h) => HospitalMobileCard(
                                  hospital: h,
                                  onTap: () => _navigateToDetails(h),
                                ))
                            .toList(),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
