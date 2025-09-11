import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_world/core/services/auth_service.dart';
import 'package:m_world/modules/manager/features/reservation_management/domain/usecases/delete_reservation.dart';
import 'package:m_world/modules/manager/features/reservation_management/domain/usecases/get_reservations.dart';
import 'package:m_world/modules/manager/features/reservation_management/domain/usecases/mark_reservation_contacted.dart';

import 'manager_reservation_state.dart';

class ManagerReservationCubit extends Cubit<ManagerReservationState> {
  final GetReservations getReservations;
  final MarkReservationContacted markReservationContacted;
  final DeleteReservation deleteReservation;
  final AuthService authHelper;

  ManagerReservationCubit({
    required this.getReservations,
    required this.markReservationContacted,
    required this.deleteReservation,
    required this.authHelper,
  }) : super(ManagerReservationInitial());

  Future<void> loadReservations() async {
    try {
      final userId = authHelper.currentUser?.uid;
      final userRole = userId != null
          ? await authHelper.getUserRole(userId)
          : null;
      if (userRole != UserRole.admin) {
        emit(ManagerReservationError('للمديرين فقط'));
        return;
      }
      emit(ManagerReservationLoading());
      final reservations = await getReservations();
      emit(ManagerReservationLoaded(reservations));
    } catch (e) {
      emit(ManagerReservationError('فشل في تحميل الحجوزات: $e'));
    }
  }

  Future<void> markAsContacted(String reservationId) async {
    try {
      final userId = authHelper.currentUser?.uid;
      final userRole = userId != null
          ? await authHelper.getUserRole(userId)
          : null;
      if (userRole != UserRole.admin) {
        emit(ManagerReservationError('للمديرين فقط'));
        return;
      }
      emit(ManagerReservationLoading());
      await markReservationContacted(reservationId);
      final reservations = await getReservations();
      emit(ManagerReservationLoaded(reservations));
    } catch (e) {
      emit(ManagerReservationError('فشل في تحديث الحجز: $e'));
    }
  }

  Future<void> removeReservation(String reservationId) async {
    try {
      final userId = authHelper.currentUser?.uid;
      final userRole = userId != null
          ? await authHelper.getUserRole(userId)
          : null;
      if (userRole != UserRole.admin) {
        emit(ManagerReservationError('للمديرين فقط'));
        return;
      }
      emit(ManagerReservationLoading());
      await deleteReservation(reservationId);
      final reservations = await getReservations();
      emit(ManagerReservationLoaded(reservations));
    } catch (e) {
      emit(ManagerReservationError('فشل في حذف الحجز: $e'));
    }
  }
}
