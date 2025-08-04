import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:m_world/shared/models/client.dart';

import '../../../../../../shared/models/invoice.dart';
import '../cubit/dashboard_cubit.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardCubit>();
    final clientController = TextEditingController();
    final invoiceController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('M World Dashboart'),
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
          //logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => cubit.logout(),
          ),
        ],
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
                      // await FirebaseAuth.instance.signOut();
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
                    _buildCard(
                      context,
                      'Add New Invoice',
                      Icons.add_circle,
                      () => cubit.addInvoice(
                        Invoice(
                          id: DateTime.now().toString(),
                          clientId: 'client_1',
                          amount: 100.0,
                          date: DateTime.now(),
                        ),
                      ),
                    ),
                    _buildCard(
                      context,
                      'All Invoices',
                      Icons.list,
                      () => cubit.loadAllInvoices(),
                    ),
                    _buildCard(
                      context,
                      'Add New Client',
                      Icons.person_add,
                      () => cubit.addClient(
                        Client(
                          id: DateTime.now().toString(),
                          name: 'New Client',
                          email: 'client@example.com',
                        ),
                      ),
                    ),
                    _buildCard(
                      context,
                      'All Clients',
                      Icons.people,
                      () => cubit.loadAllClients(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                const Text(
                  'Activity Timeline',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
