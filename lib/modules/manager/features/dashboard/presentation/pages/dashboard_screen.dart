import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:m_world/config/routes.dart';
import 'package:m_world/core/constants/app_strings.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/build_card.dart';
import '../widgets/drawer_item.dart';
import '../widgets/time_line.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardCubit>();
    final clientController = TextEditingController();
    final invoiceController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          //notification screen
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Placeholder()),
              );
            },
          ),
          //settings screen
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Placeholder()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
            ),
          ),
          child: Column(
            children: [
              // Drawer Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 50, bottom: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFF1976D2),
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'لوحة تحكم المدير',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const Text(
                      'مرحباً بعودتك!',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Navigation Items
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    children: [
                      //all invoices
                      buildDrawerItem(
                        context,
                        icon: Icons.receipt_long,
                        title: 'جميع الفواتير',
                        subtitle: 'عرض وإدارة الفواتير',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushNamed(Routes.invoiceList);
                        },
                      ),
                      //all clients
                      buildDrawerItem(
                        context,
                        icon: Icons.people,
                        title: 'جميع العملاء',
                        subtitle: 'إدارة معلومات العملاء',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushNamed(Routes.clientList);
                        },
                      ),
                      //the inventory
                      buildDrawerItem(
                        context,
                        icon: Icons.inventory,
                        title: 'المخزون',
                        subtitle: 'إدارة المخزون',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to inventory page
                          Navigator.pushNamed(context, Routes.inventoryPanel);
                        },
                      ),
                      //all supplyers
                      buildDrawerItem(
                        context,
                        icon: Icons.local_shipping,
                        title: 'جميع الموردين',
                        subtitle: 'إدارة علاقات الموردين',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to suppliers page
                          Navigator.of(context).pushNamed(Routes.suppliers);
                        },
                      ),
                      //shipments
                      buildDrawerItem(
                        context,
                        icon: Icons.shopping_cart,
                        title: 'المشتريات',
                        subtitle: 'تتبع طلبات الشراء',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to purchases page
                          Navigator.of(context).pushNamed(Routes.shipments);
                        },
                      ),
                      //the vault
                      buildDrawerItem(
                        context,
                        icon: Icons.account_balance,
                        title: 'الخزينة',
                        subtitle: 'الإدارة المالية',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to vault page
                          Navigator.of(context).pushNamed(Routes.vault);
                        },
                      ),
                      //employees
                      buildDrawerItem(
                        context,
                        icon: Icons.work,
                        title: 'الموظفين',
                        subtitle: 'إدارة أعضاء الفريق',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to employees page
                          Navigator.of(context).pushNamed(Routes.employeeList);
                        },
                      ),
                      // attendance table
                      buildDrawerItem(
                        context,
                        icon: Icons.schedule,
                        title: 'جدول الحضور',
                        subtitle: 'إدارة حضور الفريق',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to employees page
                          Navigator.of(
                            context,
                          ).pushNamed(Routes.weeklyAttendanceTable);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Logout Section
              Container(
                margin: const EdgeInsets.all(10),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    cubit.logout();
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.logout, color: Colors.red, size: 20),
                        const SizedBox(width: 15),
                        const Text(
                          'تسجيل الخروج',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: BlocConsumer<DashboardCubit, DashboardState>(
        listener: (context, state) {
          if (state is DashboardError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is DashboardSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is DashboardLoggedOut) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('تأكيد تسجيل الخروج'),
                content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(), // Cancel
                    child: const Text(AppStrings.cancel),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop(); // Close dialog
                      // Firebase logout
                      await Future.delayed(
                        const Duration(milliseconds: 100),
                      ); // Optional: ensure dialog closes
                      // Then navigate to login screen
                      if (context.mounted) {
                        Navigator.of(
                          context,
                        ).pushReplacementNamed('/LoginScreen');
                      }
                    },
                    child: const Text('تسجيل الخروج'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مرحباً!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: clientController,
                  decoration: const InputDecoration( 
                    labelText: 'البحث في العملاء',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => cubit.searchClients(value),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: invoiceController,
                  decoration: const InputDecoration(
                    labelText: 'البحث في الفواتير',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => cubit.searchInvoices(value),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: [
                    //add new invoice
                    buildCard(
                      context,
                      'إضافة  Job order',
                      Icons.add_circle,
                      () => Navigator.of(context).pushNamed(Routes.invoiceAdd),
                    ),
                    //all invoices
                    buildCard(
                      context,
                      'جميع الفواتير',
                      Icons.list,
                      () => Navigator.of(context).pushNamed(Routes.invoiceList),
                    ),
                    //add new client
                    buildCard(
                      context,
                      'إضافة عميل جديد',
                      Icons.person_add,
                      () => Navigator.of(
                        context,
                      ).pushNamed(Routes.clientManagement),
                    ),
                    //all clients
                    buildCard(
                      context,
                      'جميع العملاء',
                      Icons.people,
                      () => Navigator.of(context).pushNamed(Routes.clientList),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                //----------sales chart
                const Text(
                  'رسم بياني للمبيعات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      titlesData: FlTitlesData(show: true),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            const FlSpot(0, 1000),
                            const FlSpot(1, 1500),
                            const FlSpot(2, 1200),
                            const FlSpot(3, 1800),
                            const FlSpot(4, 2000),
                          ],
                          isCurved: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(),
                const SizedBox(height: 16),
                //----------cost chart
                const Text(
                  'رسم بياني للتكاليف والمدفوعات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      titlesData: FlTitlesData(show: true),
                      borderData: FlBorderData(show: true),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(toY: 500, color: Colors.red),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(toY: 700, color: Colors.blue),
                          ],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(toY: 600, color: Colors.red),
                          ],
                        ),
                        BarChartGroupData(
                          x: 3,
                          barRods: [
                            BarChartRodData(toY: 800, color: Colors.blue),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                //----------timeline
                const Text(
                  'خط الزمن للنشاطات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TimeLine(),
              ],
            ),
          );
        },
      ),
    );
  }
}
