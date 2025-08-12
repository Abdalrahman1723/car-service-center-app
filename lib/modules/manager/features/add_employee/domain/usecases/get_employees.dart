import '../entities/employee.dart';
import '../repositories/employee_repository.dart';

class GetEmployees {
  final EmployeeRepository repository;

  GetEmployees(this.repository);

  Stream<List<Employee>> call({
    String? searchQuery,
    String? role,
    bool? isActive,
  }) {
    return repository.getEmployees(
      searchQuery: searchQuery,
      role: role,
      isActive: isActive,
    );
  }
}
