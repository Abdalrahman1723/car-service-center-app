import 'package:m_world/modules/client/client_feature/domain/entities/reservation.dart';

abstract class ReservationRepository {
  Future<void> submitReservation(Reservation reservation);
}