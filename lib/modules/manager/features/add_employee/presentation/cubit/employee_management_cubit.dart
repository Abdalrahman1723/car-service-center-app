import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/modules/manager/features/add_employee/data/repositories/employee_repository_impl.dart';

import '../../domain/entities/employee.dart';
import '../../domain/usecases/add_employee.dart';
import '../../domain/usecases/delete_employee.dart';
import '../../domain/usecases/get_employees.dart';
import '../../domain/usecases/update_employee.dart';

part 'employee_management_state.dart';

class EmployeeManagementCubit extends Cubit<EmployeeManagementState> {
  late final EmployeeRepositoryImpl _repository;
  late final GetEmployees _getEmployees;
  late final AddEmployee _addEmployee;
  late final UpdateEmployee _updateEmployee;
  late final DeleteEmployee _deleteEmployee;
  StreamSubscription<List<Employee>>? _employeeSubscription;

  EmployeeManagementCubit() : super(EmployeeManagementLoading()) {
    _repository = EmployeeRepositoryImpl();
    _addEmployee = AddEmployee(_repository);
    _getEmployees = GetEmployees(_repository);
    _updateEmployee = UpdateEmployee(_repository);
    _deleteEmployee = DeleteEmployee(_repository);
  }


  void startListening({String? searchQuery, String? role, bool? isActive}) {
    emit(EmployeeManagementLoading());
    try {
      _employeeSubscription?.cancel();
      _employeeSubscription =
          _getEmployees(
            searchQuery: searchQuery,
            role: role,
            isActive: isActive,
          ).listen(
            (employees) {
              emit(EmployeeManagementLoaded(employees: employees));
            },
            onError: (e) {
              log('Stream employees error: $e');
              emit(EmployeeManagementError('Failed to load employees: $e'));
            },
          );
    } catch (e) {
      log('Start listening employees error: $e');
      emit(EmployeeManagementError('Failed to start listening: $e'));
    }
  }

  Future<void> addEmployee(
    Employee employee,
    String email,
    String password,
  ) async {
    emit(EmployeeManagementLoading());
    try {
      await this._addEmployee(employee, email, password);
      emit(EmployeeManagementSuccess('Employee added successfully'));
    } catch (e) {
      log('Add employee error: $e');
      emit(EmployeeManagementError('Failed to add employee: $e'));
    }
  }

  Future<void> updateEmployee(Employee employee) async {
    emit(EmployeeManagementLoading());
    try {
      await this._updateEmployee(employee);
      emit(EmployeeManagementSuccess('Employee updated successfully'));
    } catch (e) {
      log('Update employee error: $e');
      emit(EmployeeManagementError('Failed to update employee: $e'));
    }
  }

  Future<void> deleteEmployee(String employeeId) async {
    emit(EmployeeManagementLoading());
    try {
      await this._deleteEmployee(employeeId);
      emit(EmployeeManagementSuccess('Employee deleted successfully'));
    } catch (e) {
      log('Delete employee error: $e');
      emit(EmployeeManagementError('Failed to delete employee: $e'));
    }
  }

  @override
  Future<void> close() {
    _employeeSubscription?.cancel();
    return super.close();
  }
}
