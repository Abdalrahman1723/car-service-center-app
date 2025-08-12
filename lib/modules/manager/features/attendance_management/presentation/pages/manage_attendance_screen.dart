import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/modules/manager/features/attendance_management/presentation/cubit/attendance_cubit.dart';
import 'package:m_world/modules/manager/features/employee_management/domain/entities/employee.dart';

class SupervisorAttendanceScreen extends StatefulWidget {
  const SupervisorAttendanceScreen({super.key});

  @override
  SupervisorAttendanceScreenState createState() =>
      SupervisorAttendanceScreenState();
}

class SupervisorAttendanceScreenState
    extends State<SupervisorAttendanceScreen> {
  List<Employee> _employees = [];

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
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
      body: _employees.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : BlocConsumer<AttendanceCubit, AttendanceState>(
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
                if (_employees.isEmpty) {
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
                  itemExtent: 100.0,
                  itemCount: _employees.length,
                  itemBuilder: (context, index) {
                    final employee = _employees[index];
                    return _buildEmployeeAttendanceCard(context, employee);
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmployeeAttendanceCard(BuildContext context, Employee employee) {
    return Card(
      color: Colors.blueAccent.shade400,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(child: Text(employee.fullName[0])),
        title: Text(
          employee.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Role: ${employee.role}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.login, color: Colors.green),
              tooltip: 'Check In',
              onPressed: () => _checkIn(context, employee),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              tooltip: 'Check Out',
              onPressed: () => _checkOut(context, employee),
            ),
            IconButton(
              icon: const Icon(Icons.event_busy, color: Colors.orange),
              tooltip: 'Mark Absence',
              onPressed: () => _markAbsence(context, employee),
            ),
          ],
        ),
      ),
    );
  }

  void _checkIn(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Check In ${employee.fullName}'),
        content: const Text('Confirm check-in time?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AttendanceCubit>().checkIn(
                employee.id,
                DateTime.now(),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Check In'),
          ),
        ],
      ),
    );
  }

  void _checkOut(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Check Out ${employee.fullName}'),
        content: const Text('Confirm check-out time?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AttendanceCubit>().startListening(
                employeeId: employee.id,
                startDate: DateTime.now(),
                endDate: DateTime.now(),
              );
              final state = context.read<AttendanceCubit>().state;
              if (state is AttendanceLoaded) {
                try {
                  final today = DateTime.now();
                  final record = state.attendance.firstWhere(
                    (a) =>
                        DateTime(a.date.year, a.date.month, a.date.day) ==
                        DateTime(today.year, today.month, today.day),
                    orElse: () =>
                        throw Exception('No check-in record found for today'),
                  );
                  context.read<AttendanceCubit>().checkOut(
                    record.id,
                    DateTime.now(),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Check Out'),
          ),
        ],
      ),
    );
  }

  void _markAbsence(BuildContext context, Employee employee) {
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
          TextButton(
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
}
