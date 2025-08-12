import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_datasource.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  late final EmployeeDataSource dataSource;

  EmployeeRepositoryImpl()
    : dataSource = EmployeeDataSource(firestore: FirebaseFirestore.instance);

  @override
  Stream<List<Employee>> getEmployees({
    String? searchQuery,
    String? role,
    bool? isActive,
  }) {
    return dataSource.streamEmployees(
      searchQuery: searchQuery,
      role: role,
      isActive: isActive,
    );
  }

  @override
  Future<void> addEmployee(Employee employee, String email, String password) {
    return dataSource.addEmployee(employee, email, password);
  }

  @override
  Future<void> updateEmployee(Employee employee) {
    return dataSource.updateEmployee(employee);
  }

  @override
  Future<void> deleteEmployee(String employeeId) {
    return dataSource.deleteEmployee(employeeId);
  }
}
