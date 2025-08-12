
part of 'employee_management_cubit.dart';


abstract class EmployeeManagementState {}

class EmployeeManagementInitial extends EmployeeManagementState {}

class EmployeeManagementLoading extends EmployeeManagementState {}

class EmployeeManagementLoaded extends EmployeeManagementState {
  final List<Employee> employees;

  EmployeeManagementLoaded({required this.employees});
}

class EmployeeManagementSuccess extends EmployeeManagementState {
  final String message;

  EmployeeManagementSuccess(this.message);
}

class EmployeeManagementError extends EmployeeManagementState {
  final String message;

  EmployeeManagementError(this.message);
}
