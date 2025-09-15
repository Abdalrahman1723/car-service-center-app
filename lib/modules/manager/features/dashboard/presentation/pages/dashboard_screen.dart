import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:m_world/config/routes.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/build_card.dart';
import '../widgets/drawer_item.dart';
import '../widgets/time_line.dart';
import '../../domain/entities/timeline_event.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final clientController = TextEditingController();
  final invoiceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load dashboard data when the screen is first initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardCubit>().loadDashboardData();
    });
  }

  @override
  void dispose() {
    clientController.dispose();
    invoiceController.dispose();
    super.dispose();
  }

  // A helper function for responsive font sizing
  double getResponsiveFontSize(BuildContext context, double baseSize) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    // Scale font size based on screen width
    return width < 600 ? baseSize : baseSize * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardCubit>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => cubit.loadDashboardData(),
            ),
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
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'لوحة تحكم المدير',
                        style: TextStyle(
                          fontSize: getResponsiveFontSize(context, 18),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1976D2),
                        ),
                      ),
                      Text(
                        'مرحباً بعودتك!',
                        style: TextStyle(
                          fontSize: getResponsiveFontSize(context, 14),
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
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

                          icon: Icons.table_rows,

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

                            Navigator.of(
                              context,
                            ).pushNamed(Routes.employeeList);
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
                Container(
                  margin: const EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () => cubit.logout(),
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
                          Text(
                            'تسجيل الخروج',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: getResponsiveFontSize(context, 16),
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
                  Text(
                    'مرحباً!',
                    style: TextStyle(
                      fontSize: getResponsiveFontSize(context, 24),
                      fontWeight: FontWeight.bold,
                    ),
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
                        onPressed: () =>
                            Navigator.of(context).pushNamed(Routes.clientList),
                      ),
                    ),
                    onTap: () =>
                        Navigator.of(context).pushNamed(Routes.clientList),
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
                        onPressed: () =>
                            Navigator.of(context).pushNamed(Routes.invoiceList),
                      ),
                    ),
                    onTap: () =>
                        Navigator.of(context).pushNamed(Routes.invoiceList),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        children: [
                          buildCard(
                            context,
                            'إضافة Job order',
                            Icons.add_circle,
                            () => Navigator.of(
                              context,
                            ).pushNamed(Routes.invoiceAdd),
                          ),
                          buildCard(
                            context,
                            'جميع الفواتير',
                            Icons.list,
                            () => Navigator.of(
                              context,
                            ).pushNamed(Routes.invoiceList),
                          ),
                          buildCard(
                            context,
                            'إضافة عميل جديد',
                            Icons.person_add,
                            () => Navigator.of(
                              context,
                            ).pushNamed(Routes.clientManagement),
                          ),
                          buildCard(
                            context,
                            'جميع العملاء',
                            Icons.people,
                            () => Navigator.of(
                              context,
                            ).pushNamed(Routes.clientList),
                          ),
                        ],
                      );
                    },
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
                                size: getResponsiveFontSize(context, 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'رسم بياني للمبيعات',
                              style: TextStyle(
                                fontSize: getResponsiveFontSize(context, 18),
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSalesChart(salesData),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  //----------cost chart (placeholder)
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
                    child: Center(
                      child: Text(
                        'لا توجد بيانات متاحة لعرضها',
                        style: TextStyle(
                          fontSize: getResponsiveFontSize(context, 16),
                          color: Colors.grey,
                        ),
                      ),
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
                                size: getResponsiveFontSize(context, 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'خط الزمن للنشاطات',
                              style: TextStyle(
                                fontSize: getResponsiveFontSize(context, 18),
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
      ),
    );
  }

  Widget _buildSalesChart(Map<String, double> salesData) {
    if (salesData.isEmpty) {
      return Center(
        child: Text(
          'لا توجد بيانات مبيعات',
          style: TextStyle(
            fontSize: getResponsiveFontSize(context, 16),
            color: Colors.grey,
          ),
        ),
      );
    }

    final entries = salesData.entries.toList();
    final spots = entries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    final nonZeroSpots = spots.where((spot) => spot.y > 0).toList();
    final maxValue = nonZeroSpots.isNotEmpty
        ? nonZeroSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) *
              1.2
        : 1.0;

    // Check if the interval is zero, if so, provide a fallback.
    final horizontalInterval = maxValue / 5 > 0 ? maxValue / 5 : 1.0;

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: horizontalInterval,
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
                  if (value.toInt() < entries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        entries[value.toInt()].key,
                        style: TextStyle(
                          fontSize: getResponsiveFontSize(context, 12),
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
                interval: horizontalInterval,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: getResponsiveFontSize(context, 12),
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.withOpacity(0.5)),
          ),
          minX: 0,
          maxX: (entries.length - 1).toDouble(),
          minY: 0,
          maxY: maxValue,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
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
}
