import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_employee_state.dart';

class AddEmployeeCubit extends Cubit<AddEmployeeState> {
  AddEmployeeCubit() : super(AddEmployeeInitial());
}
