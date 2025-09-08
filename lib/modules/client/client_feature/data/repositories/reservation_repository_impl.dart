import 'package:m_world/modules/client/client_feature/data/datasources/reservation_datasource.dart';
import 'package:m_world/modules/client/client_feature/domain/entities/reservation.dart';
import 'package:m_world/modules/client/client_feature/domain/repositories/reservation_repository.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationDataSource dataSource;

  ReservationRepositoryImpl(this.dataSource);

  @override
  Future<void> submitReservation(Reservation reservation) async {
    try {
      await dataSource.submitReservation(reservation);
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }
}
