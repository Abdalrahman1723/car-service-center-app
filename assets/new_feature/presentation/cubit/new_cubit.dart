import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'new_state.dart';

class NewCubit extends Cubit<NewState> {
  NewCubit() : super(NewInitial());
}
