import '../entities/employee.dart';
import '../repositories/employee_repository.dart';

class UpdateEmployee {
  final EmployeeRepository repository;

  UpdateEmployee(this.repository);

  Future<void> call(Employee employee) async {
    await repository.updateEmployee(employee);
  }
}
