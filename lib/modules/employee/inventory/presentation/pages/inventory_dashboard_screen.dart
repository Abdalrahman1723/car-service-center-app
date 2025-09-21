import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/config/routes.dart';
import 'package:m_world/core/constants/app_strings.dart';
import 'package:m_world/core/services/auth_service.dart';
import 'package:m_world/modules/manager/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:m_world/modules/manager/features/dashboard/presentation/cubit/dashboard_cubit.dart';

class InventoryDashboardScreen extends StatelessWidget {
  const InventoryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLargeScreen = screenSize.width > 900;

    return BlocProvider(
      create: (context) => DashboardCubit(FirebaseDashboardRepository()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'لوحة تحكم المخزون',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.logout, size: isTablet ? 28 : 24),
              onPressed: () => _showLogoutDialog(context),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
          child: GridView.count(
            crossAxisCount: isLargeScreen ? 3 : (isTablet ? 2 : 2),
            crossAxisSpacing: isTablet ? 20 : 16,
            mainAxisSpacing: isTablet ? 20 : 16,
            childAspectRatio: isTablet ? 1.1 : 1.0,
            children: [
              _buildDashboardCard(
                context,
                'إدارة الشحنات',
                Icons.local_shipping,
                Colors.blue,
                () => Navigator.pushNamed(context, Routes.shipments),
                isTablet,
              ),
              _buildDashboardCard(
                context,
                'إدارة الموردين',
                Icons.business,
                Colors.green,
                () => Navigator.pushNamed(context, Routes.suppliers),
                isTablet,
              ),
              _buildDashboardCard(
                context,
                'إدارة المخزون',
                Icons.inventory,
                Colors.teal,
                () => Navigator.pushNamed(
                  context,
                  Routes.restrictedInventoryPanel,
                ),
                isTablet,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isTablet,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: isTablet ? 56 : 48, color: Colors.white),
              SizedBox(height: isTablet ? 16 : 12),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تأكيد تسجيل الخروج',
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'هل أنت متأكد من تسجيل الخروج؟',
          style: TextStyle(fontSize: isTablet ? 16 : 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(Routes.login);
              }
            },
            child: Text(
              'تسجيل الخروج',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
