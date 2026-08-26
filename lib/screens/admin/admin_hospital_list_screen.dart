import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/admin_hospital_model.dart';
import '../../models/hospital_model.dart';
import '../../services/admin_hospital_service.dart';
import '../../widgets/admin_widgets.dart';
import 'admin_hospital_details_screen.dart';

/// Admin Hospital List Screen supporting multi-field search, status filtering, and responsive view.
class AdminHospitalListScreen extends StatefulWidget {
  final VerificationStatus? initialStatus;

  const AdminHospitalListScreen({
    super.key,
    this.initialStatus,
  });

  @override
  State<AdminHospitalListScreen> createState() => _AdminHospitalListScreenState();
}

class _AdminHospitalListScreenState extends State<AdminHospitalListScreen> {
  final _service = AdminHospitalService();
  final _searchController = TextEditingController();

  VerificationStatus? _selectedStatus;
  List<AdminHospitalDetail> _hospitals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _fetchHospitals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchHospitals() async {
    setState(() => _isLoading = true);
    final results = await _service.getHospitals(
      status: _selectedStatus,
      search: _searchController.text,
    );
    setState(() {
      _hospitals = results;
      _isLoading = false;
    });
  }

  void _onStatusChanged(VerificationStatus? status) {
    setState(() {
      _selectedStatus = status;
    });
    _fetchHospitals();
  }

  void _onSearchSubmitted(String query) {
    _fetchHospitals();
  }

  void _navigateToDetails(AdminHospitalDetail hospital) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdminHospitalDetailsScreen(hospitalId: hospital.id),
      ),
    );
    _fetchHospitals();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.navyPrimary, size: 20.0),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Hospital Directory & Reviews',
          style: TextStyle(color: AppColors.navyPrimary, fontWeight: FontWeight.w800, fontSize: 18.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.navyPrimary),
            onPressed: _fetchHospitals,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search Controls Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            color: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input Field
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    if (val.isEmpty) _fetchHospitals();
                  },
                  onSubmitted: _onSearchSubmitted,
                  decoration: InputDecoration(
                    hintText: 'Search by hospital name, application ID, registration no, HFR ID, state...',
                    hintStyle: const TextStyle(fontSize: 13.0, color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.saffronPrimary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18.0),
                            onPressed: () {
                              _searchController.clear();
                              _fetchHospitals();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                  selectedStatus: _selectedStatus,
                  onStatusSelected: _onStatusChanged,
                ),
              ],
            ),
          ),

          const Divider(height: 1.0, color: AppColors.surfaceBorder),

          // Main Hospital List View / Table
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Showing ${_hospitals.length} Registrations',
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
                                hospitals: _hospitals,
                                onHospitalTap: _navigateToDetails,
                              )
                            : Column(
                                children: _hospitals
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
      ),
    );
  }
}
