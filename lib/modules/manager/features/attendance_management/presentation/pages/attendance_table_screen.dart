import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:m_world/core/constants/app_strings.dart';
import 'package:m_world/modules/manager/features/attendance_management/domain/entities/attendance.dart';
import 'package:m_world/modules/manager/features/attendance_management/presentation/cubit/attendance_cubit.dart';
import 'package:m_world/modules/manager/features/employee_management/domain/entities/employee.dart';

class WeeklyAttendanceTableScreen extends StatefulWidget {
  const WeeklyAttendanceTableScreen({super.key});

  @override
  WeeklyAttendanceTableScreenState createState() =>
      WeeklyAttendanceTableScreenState();
}

class WeeklyAttendanceTableScreenState
    extends State<WeeklyAttendanceTableScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = now.subtract(Duration(days: now.weekday - 1));
    _endDate = _startDate!.add(const Duration(days: 6));
    context.read<AttendanceCubit>().startListening(
      startDate: _startDate,
      endDate: _endDate,
      allEmployees: true,
    );
  }

  void _applyFilters() {
    context.read<AttendanceCubit>().startListening(
      startDate: _startDate,
      endDate: _endDate,
      allEmployees: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by Date',
            onPressed: () => _showDateFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export to PDF',
            onPressed: () => _exportToPDF(context),
          ),
        ],
      ),
      body: BlocConsumer<AttendanceCubit, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AttendanceLoaded) {
            return FutureBuilder<List<Employee>>(
              future: _fetchEmployees(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading employees'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No employees found'));
                }
                final employees = snapshot.data!;
                final attendanceByEmployee = _groupAttendanceByEmployee(
                  state.attendance,
                  employees,
                );
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Total Hours')),
                      DataColumn(label: Text('Overtime')),
                      DataColumn(label: Text('Late Minutes')),
                      DataColumn(label: Text('Attendance %')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: employees.map((employee) {
                      final summary = _calculateEmployeeSummary(
                        attendanceByEmployee[employee.id] ?? [],
                        _startDate!,
                        _endDate!,
                      );
                      final latestStatus =
                          attendanceByEmployee[employee.id]?.isNotEmpty == true
                          ? attendanceByEmployee[employee.id]!
                                .first
                                .compensationStatus
                          : 'N/A';
                      return DataRow(
                        cells: [
                          DataCell(Text(employee.fullName)),
                          DataCell(
                            Text(summary['totalHours'].toStringAsFixed(2)),
                          ),
                          DataCell(
                            Text(summary['totalOvertime'].toStringAsFixed(2)),
                          ),
                          DataCell(
                            Text(summary['totalLateMinutes'].toString()),
                          ),
                          DataCell(
                            Text(
                              summary['attendancePercentage'].toStringAsFixed(
                                1,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 8,
                                  backgroundColor:
                                      latestStatus == AppStrings.onTime
                                      ? Colors.green
                                      : latestStatus == AppStrings.compensated
                                      ? Colors.yellow
                                      : latestStatus ==
                                            AppStrings.notCompensated
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(latestStatus),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('No attendance data loaded'));
        },
      ),
    );
  }

  Future<List<Employee>> _fetchEmployees() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('employees')
        .get();
    return snapshot.docs
        .map((doc) => Employee.fromMap(doc.id, doc.data()))
        .toList();
  }

  Map<String, List<Attendance>> _groupAttendanceByEmployee(
    List<Attendance> attendance,
    List<Employee> employees,
  ) {
    final Map<String, List<Attendance>> grouped = {};
    for (var employee in employees) {
      grouped[employee.id] = attendance
          .where((a) => a.employeeId == employee.id)
          .toList();
    }
    return grouped;
  }

  Map<String, dynamic> _calculateEmployeeSummary(
    List<Attendance> attendance,
    DateTime startDate,
    DateTime endDate,
  ) {
    double totalHours = 0.0;
    double totalOvertime = 0.0;
    int totalLateMinutes = 0;
    int totalDays = (endDate.difference(startDate).inDays + 1);
    int attendedDays = 0;

    for (var record in attendance) {
      if (record.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          record.date.isBefore(endDate.add(const Duration(days: 1)))) {
        if (record.absenceReason == null) {
          attendedDays++;
          totalHours +=
              record.extraHours +
              (record.checkOutTime != null && record.checkInTime != null
                  ? record.checkOutTime!
                        .difference(record.checkInTime!)
                        .inHours
                        .toDouble()
                  : 0.0);
          totalOvertime += record.extraHours;
          totalLateMinutes += record.lateMinutes;
        }
      }
    }

    final attendancePercentage = totalDays > 0
        ? (attendedDays / totalDays) * 100
        : 0.0;

    return {
      'totalHours': totalHours,
      'totalOvertime': totalOvertime,
      'totalLateMinutes': totalLateMinutes,
      'attendancePercentage': attendancePercentage,
    };
  }

  void _showDateFilterDialog(BuildContext context) {
    DateTime? tempStartDate = _startDate;
    DateTime? tempEndDate = _endDate;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filter by Date Range'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () async {
                  final pickedRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedRange != null) {
                    setDialogState(() {
                      tempStartDate = pickedRange.start;
                      tempEndDate = pickedRange.end;
                    });
                  }
                },
                child: Text(
                  tempStartDate == null
                      ? 'Select Date Range'
                      : 'From ${DateFormat.yMMMd().format(tempStartDate!)} to ${DateFormat.yMMMd().format(tempEndDate!)}',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                final now = DateTime.now();
                _startDate = now.subtract(Duration(days: now.weekday - 1));
                _endDate = _startDate!.add(const Duration(days: 6));
              });
              _applyFilters();
              Navigator.pop(dialogContext);
            },
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () {
              if (tempStartDate != null && tempEndDate != null) {
                setState(() {
                  _startDate = tempStartDate;
                  _endDate = tempEndDate;
                });
                _applyFilters();
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _exportToPDF(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF export not implemented yet'),
        backgroundColor: Colors.grey,
        duration: Duration(seconds: 2),
      ),
    );
    // TODO: Implement PDF export similar to VaultScreen
  }
}
