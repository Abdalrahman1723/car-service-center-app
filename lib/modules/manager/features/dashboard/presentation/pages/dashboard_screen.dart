import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:m_world/config/routes.dart';
import 'package:m_world/core/constants/app_strings.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/build_card.dart';
import '../widgets/drawer_item.dart';
import '../widgets/time_line.dart';
import '../../domain/entities/timeline_event.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardCubit>();
    final clientController = TextEditingController();
    final invoiceController = TextEditingController();

    // Load dashboard data when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.loadDashboardData();
    });

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
          //refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              cubit.loadDashboardData();
            },
          ),
          //notification screen
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications page
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
                      //reservations
                      buildDrawerItem(
                        context,
                        icon: Icons.schedule,
                        title: 'الحجوزات',
                        subtitle: 'عرض وإدارة الحجوزات',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(
                            context,
                          ).pushNamed(Routes.reservationList);
                        },
                      ),
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
                      // reports
                      buildDrawerItem(
                        context,
                        icon: Icons.assessment,
                        title: 'التقارير',
                        subtitle: 'تقارير الأعمال والمالية',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushNamed(Routes.reports);
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
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          Map<String, double> salesData = {};
          List<TimelineEvent> timelineEvents = [];

          if (state is DashboardDataLoaded) {
            salesData = state.salesData;
            timelineEvents = state.timelineEvents;
          } else if (state is DashboardChartsLoaded) {
            salesData = state.salesData;
            timelineEvents = state.timelineEvents;
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
                  decoration: InputDecoration(
                    labelText: 'البحث في العملاء',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        Navigator.of(context).pushNamed(Routes.clientList);
                      },
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.clientList);
                  },
                  readOnly: true,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: invoiceController,
                  decoration: InputDecoration(
                    labelText: 'البحث في الفواتير',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        Navigator.of(context).pushNamed(Routes.invoiceList);
                      },
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.invoiceList);
                  },
                  readOnly: true,
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.trending_up,
                              color: Colors.blue[600],
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'رسم بياني للمبيعات',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Add loading state for chart
                      BlocBuilder<DashboardCubit, DashboardState>(
                        builder: (context, state) {
                          if (state is DashboardLoading) {
                            return Container(
                              height: 250,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text(
                                      'جاري تحميل البيانات...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return _buildSalesChart(salesData);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                //----------cost chart
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                //----------timeline
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.purple[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.timeline,
                              color: Colors.purple[600],
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'خط الزمن للنشاطات',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TimeLine(events: timelineEvents),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSalesChart(Map<String, double> salesData) {
    // Handle null or empty data
    if (salesData.isEmpty) {
      return _buildErrorWidget(
        'لا توجد بيانات مبيعات',
        Icons.bar_chart,
        'لا توجد بيانات للعرض',
      );
    }

    try {
      // Clean and normalize data
      final cleanedData = <MapEntry<String, double>>[];

      for (final entry in salesData.entries) {
        if (entry.key.isNotEmpty) {
          double value = entry.value;

          // Handle problematic values
          if (value.isNaN || value.isInfinite) {
            value = 0.0;
          } else if (value < 0) {
            value = 0.0; // Convert negative values to zero
          } else if (value > 1000000) {
            value = 1000000; // Cap extremely large values
          }

          cleanedData.add(MapEntry(entry.key, value));
        }
      }

      // If no valid data after cleaning, show error
      if (cleanedData.isEmpty) {
        return _buildErrorWidget(
          'بيانات غير صالحة',
          Icons.warning,
          'جميع البيانات غير صالحة للعرض',
        );
      }

      // Sort data by value to ensure proper ordering
      cleanedData.sort((a, b) => a.value.compareTo(b.value));

      // Create chart spots with proper spacing
      final spots = <FlSpot>[];
      for (int i = 0; i < cleanedData.length; i++) {
        spots.add(FlSpot(i.toDouble(), cleanedData[i].value));
      }

      // Calculate proper scaling
      double minValue = 0;
      double maxValue = 100;

      if (spots.isNotEmpty) {
        final values = spots.map((spot) => spot.y).toList();
        minValue = values.reduce((a, b) => a < b ? a : b);
        maxValue = values.reduce((a, b) => a > b ? a : b);

        // Add padding to the range
        final range = maxValue - minValue;
        if (range == 0) {
          // If all values are the same, create a small range
          minValue = (minValue * 0.9).clamp(0, double.infinity);
          maxValue = (maxValue * 1.1).clamp(0, double.infinity);
        } else {
          final padding = range * 0.1; // 10% padding
          minValue = (minValue - padding).clamp(0, double.infinity);
          maxValue = maxValue + padding;
        }
      }

      // Ensure minimum range for visibility
      if (maxValue - minValue < 1) {
        maxValue = minValue + 1;
      }

      return SizedBox(
        height: 250,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (maxValue - minValue) / 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.3),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35,
                  getTitlesWidget: (value, meta) {
                    try {
                      final index = value.toInt();
                      if (index >= 0 && index < cleanedData.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            cleanedData[index].key,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      }
                    } catch (e) {
                      // Handle any errors in title generation
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: (maxValue - minValue) / 5,
                  getTitlesWidget: (value, meta) {
                    try {
                      return Text(
                        value.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    } catch (e) {
                      return const Text('');
                    }
                  },
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
            ),
            minX: 0,
            maxX: (cleanedData.length - 1).toDouble(),
            minY: minValue,
            maxY: maxValue,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true, // Always show curves
                curveSmoothness: 0.35, // Smooth curves
                color: Colors.blue,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 5,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: Colors.blue,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.blue.withOpacity(0.1),
                ),
                // Add gradient for better visual appeal
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.8),
                    Colors.blue.withOpacity(0.3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ],
            // Add touch interaction
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => Colors.blue.withOpacity(0.8),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((touchedSpot) {
                    final index = touchedSpot.x.toInt();
                    if (index >= 0 && index < cleanedData.length) {
                      return LineTooltipItem(
                        '${cleanedData[index].key}\n${touchedSpot.y.toStringAsFixed(2)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                    return null;
                  }).toList();
                },
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      // Catch any unexpected errors and show a fallback chart
      return _buildFallbackChart();
    }
  }

  Widget _buildFallbackChart() {
    // Create a simple fallback chart with sample data
    final fallbackSpots = [
      const FlSpot(0, 10),
      const FlSpot(1, 20),
      const FlSpot(2, 15),
      const FlSpot(3, 25),
      const FlSpot(4, 30),
    ];

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, meta) {
                  final months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو'];
                  final index = value.toInt();
                  if (index >= 0 && index < months.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        months[index],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.withOpacity(0.5)),
          ),
          minX: 0,
          maxX: 4,
          minY: 0,
          maxY: 35,
          lineBarsData: [
            LineChartBarData(
              spots: fallbackSpots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: Colors.blue,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String title, IconData icon, String message) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

}
