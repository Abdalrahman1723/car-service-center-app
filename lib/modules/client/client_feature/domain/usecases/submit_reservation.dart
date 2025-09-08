import 'package:m_world/modules/client/client_feature/domain/entities/reservation.dart';
import 'package:m_world/modules/client/client_feature/domain/repositories/reservation_repository.dart';

class SubmitReservation {
  final ReservationRepository repository;

  SubmitReservation(this.repository);

  Future<void> call(Reservation reservation) async {
    await repository.submitReservation(reservation);
  }
}
