import 'package:flutter/material.dart';
import '../app/theme.dart';

enum AdminSection {
  overview,
  pending,
  directory,
  verified,
  rejected,
}

/// Reusable Left Sidebar for the Admin Portal.
/// Fixed 260px wide sidebar with SIH/AYUSH branding, menu items, badges, and profile card.
class AdminSidebar extends StatelessWidget {
  final AdminSection currentSection;
  final ValueChanged<AdminSection> onSectionSelected;
  final int? pendingCount;

  const AdminSidebar({
    super.key,
    required this.currentSection,
    required this.onSectionSelected,
    this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260.0,
      decoration: const BoxDecoration(
        color: AppColors.navyPrimary,
      ),
      child: Column(
        children: [
          // Logo & Header
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
                  child: const Icon(Icons.verified_user_rounded,
                      color: AppColors.background, size: 24.0),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'MEDIKIOSK',
                        style: TextStyle(
                          color: AppColors.background,
                          fontWeight: FontWeight.w900,
                          fontSize: 16.0,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        'Admin Central Portal',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 11.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF1E3A8A), height: 1.0),
          const SizedBox(height: 16.0),

          // Menu Items
          _buildSidebarItem(
            context: context,
            icon: Icons.dashboard_rounded,
            title: 'Overview Dashboard',
            isSelected: currentSection == AdminSection.overview,
            onTap: () => onSectionSelected(AdminSection.overview),
          ),
          _buildSidebarItem(
            context: context,
            icon: Icons.hourglass_top_rounded,
            title: 'Pending Reviews',
            isSelected: currentSection == AdminSection.pending,
            badgeCount: pendingCount,
            badgeColor: AppColors.saffronPrimary,
            onTap: () => onSectionSelected(AdminSection.pending),
          ),
          _buildSidebarItem(
            context: context,
            icon: Icons.local_hospital_rounded,
            title: 'Hospital Directory',
            isSelected: currentSection == AdminSection.directory,
            onTap: () => onSectionSelected(AdminSection.directory),
          ),
          _buildSidebarItem(
            context: context,
            icon: Icons.verified_rounded,
            title: 'Verified Facilities',
            isSelected: currentSection == AdminSection.verified,
            onTap: () => onSectionSelected(AdminSection.verified),
          ),
          _buildSidebarItem(
            context: context,
            icon: Icons.cancel_outlined,
            title: 'Rejected Applications',
            isSelected: currentSection == AdminSection.rejected,
            onTap: () => onSectionSelected(AdminSection.rejected),
          ),
          const Divider(color: Color(0xFF1E3A8A), height: 24.0),
          _buildSidebarItem(
            context: context,
            icon: Icons.domain_rounded,
            title: 'Hospital Portal',
            isSelected: false,
            onTap: () {
              Navigator.of(context).pushNamed('/register');
            },
          ),

          const Spacer(),

          // Bottom Officer Profile Card
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
                  child: Icon(Icons.person_rounded,
                      color: AppColors.saffronDark),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Verification Officer',
                        style: TextStyle(
                          color: AppColors.background,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Ministry of Ayush',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 10.0),
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
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
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
          leading: Icon(
            icon,
            color: isSelected ? AppColors.saffronPrimary : AppColors.textMuted,
            size: 20.0,
          ),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: badgeColor ?? AppColors.navyLight,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(
                      color: AppColors.background,
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          onTap: onTap,
        ),
      ),
    );
  }
}

/// Reusable Mobile Drawer for the Admin Portal.
class AdminMobileDrawer extends StatelessWidget {
  final AdminSection currentSection;
  final ValueChanged<AdminSection> onSectionSelected;
  final int? pendingCount;

  const AdminMobileDrawer({
    super.key,
    required this.currentSection,
    required this.onSectionSelected,
    this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
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
                Icon(Icons.verified_user_rounded,
                    color: AppColors.saffronPrimary, size: 36.0),
                SizedBox(height: 10.0),
                Text('MediKiosk Admin Portal',
                    style: TextStyle(
                        color: AppColors.background,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold)),
                Text('Ministry of Ayush',
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 12.0)),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.dashboard_rounded,
              color: currentSection == AdminSection.overview
                  ? AppColors.saffronPrimary
                  : const Color(0xFFCBD5E1),
            ),
            title: Text(
              'Overview Dashboard',
              style: TextStyle(
                color: AppColors.background,
                fontWeight: currentSection == AdminSection.overview
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            selected: currentSection == AdminSection.overview,
            onTap: () {
              Navigator.of(context).pop();
              onSectionSelected(AdminSection.overview);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.hourglass_top_rounded,
              color: currentSection == AdminSection.pending
                  ? AppColors.saffronPrimary
                  : AppColors.saffronDark,
            ),
            title: Text(
              'Pending Reviews',
              style: TextStyle(
                color: AppColors.background,
                fontWeight: currentSection == AdminSection.pending
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            selected: currentSection == AdminSection.pending,
            trailing: (pendingCount != null && pendingCount! > 0)
                ? CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.saffronPrimary,
                    child: Text(
                      pendingCount.toString(),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11),
                    ),
                  )
                : null,
            onTap: () {
              Navigator.of(context).pop();
              onSectionSelected(AdminSection.pending);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.local_hospital_rounded,
              color: currentSection == AdminSection.directory
                  ? AppColors.saffronPrimary
                  : const Color(0xFFCBD5E1),
            ),
            title: Text(
              'Hospital Directory',
              style: TextStyle(
                color: AppColors.background,
                fontWeight: currentSection == AdminSection.directory
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            selected: currentSection == AdminSection.directory,
            onTap: () {
              Navigator.of(context).pop();
              onSectionSelected(AdminSection.directory);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.verified_rounded,
              color: currentSection == AdminSection.verified
                  ? AppColors.saffronPrimary
                  : AppColors.greenSuccess,
            ),
            title: Text(
              'Verified Facilities',
              style: TextStyle(
                color: AppColors.background,
                fontWeight: currentSection == AdminSection.verified
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            selected: currentSection == AdminSection.verified,
            onTap: () {
              Navigator.of(context).pop();
              onSectionSelected(AdminSection.verified);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.cancel_outlined,
              color: currentSection == AdminSection.rejected
                  ? AppColors.saffronPrimary
                  : const Color(0xFFDC2626),
            ),
            title: Text(
              'Rejected Applications',
              style: TextStyle(
                color: AppColors.background,
                fontWeight: currentSection == AdminSection.rejected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            selected: currentSection == AdminSection.rejected,
            onTap: () {
              Navigator.of(context).pop();
              onSectionSelected(AdminSection.rejected);
            },
          ),
          const Divider(color: Color(0xFF1E3A8A)),
          ListTile(
            leading: const Icon(Icons.domain_rounded,
                color: AppColors.saffronPrimary),
            title: const Text('Hospital Portal',
                style: TextStyle(color: AppColors.background)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/register');
            },
          ),
        ],
      ),
    );
  }
}
