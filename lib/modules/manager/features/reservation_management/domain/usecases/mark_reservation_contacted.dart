
import 'package:m_world/modules/manager/features/reservation_management/domain/repositories/manager_reservation_repository.dart';

class MarkReservationContacted {
  final ManagerReservationRepository repository;

  MarkReservationContacted(this.repository);

  Future<void> call(String reservationId) async {
    await repository.markReservationContacted(reservationId);
  }
}