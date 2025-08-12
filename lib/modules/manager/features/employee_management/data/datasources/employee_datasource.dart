import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/employee.dart';

class EmployeeDataSource {
  final FirebaseFirestore _firestore ;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _employeesCollection = 'employees';
  static const String _usersCollection = 'users';

  EmployeeDataSource({required FirebaseFirestore firestore}) : _firestore = firestore;

  // Stream all employees in real-time
  Stream<List<Employee>> streamEmployees({
    String? searchQuery,
    String? role,
    bool? isActive,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(
        _employeesCollection,
      );
      if (role != null) query = query.where('role', isEqualTo: role);
      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }
      return query.snapshots().map((snapshot) {
        final employees = snapshot.docs
            .map((doc) => Employee.fromMap(doc.id, doc.data()))
            .toList();
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final queryLower = searchQuery.toLowerCase();
          return employees
              .where((e) => e.fullName.toLowerCase().contains(queryLower))
              .toList();
        }
        log('Streamed ${employees.length} employees');
        return employees;
      });
    } catch (e) {
      log('Stream employees error: $e');
      throw Exception('Failed to stream employees: $e');
    }
  }

  // Create employee with Firebase Auth account
  Future<void> addEmployee(
    Employee employee,
    String email,
    String password,
  ) async {
    try {
      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userId = userCredential.user!.uid;

      // Save employee data
      await _firestore
          .collection(_employeesCollection)
          .doc(userId)
          .set(employee.copyWith(id: userId).toMap());

      // Save user role in users collection
      await _firestore.collection(_usersCollection).doc(userId).set({
        'role': employee.role,
        'email': email,
      });
      log('Added employee: ${employee.fullName}');
    } catch (e) {
      log('Add employee error: $e');
      throw Exception('Failed to add employee: $e');
    }
  }

  // Update employee data
  Future<void> updateEmployee(Employee employee) async {
    try {
      await _firestore
          .collection(_employeesCollection)
          .doc(employee.id)
          .update(employee.toMap());
      log('Updated employee: ${employee.fullName}');
    } catch (e) {
      log('Update employee error: $e');
      throw Exception('Failed to update employee: $e');
    }
  }

  // Soft delete employee
  Future<void> deleteEmployee(String employeeId) async {
    try {
      await _firestore.collection(_employeesCollection).doc(employeeId).update({
        'isActive': false,
      });
      log('Soft deleted employee: $employeeId');
    } catch (e) {
      log('Delete employee error: $e');
      throw Exception('Failed to delete employee: $e');
    }
  }
}
