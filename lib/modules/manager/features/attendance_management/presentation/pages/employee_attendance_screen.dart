import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:m_world/core/constants/app_strings.dart';
import 'package:m_world/modules/manager/features/attendance_management/domain/entities/attendance.dart';
import 'package:m_world/modules/manager/features/attendance_management/presentation/cubit/attendance_cubit.dart';
import 'package:m_world/modules/manager/features/employee_management/domain/entities/employee.dart';

class EmployeeAttendanceScreen extends StatefulWidget {
  final Employee employee;

  const EmployeeAttendanceScreen({super.key, required this.employee});

  @override
  EmployeeAttendanceScreenState createState() =>
      EmployeeAttendanceScreenState();
}

class EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen> {
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  final String userRole = 'manager';

  @override
  void initState() {
    super.initState();
    context.read<AttendanceCubit>().startListening(
      employeeId: widget.employee.id,
    );
  }

  void _applyFilters() {
    context.read<AttendanceCubit>().startListening(
      employeeId: widget.employee.id,
      status: _selectedStatus,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('حضور: ${widget.employee.fullName}'),
        actions: [
          if (userRole == 'manager')
            IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filter Attendance',
              onPressed: () => _showFilterDialog(context),
            ),
        ],
      ),
      body: Column(
        children: [
          // Employee Details Card
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: _buildEmployeeDetails(),
          ),

          // Weekly Summary Card
          BlocBuilder<AttendanceCubit, AttendanceState>(
            builder: (context, state) {
              if (state is AttendanceLoaded) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: _buildWeeklySummary(state),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Attendance Records List
          Expanded(
            child: BlocConsumer<AttendanceCubit, AttendanceState>(
              listener: (context, state) {
                if (state is AttendanceError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } else if (state is AttendanceSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AttendanceLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AttendanceLoaded) {
                  if (state.groupedAttendance.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد سجلات حضور.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16.0, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    itemCount: state.groupedAttendance.length,
                    itemBuilder: (context, groupIndex) {
                      final groupKey = state.groupedAttendance.keys.elementAt(
                        groupIndex,
                      );
                      final records = state.groupedAttendance[groupKey]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDateDivider(groupKey),
                          ...records.map(
                            (record) => _buildAttendanceCard(context, record),
                          ),
                          const SizedBox(height: 16.0),
                        ],
                      );
                    },
                  );
                }
                return const Center(
                  child: Text(
                    'لا توجد سجلات حضور.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeDetails() {
    return Card(
      color: Colors.blue.shade300,
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.employee.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Role: ${widget.employee.role}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummary(AttendanceLoaded state) {
    return Card(
      color: Colors.white,

      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Summary',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Total Hours',
              '${state.totalHours.toStringAsFixed(2)} hrs',
            ),
            _buildSummaryRow(
              'Overtime',
              '${state.totalOvertime.toStringAsFixed(2)} hrs',
            ),
            _buildSummaryRow('Late Minutes', '${state.totalLateMinutes} min'),
            _buildSummaryRow(
              'Attendance',
              '${state.attendancePercentage.toStringAsFixed(1)}%',
              color: state.attendancePercentage >= 90
                  ? Colors.green
                  : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateDivider(String group) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        group,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(BuildContext context, Attendance record) {
    final statusColor = record.compensationStatus == AppStrings.onTime
        ? Colors.green
        : record.compensationStatus == AppStrings.compensated
        ? Colors.blue.shade500
        : record.compensationStatus == AppStrings.notCompensated
        ? Colors.orange
        : Colors.red;

    return Card(
      color: Colors.white54,

      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(Icons.access_time_filled, color: statusColor),
        ),
        title: Text(
          record.compensationStatus,
          style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
        ),
        subtitle: record.absenceReason != null
            ? Text(
                'Reason: ${record.absenceReason}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              )
            : Text(
                'Check-in: ${record.checkInTime != null ? DateFormat.jm().format(record.checkInTime!) : 'N/A'}\n'
                'Check-out: ${record.checkOutTime != null ? DateFormat.jm().format(record.checkOutTime!) : 'N/A'}',
                style: const TextStyle(height: 1.5),
              ),
        trailing: record.absenceReason != null
            ? null
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (record.isLate)
                    Text(
                      'Late: ${record.lateMinutes} min',
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  if (record.leftEarly)
                    Text(
                      'Early: ${record.earlyMinutes} min',
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  if (record.extraHours > 0)
                    Text(
                      'Overtime: ${record.extraHours.toStringAsFixed(1)} hrs',
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                ],
              ),
        onTap: userRole == 'manager'
            ? () => showDialog(
                context: context,
                builder: (_) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: _buildCompensationDialog(context, record),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildCompensationDialog(BuildContext context, Attendance record) {
    String? selectedStatus = record.compensationStatus;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Update Compensation Status',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedStatus,
            items: [
              AppStrings.onTime,
              AppStrings.compensated,
              AppStrings.notCompensated,
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (value) => setState(() => selectedStatus = value),
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (selectedStatus != null) {
                    context.read<AttendanceCubit>().updateCompensationStatus(
                      record.id,
                      selectedStatus!,
                    );
                  }
                  Navigator.pop(context);
                },
                child: const Text('Update'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    String? tempStatus = _selectedStatus;
    DateTime? tempStartDate = _startDate;
    DateTime? tempEndDate = _endDate;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filter Attendance'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                  ),
                  value: tempStatus,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...[
                      AppStrings.onTime,
                      AppStrings.compensated,
                      AppStrings.notCompensated,
                    ].map((s) => DropdownMenuItem(value: s, child: Text(s))),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => tempStatus = value),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
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
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStatus = null;
                _startDate = null;
                _endDate = null;
              });
              _applyFilters();
              Navigator.pop(dialogContext);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStatus = tempStatus;
                _startDate = tempStartDate;
                _endDate = tempEndDate;
              });
              _applyFilters();
              Navigator.pop(dialogContext);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
