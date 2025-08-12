import 'package:m_world/modules/manager/features/add_employee/domain/repositories/employee_repository.dart';

import '../entities/employee.dart';

class AddEmployee {
  final EmployeeRepository repository;

  AddEmployee(this.repository);

  Future<void> call(Employee employee, String email, String password) async {
    await repository.addEmployee(employee, email, password);
  }
}
