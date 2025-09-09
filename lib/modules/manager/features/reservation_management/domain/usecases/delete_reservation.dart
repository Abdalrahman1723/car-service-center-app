import 'package:m_world/modules/manager/features/reservation_management/domain/repositories/manager_reservation_repository.dart';

class DeleteReservation {
  final ManagerReservationRepository repository;

  DeleteReservation(this.repository);

  Future<void> call(String reservationId) async {
    await repository.deleteReservation(reservationId);
  }
}
