import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/modules/client/client_feature/domain/entities/reservation.dart';
import 'package:m_world/modules/client/client_feature/domain/usecases/submit_reservation.dart';
import 'client_screen_state.dart';

class ClientScreenCubit extends Cubit<ClientScreenState> {
  final SubmitReservation submitReservation;

  ClientScreenCubit({required this.submitReservation})
    : super(ClientScreenInitial());

  Future<void> submitReservationForm(Reservation reservation) async {
    try {
      emit(ClientScreenLoading());
      await submitReservation(reservation);
      emit(ClientScreenSuccess('تم تقديم الحجز بنجاح!'));
    } catch (e) {
      emit(ClientScreenError('خطأ في تقديم الحجز: $e'));
    }
  }
}
