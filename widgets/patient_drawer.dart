import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class PatientDrawer extends StatelessWidget {
  final String currentRoute;

  const PatientDrawer({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

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
                    user?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.fullName ?? 'User',
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
            icon: Icons.calendar_today,
            title: 'Book Appointments',
            route: '/patient/book-appointment',
            isSelected: currentRoute == '/patient/book-appointment',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.medical_information,
            title: 'View EHR',
            route: '/patient/ehr',
            isSelected: currentRoute == '/patient/ehr',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.chat,
            title: 'Messages',
            route: '/patient/messages',
            isSelected: currentRoute == '/patient/messages',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.medical_services,
            title: 'Order Prescriptions',
            route: '/patient/prescriptions',
            isSelected: currentRoute == '/patient/prescriptions',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.info_outline,
            title: 'Medicine Info',
            route: '/patient/medicine-info',
            isSelected: currentRoute == '/patient/medicine-info',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.payment,
            title: 'Make Payment',
            route: '/patient/payment',
            isSelected: currentRoute == '/patient/payment',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            route: '/patient/settings',
            isSelected: currentRoute == '/patient/settings',
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.errorRed),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.errorRed),
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
