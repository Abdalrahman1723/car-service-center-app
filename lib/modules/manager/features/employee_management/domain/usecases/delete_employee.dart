import '../repositories/employee_repository.dart';

class DeleteEmployee {
  final EmployeeRepository repository;

  DeleteEmployee(this.repository);

  Future<void> call(String employeeId) async {
    await repository.deleteEmployee(employeeId);
  }
}
