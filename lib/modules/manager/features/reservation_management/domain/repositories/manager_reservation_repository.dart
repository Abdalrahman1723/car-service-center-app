import 'package:m_world/modules/client/client_feature/domain/entities/reservation.dart';

abstract class ManagerReservationRepository {
  Future<List<Reservation>> getReservations();
  Future<void> markReservationContacted(String reservationId);
  Future<void> deleteReservation(String reservationId);
}
