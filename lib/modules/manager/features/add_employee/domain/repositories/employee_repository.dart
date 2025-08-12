import '../entities/employee.dart';

abstract class EmployeeRepository {
  Stream<List<Employee>> getEmployees({
    String? searchQuery,
    String? role,
    bool? isActive,
  });
  Future<void> addEmployee(Employee employee, String email, String password);
  Future<void> updateEmployee(Employee employee);
  Future<void> deleteEmployee(String employeeId);
}
