import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/modules/manager/features/attendance_management/domain/entities/attendance.dart';
import 'package:m_world/modules/manager/features/attendance_management/presentation/cubit/attendance_cubit.dart';
import 'package:m_world/modules/manager/features/employee_management/domain/entities/employee.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SupervisorAttendanceScreen extends StatefulWidget {
  const SupervisorAttendanceScreen({super.key});

  @override
  SupervisorAttendanceScreenState createState() =>
      SupervisorAttendanceScreenState();
}

class SupervisorAttendanceScreenState
    extends State<SupervisorAttendanceScreen> {
  List<Employee> _employees = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    context.read<AttendanceCubit>().startListening(allEmployees: true);
    _fetchEmployees();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchEmployees() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('employees')
        .where('isActive', isEqualTo: true)
        .get();
    setState(() {
      _employees = snapshot.docs
          .map((doc) => Employee.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Attendance')),
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
          if (state is AttendanceLoading || _employees.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AttendanceLoaded &&
              state.attendance.isEmpty &&
              _employees.isEmpty) {
            return const Center(
              child: Text(
                'No active employees found.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _employees.length,
            itemBuilder: (context, index) {
              final employee = _employees[index];
              final todayRecord = state is AttendanceLoaded
                  ? state.attendance.cast<Attendance?>().firstWhere(
                      (a) =>
                          a!.employeeId == employee.id &&
                          DateTime(a.date.year, a.date.month, a.date.day) ==
                              DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                              ),
                      orElse: () => null,
                    )
                  : null;

              return _buildEmployeeAttendanceCard(
                context,
                employee,
                todayRecord,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmployeeAttendanceCard(
    BuildContext context,
    Employee employee,
    Attendance? todayRecord,
  ) {
    final isDayComplete = todayRecord?.checkOutTime != null;
    final canCheckIn = todayRecord == null;
    final cardColor = todayRecord?.absenceReason != null
        ? Colors.grey.shade300
        : isDayComplete
        ? Colors.green.shade100
        : todayRecord != null
        ? Colors.orange.shade100
        : Colors.blueAccent.shade100;

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              employee.fullName[0],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            employee.fullName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Role: ${employee.role}'),
              if (todayRecord != null) _buildWorkHoursCounter(todayRecord),
            ],
          ),
          trailing: _buildAttendanceActions(
            context,
            employee,
            todayRecord,
            canCheckIn,
            isDayComplete,
          ),
        ),
      ),
    );
  }

  Widget _buildWorkHoursCounter(Attendance record) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final now = DateTime.now();
        final checkIn = record.checkInTime;
        final checkOut = record.checkOutTime;
        Duration? duration;

        if (checkIn != null) {
          duration = checkOut != null
              ? checkOut.difference(checkIn)
              : now.difference(checkIn);
        }

        if (duration == null) {
          return const Text('Hours Worked: N/A');
        }

        final hours = duration.inHours;
        final minutes = duration.inMinutes.remainder(60);

        return Text(
          'Hours Worked: ${hours}h ${minutes}m',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        );
      },
    );
  }

  Widget _buildAttendanceActions(
    BuildContext context,
    Employee employee,
    Attendance? todayRecord,
    bool canCheckIn,
    bool isDayComplete,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        //check in button
        IconButton(
          icon: Icon(
            Icons.login,
            color: canCheckIn ? Colors.green : Colors.grey,
          ),
          tooltip: 'Check In',
          onPressed: canCheckIn
              ? () => _showCheckInDialog(context, employee)
              : null,
        ),
        //check out button
        IconButton(
          icon: Icon(
            Icons.logout,
            color:
                !isDayComplete &&
                    !canCheckIn &&
                    (todayRecord?.absenceReason == null)
                ? Colors.red
                : Colors.grey,
          ),
          tooltip: 'Check Out',
          onPressed:
              (!isDayComplete &&
                  !canCheckIn &&
                  (todayRecord?.absenceReason == null))
              ? () => _showCheckOutDialog(context, employee, todayRecord!)
              : null,
        ),
        IconButton(
          icon: Icon(
            Icons.event_busy,
            color: canCheckIn ? Colors.orange : Colors.grey,
          ),
          tooltip: 'Mark Absence',
          onPressed: canCheckIn
              ? () => _showMarkAbsenceDialog(context, employee)
              : null,
        ),
      ],
    );
  }

  Future<void> _showCheckInDialog(
    BuildContext context,
    Employee employee,
  ) async {
    DateTime? selectedDate = DateTime.now();
    TimeOfDay? selectedTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Check In ${employee.fullName}'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDatePickerField(
                  context,
                  'Check-in Date',
                  selectedDate!,
                  (date) => setState(() => selectedDate = date),
                ),
                const SizedBox(height: 16),
                _buildTimePickerField(
                  context,
                  'Check-in Time',
                  selectedTime!,
                  (time) => setState(() => selectedTime = time),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedDate == null || selectedTime == null) {
                // Handle case where date/time is not selected
                return;
              }
              final checkInTime = DateTime(
                selectedDate!.year,
                selectedDate!.month,
                selectedDate!.day,
                selectedTime!.hour,
                selectedTime!.minute,
              );
              context.read<AttendanceCubit>().checkIn(employee.id, checkInTime);
              Navigator.pop(dialogContext);
            },
            child: const Text('Check In'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCheckOutDialog(
    BuildContext context,
    Employee employee,
    Attendance record,
  ) async {
    DateTime? selectedDate = record.checkOutTime ?? DateTime.now();
    TimeOfDay? selectedTime = TimeOfDay.fromDateTime(
      record.checkOutTime ?? DateTime.now(),
    );

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Check Out ${employee.fullName}'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDatePickerField(
                  context,
                  'Check-out Date',
                  selectedDate!,
                  (date) => setState(() => selectedDate = date),
                ),
                const SizedBox(height: 16),
                _buildTimePickerField(
                  context,
                  'Check-out Time',
                  selectedTime!,
                  (time) => setState(() => selectedTime = time),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedDate == null || selectedTime == null) {
                // Handle case where date/time is not selected
                return;
              }
              final checkOutTime = DateTime(
                selectedDate!.year,
                selectedDate!.month,
                selectedDate!.day,
                selectedTime!.hour,
                selectedTime!.minute,
              );
              context.read<AttendanceCubit>().checkOut(record.id, checkOutTime);
              Navigator.pop(dialogContext);
            },
            child: const Text('Check Out'),
          ),
        ],
      ),
    );
  }

  void _showMarkAbsenceDialog(BuildContext context, Employee employee) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Mark Absence for ${employee.fullName}'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for Absence',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                context.read<AttendanceCubit>().markAbsence(
                  employee.id,
                  DateTime.now(),
                  reasonController.text,
                );
                Navigator.pop(dialogContext);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text('Mark Absence'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerField(
    BuildContext context,
    String label,
    TimeOfDay time,
    ValueChanged<TimeOfDay> onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final newTime = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (newTime != null) {
          onChanged(newTime);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.access_time),
        ),
        child: Text(
          time.format(context),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }

  Widget _buildDatePickerField(
    BuildContext context,
    String label,
    DateTime date,
    ValueChanged<DateTime> onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final newDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now().subtract(const Duration(days: 2)),
          lastDate: DateTime.now().add(const Duration(days: 2)),
        );
        if (newDate != null) {
          onChanged(newDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          DateFormat.yMMMd().format(date),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
