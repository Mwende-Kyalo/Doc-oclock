import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class DoctorDrawer extends StatelessWidget {
  final String currentRoute;

  const DoctorDrawer({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    user?.fullName.substring(0, 1).toUpperCase() ?? 'D',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.fullName ?? l10n.doctor,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.event_note,
            title: l10n.upcomingAppointments,
            route: '/doctor/dashboard',
            isSelected: currentRoute == '/doctor/dashboard',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.chat,
            title: l10n.messages,
            route: '/doctor/messages',
            isSelected: currentRoute == '/doctor/messages',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.medical_information,
            title: l10n.patientEhrs,
            route: '/doctor/ehr',
            isSelected: currentRoute == '/doctor/ehr',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.calendar_today,
            title: l10n.calendar,
            route: '/doctor/calendar',
            isSelected: currentRoute == '/doctor/calendar',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.payment,
            title: l10n.doctorPayments,
            route: '/doctor/payments',
            isSelected: currentRoute == '/doctor/payments',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.history,
            title: l10n.history,
            route: '/doctor/history',
            isSelected: currentRoute == '/doctor/history',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: l10n.settings,
            route: '/doctor/settings',
            isSelected: currentRoute == '/doctor/settings',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.rate_review,
            title: l10n.patientReviews,
            route: '/doctor/reviews',
            isSelected: currentRoute == '/doctor/reviews',
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.errorRed),
            title: Text(
              l10n.logout,
              style: const TextStyle(color: AppTheme.errorRed),
            ),
            onTap: () async {
              await authProvider.signOut();
              if (context.mounted) {
                context.go('/sign-in');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.lightBlue : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppTheme.lightBlue : null,
        ),
      ),
      selected: isSelected,
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}
