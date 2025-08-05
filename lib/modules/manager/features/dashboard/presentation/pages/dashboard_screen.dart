import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:m_world/config/routes.dart';
import 'package:m_world/shared/models/client.dart';
import '../../../../../../shared/models/invoice.dart';
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
                      'Manager Dashboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const Text(
                      'Welcome back!',
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
                        title: 'All Invoices',
                        subtitle: 'View and manage invoices',
                        onTap: () {
                          Navigator.pop(context);
                          cubit.loadAllInvoices();
                        },
                      ),
                      buildDrawerItem(
                        context,
                        icon: Icons.people,
                        title: 'All Clients',
                        subtitle: 'Manage client information',
                        onTap: () {
                          Navigator.pop(context);
                          cubit.loadAllClients();
                        },
                      ),
                      buildDrawerItem(
                        context,
                        icon: Icons.local_shipping,
                        title: 'All Suppliers',
                        subtitle: 'Manage supplier relationships',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to suppliers page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Placeholder(),
                            ),
                          );
                        },
                      ),
                      buildDrawerItem(
                        context,
                        icon: Icons.shopping_cart,
                        title: 'The Purchases',
                        subtitle: 'Track purchase orders',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to purchases page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Placeholder(),
                            ),
                          );
                        },
                      ),
                      buildDrawerItem(
                        context,
                        icon: Icons.account_balance,
                        title: 'The Vault',
                        subtitle: 'Financial management',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to vault page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Placeholder(),
                            ),
                          );
                        },
                      ),
                      buildDrawerItem(
                        context,
                        icon: Icons.inventory,
                        title: 'The Inventory',
                        subtitle: 'Stock management',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to inventory page
                          Navigator.pushNamed(context, Routes.inventoryPanel);
                        },
                      ),
                      buildDrawerItem(
                        context,
                        icon: Icons.work,
                        title: 'The Employees',
                        subtitle: 'Manage team members',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to employees page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Placeholder(),
                            ),
                          );
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
                          'Logout',
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
                title: const Text('Confirm Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(), // Cancel
                    child: const Text('Cancel'),
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
                    child: const Text('Logout'),
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
                  'Welcome, Manager!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: clientController,
                  decoration: const InputDecoration(
                    labelText: 'Search Clients',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => cubit.searchClients(value),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: invoiceController,
                  decoration: const InputDecoration(
                    labelText: 'Search Invoices',
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
                      'Add New Invoice',
                      Icons.add_circle,
                      () => cubit.addInvoice(
                        Invoice(
                          id: DateTime.now().toString(),
                          clientId: '',
                          amount: 100.0,
                        ),
                      ),
                    ),
                    //all invoices
                    buildCard(
                      context,
                      'All Invoices',
                      Icons.list,
                      () => cubit.loadAllInvoices(),
                    ),
                    //add new client
                    buildCard(
                      context,
                      'Add New Client',
                      Icons.person_add,
                      () => cubit.addClient(
                        Client(
                          id: DateTime.now().toString(),
                          name: 'New Client',
                          email: 'client@example.com',
                          carType: 'X6',
                          balance: 0,
                        ),
                      ),
                    ),
                    //all clients
                    buildCard(
                      context,
                      'All Clients',
                      Icons.people,
                      () => cubit.loadAllClients(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                //----------sales chart
                const Text(
                  'Sales Chart',
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
                  'Costs & Payments Chart',
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
                  'Activity Timeline',
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
