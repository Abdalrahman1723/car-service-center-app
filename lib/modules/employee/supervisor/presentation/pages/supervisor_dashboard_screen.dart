import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/config/routes.dart';
import 'package:m_world/core/constants/app_strings.dart';
import 'package:m_world/core/services/auth_service.dart';
import 'package:m_world/modules/manager/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:m_world/modules/manager/features/dashboard/presentation/cubit/dashboard_cubit.dart';

class SupervisorDashboardScreen extends StatelessWidget {
  const SupervisorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit(FirebaseDashboardRepository()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة تحكم المشرف'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _showLogoutDialog(context),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildDashboardCard(
                context,
                'إدارة الفواتير',
                Icons.receipt,
                Colors.blue,
                () => Navigator.pushNamed(context, Routes.invoiceAdd),
              ),
              _buildDashboardCard(
                context,
                'قائمة الفواتير',
                Icons.list_alt,
                Colors.green,
                () => Navigator.pushNamed(context, Routes.invoiceList),
              ),
              _buildDashboardCard(
                context,
                'إدارة الحضور',
                Icons.people,
                Colors.orange,
                () => Navigator.pushNamed(context, Routes.manageAttendance),
              ),
              _buildDashboardCard(
                context,
                'إدارة العملاء',
                Icons.person,
                Colors.purple,
                () => Navigator.pushNamed(context, Routes.clientManagement),
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
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(Routes.login);
              }
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
